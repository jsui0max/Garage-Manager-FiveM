<?php
session_start();
require_once 'db.php';
require_once 'auth.php';

if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}
if (isset($_GET['id'])) {
    $stmt = $pdo->prepare("SELECT * FROM rendezvous_mecano WHERE id = :id");
    $stmt->execute(['id' => $_GET['id']]);
    $rdv = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$rdv) {
        die("Rendez-vous non trouvé");
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $stmt = $pdo->prepare("UPDATE rendezvous_mecano SET
        nom_joueur = :nom_joueur,
        garage = :garage,
        vehicule = :vehicule,
        plaque = :plaque,
        numero_tel = :numero_tel,
        date_rdv = :date_rdv,
        motif = :motif
        -- numero_or = :numero_or
        WHERE id = :id");

    $stmt->execute([
        'nom_joueur' => $_POST['nom_joueur'],
        'garage' => $_POST['garage'],
        'vehicule' => $_POST['vehicule'],
        'plaque' => $_POST['plaque'],
        'numero_tel' => $_POST['numero_tel'],
        'date_rdv' => $_POST['date_rdv'],
        'motif' => $_POST['motif'],
        // 'numero_or' => $_POST['numero_or'],
        'id' => $_GET['id']
    ]);

    header("Location: index.php"); 
    exit;
}

?>

<!DOCTYPE html>
<html>
<head>
    <title>Éditer Rendez-vous</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <h1>Éditer le Rendez-vous</h1>
    <form method="post">
        <label>Nom du joueur</label>
        <input type="text" name="nom_joueur" value="<?= htmlspecialchars($rdv['nom_joueur']) ?>" required><br>

        <label>Garage</label>
        <input type="text" name="garage" value="<?= htmlspecialchars($rdv['garage']) ?>" required><br>

        <label>Véhicule</label>
        <input type="text" name="vehicule" value="<?= htmlspecialchars($rdv['vehicule']) ?>" required><br>

        <label>Plaque</label>
        <input type="text" name="plaque" value="<?= htmlspecialchars($rdv['plaque']) ?>" required><br>

        <label>Téléphone</label>
        <input type="text" name="numero_tel" value="<?= htmlspecialchars($rdv['numero_tel']) ?>" required><br>

        <label>Date</label>
        <input type="datetime-local" name="date_rdv" value="<?= date('Y-m-d H:i', strtotime($rdv['date_rdv'])) ?>" required><br>

        <label>Motif</label>
        <textarea name="motif" required><?= htmlspecialchars($rdv['motif']) ?></textarea><br>


        <button type="submit">Enregistrer les modifications</button>
    </form>
    <a href="index.php" class="back-btn">Retour</a>
</body>
</html>
