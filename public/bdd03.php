<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sélection du service</title>
</head>

<body>
<?php
$connexion = mysqli_connect("db","etudiant","etudiant","empScePhp");
if ($connexion) 
{
  // connexion réussie
  mysqli_set_charset ($connexion,"utf8");
  echo '<form action="bdd03a.php" method="post">';
  echo "<h2>Liste des employés par service</h2>";
  echo "<p />Sélectionnez le service souhaité :<p />";
  echo '<select name="service" size="5">';
  $requete="select * from service order by designation;";
  $resultat= mysqli_query($connexion, $requete);
  $ligne=mysqli_fetch_assoc($resultat);
  if ($ligne) 
  {
    echo '<option selected value = "' . $ligne["code"] . '">' . $ligne["code"]
. ' ' . $ligne["designation"] . '</option>'; // ne pas changer de ligne
    $ligne=mysqli_fetch_assoc($resultat);
    while ($ligne) 
    {
      echo '<option value = "' . $ligne["code"] . '">' . $ligne["code"] 
. ' ' . $ligne["designation"] . '</option>'; // ne pas changer de ligne
      $ligne=mysqli_fetch_assoc($resultat);
    }
  }
  echo "</select>";
  echo '<p /><input type="submit" value="Afficher la liste"><p />';
  echo "</form>";
}
else
{
  echo "problème à la connexion <br />";
}
mysqli_close($connexion);
?>
</body>
</html>
