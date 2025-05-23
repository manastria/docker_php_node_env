#!/bin/bash

set -e

# --- Variables
# Source les variables communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/vars.sh"


# sudo apt update && sudo apt upgrade -y

# --- 1. Installer l'environnement graphique LXDE minimal
echo "[+] Installation de LXDE et des utilitaires"
sudo apt update
sudo apt install --no-install-recommends -y \
    lxde-core \
    lightdm lxterminal \
    lightdm-gtk-greeter lightdm-gtk-greeter-settings \
    xserver-xorg xserver-xorg-video-all xserver-xorg-input-all \
    console-setup keyboard-configuration \
    firefox-esr \
    pcmanfm \
    mousepad \
    gvfs-backends \
    php-cli \
    samba-client

# --- 1. Créer l'utilisateur s'il n'existe pas
"$SCRIPT_DIR/add_user.sh"

# --- 3. Configurer le clavier en AZERTY (FR)
echo "[+] Configuration du clavier en français (AZERTY)"
sudo sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="fr"/' /etc/default/keyboard
sudo sed -i 's/^XKBMODEL=.*/XKBMODEL="pc105"/' /etc/default/keyboard
sudo sed -i '/^XKBVARIANT=/c\XKBVARIANT=""' /etc/default/keyboard
sudo sed -i '/^XKBOPTIONS=/c\XKBOPTIONS=""' /etc/default/keyboard
sudo systemctl restart keyboard-setup.service

# --- 4. Créer le raccourci "Mon site" sur le bureau
echo "[+] Création du raccourci Mon site"
sudo -u "$USERNAME" mkdir -p "$USER_HOME/Bureau"

cat <<EOF | sudo tee "$USER_HOME/Bureau/Mon_site.desktop" > /dev/null
[Desktop Entry]
Name=Mon site
Comment=Ouvre le site web local
Exec=firefox-esr http://$IP_SITE
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOF

sudo chmod +x "$USER_HOME/Bureau/Mon_site.desktop"
sudo chown "$USERNAME:$USERNAME" "$USER_HOME/Bureau/Mon_site.desktop"

# --- 5. Ajouter un favori Samba dans l'explorateur PCManFM
echo "[+] Ajout du favori réseau Samba"
sudo -u "$USERNAME" mkdir -p "$USER_HOME/.config/gtk-3.0"
echo "smb://$IP_SITE/$SHARE_NAME Partage Web" | sudo tee "$USER_HOME/.config/gtk-3.0/bookmarks" > /dev/null
sudo chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config"

# --- 6. Démarrage automatique : conserver l'autostart LXDE et ajouter clavier + Firefox
echo "[+] Configuration de l'autostart LXDE"
AUTOSTART_DIR="$USER_HOME/.config/lxsession/LXDE"
sudo -u "$USERNAME" mkdir -p "$AUTOSTART_DIR"

AUTOSTART_FILE="$AUTOSTART_DIR/autostart"

# 1) Copier le fichier modèle si l'utilisateur n'en a pas encore
if [ ! -f "$AUTOSTART_FILE" ]; then
    sudo -u "$USERNAME" cp /etc/xdg/lxsession/LXDE/autostart "$AUTOSTART_FILE"
fi

# 2) Ajouter @setxkbmap fr si absent
grep -qxF '@setxkbmap fr' "$AUTOSTART_FILE" || \
    echo '@setxkbmap fr' | sudo tee -a "$AUTOSTART_FILE" >/dev/null

# 3) Ajouter le lancement de Firefox si absent
grep -qxF "@firefox-esr http://$IP_SITE" "$AUTOSTART_FILE" || \
    echo "@firefox-esr http://$IP_SITE" | sudo tee -a "$AUTOSTART_FILE" >/dev/null

# 4) Droits
sudo chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config"


# --- 7. Configurer le hostname
echo "[+] Configuration du hostname"
"$SCRIPT_DIR/hostname.sh"

# --- 7. Configurer le réseau
echo "[+] Configuration du réseau"
"$SCRIPT_DIR/config_hostonly_eth0.sh"

# --- 8. Installer et configurer Samba
echo "[+] Installation de Samba"
"$SCRIPT_DIR/configure-samba.sh"

echo "[✔] Installation et configuration terminées pour l'utilisateur $USERNAME"
