CREATE TABLE IF NOT EXISTS `garage_or` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `plate` VARCHAR(12) NOT NULL,
  `or_number` VARCHAR(20) NOT NULL,
  `owner` VARCHAR(64) NOT NULL,
  `date` DATETIME NOT NULL,
  `description` TEXT,
  `mechanic` VARCHAR(64),
  `cost` INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS `garage_rdv` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `plate` VARCHAR(12) NOT NULL,
  `owner` VARCHAR(64) NOT NULL,
  `or_number` VARCHAR(20),
  `date_rdv` DATETIME NOT NULL,
  `type_service` VARCHAR(100),
  `status` VARCHAR(20) DEFAULT 'En attente',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS `rdv_garage` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `plate` VARCHAR(12) NOT NULL,
    `date` DATETIME NOT NULL,
    `service` VARCHAR(255) NOT NULL,
    `status` ENUM('pending', 'completed', 'canceled') DEFAULT 'pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS vehicule_usure_pneus (
    plate VARCHAR(20) PRIMARY KEY,
    usure INT NOT NULL DEFAULT 100
);

CREATE TABLE `veh_km` (
  `carplate` varchar(10) NOT NULL,
  `km` varchar(255) NOT NULL DEFAULT '0',
  `state` int(1) NOT NULL DEFAULT '0',
  `reset` int(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
