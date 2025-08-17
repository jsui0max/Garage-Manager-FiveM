<?php
session_start(); 

require_once 'db.php';
require_once 'auth.php';

if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}

$stmt = $pdo->query("SELECT * FROM saves");
$or_termines = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html>
<head>
    <title>OR Terminés</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <h1>OR Terminés</h1>
    <a href="index.php">Retour</a>

    <?php if (count($or_termines) > 0): ?>
        <table>
            <thead>
                <tr>
                    <th>Nom</th>
                    <th>Garage</th>
                    <th>Véhicule</th>
                    <th>Plaque</th>
                    <th>Téléphone</th>
                    <th>Date</th>
                    <th>Motif</th>
                    <th>Validé</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($or_termines as $or): ?>
                <tr>
                    <td><?= htmlspecialchars($or['nom_joueur']) ?></td>
                    <td><?= htmlspecialchars($or['garage']) ?></td>
                    <td><?= htmlspecialchars($or['vehicule']) ?></td>
                    <td><?= htmlspecialchars($or['plaque']) ?></td>
                    <td><?= htmlspecialchars($or['numero_tel']) ?></td>
                    <td><?= htmlspecialchars($or['date_rdv']) ?></td>
                    <td><?= htmlspecialchars($or['motif']) ?></td>
                    <td><?= ($or['numero_or']) ?></td>
                </tr>
                <?php endforeach ?>
            </tbody>
        </table>
    <?php else: ?>
        <p>Aucun OR terminé trouvé.</p>
    <?php endif ?>
</body><div class="footer">
    Créé par Jsui0max
</div>
</html>
