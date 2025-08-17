<?php
session_start(); 

require_once 'db.php';
require_once 'auth.php';

if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}

$stmt = $pdo->query("SELECT * FROM rendezvous_mecano");
$rendezvous = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (isset($_GET['delete'])) {
    $stmt = $pdo->prepare("DELETE FROM rendezvous_mecano WHERE id = :id");
    $stmt->execute(['id' => $_GET['delete']]);
    header("Location: index.php"); 
    exit;
}

?>

<!DOCTYPE html>
<html>
<head>
    <title>Gestion RDV</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <h1>Tableau de bord</h1>
    <a href="logout.php">Déconnexion | </a><a href="orterminer.php">Voir les OR Terminés</a>


    <!-- <form method="get">
        <input type="text" name="search" placeholder="Recherche par nom/plaque/date..." value="<?= $_GET['search'] ?? '' ?>">
        <button type="submit">Rechercher</button>
    </form> -->


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
                <th>Actions</th> 
            </tr>
        </thead>
        <tbody>
            <?php foreach ($rendezvous as $rdv): ?>
            <tr>
                <td><?= htmlspecialchars($rdv['nom_joueur']) ?></td>
                <td><?= $rdv['garage'] ?></td>
                <td><?= $rdv['vehicule'] ?></td>
                <td><?= $rdv['plaque'] ?></td>
                <td><?= $rdv['numero_tel'] ?></td>
                <td><?= $rdv['date_rdv'] ?></td>
                <td><?= $rdv['motif'] ?></td>
                <td><?= ($rdv['numero_or'] )?></td>
                <td>
                    <a href="edit_rdv.php?id=<?= $rdv['id'] ?>">Éditer</a> | 
                    <a href="?delete=<?= $rdv['id'] ?>" onclick="return confirm('Êtes-vous sûr de vouloir supprimer ce rendez-vous ?');">Supprimer</a> |
                    <a href="sauvegarder.php?id=<?= $rdv['id'] ?>" >OR terminé</a>
                </td>
            </tr>
            <?php endforeach ?>
        </tbody>
    </table><div class="footer">
    Créé par Jsui0max
</div>

</body>
</html>
