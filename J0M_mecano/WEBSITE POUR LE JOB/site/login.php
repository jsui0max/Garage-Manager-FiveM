<?php
session_start(); 

require_once 'db.php';
require_once 'auth.php';

$mdp = 'garage123'; 

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if ($_POST['password'] === $mdp) {
        $_SESSION['admin_logged_in'] = true;
        error_log("Connexion réussie.");
        header("Location: index.php"); 
        exit; 
    } else {
        $error = "Mot de passe incorrect.";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Connexion</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <h2>Connexion Admin</h2>
    <form method="post">
        <input type="password" name="password" placeholder="Mot de passe" required>
        <button type="submit">Se connecter</button>
    </form>
    <?php if (isset($error)) echo "<p style='color:red;'>$error</p>"; ?>
</body>
<div class="footer">
    Créé par Jsui0max
</div>
</html>
