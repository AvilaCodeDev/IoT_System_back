-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         10.6.4-MariaDB - mariadb.org binary distribution
-- SO del servidor:              Win64
-- HeidiSQL Versión:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para iot_system
CREATE DATABASE IF NOT EXISTS `iot_system` /*!40100 DEFAULT CHARACTER SET utf8mb3 */;
USE `iot_system`;

-- Volcando estructura para tabla iot_system.devices
CREATE TABLE IF NOT EXISTS `devices` (
  `id` smallint(3) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL DEFAULT 0,
  `label` varchar(255) NOT NULL,
  `manufacturer` varchar(255) NOT NULL,
  `state` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`state`)),
  PRIMARY KEY (`id`),
  KEY `FK_devices_devicetypes` (`type`),
  CONSTRAINT `FK_devices_devicetypes` FOREIGN KEY (`type`) REFERENCES `devicetypes` (`id_type`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla iot_system.devicetypes
CREATE TABLE IF NOT EXISTS `devicetypes` (
  `id_type` int(11) NOT NULL AUTO_INCREMENT,
  `type_description` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id_type`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para vista iot_system.devicesview
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `devicesview` (
	`id` SMALLINT(3) UNSIGNED ZEROFILL NOT NULL,
	`typeDescription` VARCHAR(50) NULL COLLATE 'utf8mb3_general_ci',
	`label` VARCHAR(255) NOT NULL COLLATE 'utf8mb3_general_ci',
	`state` LONGTEXT NULL COLLATE 'utf8mb4_bin',
	`type` INT(11) NOT NULL,
	`manufacturer` VARCHAR(255) NOT NULL COLLATE 'utf8mb3_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para procedimiento iot_system.DeleteDevice
DELIMITER //
CREATE PROCEDURE `DeleteDevice`(
	IN `id` SMALLINT
)
BEGIN

	DELETE FROM devices WHERE devices.id = id;

END//
DELIMITER ;

-- Volcando estructura para procedimiento iot_system.InsertData
DELIMITER //
CREATE PROCEDURE `InsertData`(
	IN `my_table` VARCHAR(50),
	IN `data` JSON
)
BEGIN
 DECLARE formated_keys TEXT DEFAULT NULL;
 DECLARE formated_data TEXT DEFAULT NULL;
 
 SET formated_keys = REPLACE(
 							REPLACE(
 								replace(
 									JSON_KEYS(DATA),
								 	'[',
								 	""),
								']',
								""
								),
								'"',
								'`'
							);
	
	SET formated_data = REPLACE(
								REPLACE( 
									Replace(
										Replace(
											JSON_EXTRACT( DATA, '$.*'),
											'[',
											''
										),
										']',
										''
									),
									'{',
									"'{"
									),
									"}",
									"}'"
								);
	
	SET @SQL = CONCAT('insert into ', my_table,'(', formated_keys,') values (', formated_data, ')');
	
	PREPARE stmt FROM @sql;
   EXECUTE stmt; 
   DEALLOCATE PREPARE stmt;
      
END//
DELIMITER ;

-- Volcando estructura para procedimiento iot_system.UpdateDevice
DELIMITER //
CREATE PROCEDURE `UpdateDevice`(
	IN `data` JSON
)
BEGIN
	DECLARE data_type TEXT DEFAULT NULL;
	declare data_label TEXT DEFAULT NULL;
	DECLARE data_manufacturer TEXT DEFAULT NULL;
	DECLARE data_state JSON DEFAULT NULL;
	DECLARE data_id INTEGER DEFAULT 0;
	
	SET data_type = Replace(JSON_EXTRACT( DATA, '$.type' ), '"', '');
	SET data_label = Replace(JSON_EXTRACT( DATA, '$.label' ), '"', '');
	SET data_manufacturer = Replace(JSON_EXTRACT( DATA, '$.manufacturer' ), '"', '');
	SET data_state = TRIM( BOTH '"' From JSON_EXTRACT( DATA, '$.state' ));
	SET data_id = replace(JSON_EXTRACT( DATA, '$.id' ), '"', '');
	
	UPDATE 
		devices 
	SET 
		devices.`type` = data_type , 
		devices.label = data_label, 
		devices.manufacturer = data_manufacturer, 
		devices.state = data_state
	where
		devices.id = data_id;
END//
DELIMITER ;

-- Volcando estructura para función iot_system.StopDevice
DELIMITER //
CREATE FUNCTION `StopDevice`() RETURNS tinyint(4)
BEGIN
	SET @lastUptdated := 0;
	
	UPDATE devices set `state` = JSON_SET(`state`,'$.turnedOn', false), id = (SELECT @lastUpdated := id) where id = ( SELECT id  FROM devices
	where 
		JSON_EXTRACT( devices.`state`, '$.turnedOn' ) = true
	ORDER BY RAND()
	LIMIT 1);

	RETURN @lastUpdated;
END//
DELIMITER ;

-- Volcando estructura para vista iot_system.devicesview
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `devicesview`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `devicesview` AS SELECT id, type_description AS `typeDescription`, label, state, id_type AS `type`, manufacturer  FROM devices
INNER JOIN devicetypes ON  devicetypes.id_type = devices.`type` ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
