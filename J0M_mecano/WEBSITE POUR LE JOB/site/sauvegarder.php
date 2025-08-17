<?php
session_start();
require_once 'db.php';
require_once 'auth.php';

if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}

if (isset($_GET['id'])) {
    $id = $_GET['id'];

    $stmt = $pdo->prepare("SELECT * FROM rendezvous_mecano WHERE id = :id");
    $stmt->execute(['id' => $id]);
    $rdv = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($rdv) {
        $stmt = $pdo->prepare("INSERT INTO saves (nom_joueur, garage, vehicule, plaque, numero_tel, date_rdv, motif, numero_or)
                               VALUES (:nom_joueur, :garage, :vehicule, :plaque, :numero_tel, :date_rdv, :motif, :numero_or)");
        $stmt->execute([
            'nom_joueur' => $rdv['nom_joueur'],
            'garage' => $rdv['garage'],
            'vehicule' => $rdv['vehicule'],
            'plaque' => $rdv['plaque'],
            'numero_tel' => $rdv['numero_tel'],
            'date_rdv' => $rdv['date_rdv'],
            'motif' => $rdv['motif'],
            'numero_or' => $rdv['numero_or']
        ]);

        $stmt = $pdo->prepare("DELETE FROM rendezvous_mecano WHERE id = :id");
        $stmt->execute(['id' => $id]);

        header("Location: index.php"); 
        exit;
    } else {
        die("Rendez-vous non trouvé.");
    }
} else {
    die("ID non fourni.");
}
?>
