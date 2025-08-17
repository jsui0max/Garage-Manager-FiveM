

DROP TABLE IF EXISTS `admins`;
CREATE TABLE IF NOT EXISTS `admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `admins`
--

INSERT INTO `admins` (`id`, `username`, `password`) VALUES
(1, 'admin', 'garage123');



--
-- Structure de la table `saves`
--

DROP TABLE IF EXISTS `saves`;
CREATE TABLE IF NOT EXISTS `saves` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nom_joueur` varchar(255) DEFAULT NULL,
  `garage` varchar(255) DEFAULT NULL,
  `vehicule` varchar(255) DEFAULT NULL,
  `plaque` varchar(255) DEFAULT NULL,
  `numero_tel` varchar(255) DEFAULT NULL,
  `date_rdv` datetime DEFAULT NULL,
  `motif` text,
  `numero_or` int DEFAULT NULL,
  `date_save` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

