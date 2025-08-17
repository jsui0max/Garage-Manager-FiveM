<?php
function get_rendezvous($pdo, $filters = []) {
    $search = $filters['search'] ?? '';
    $sql = "SELECT * FROM rendezvous_mecano";
    if ($search) {
        $sql .= " WHERE nom_joueur LIKE :search OR plaque LIKE :search OR date_rdv LIKE :search";
    }
    $stmt = $pdo->prepare($sql);
    if ($search) {
        $stmt->bindValue(':search', "%$search%");
    }
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}
