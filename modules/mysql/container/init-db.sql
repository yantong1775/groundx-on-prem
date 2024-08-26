CREATE DATABASE IF NOT EXISTS eyelevel;

USE eyelevel;

CREATE TABLE IF NOT EXISTS `partner_users` (
  `customer_username` varchar(255) NOT NULL,
  `partner_username` varchar(255) NOT NULL,
  `status` varchar(20) DEFAULT 'user',
  `customer_email` varchar(255) NOT NULL,
  `created` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `eula` tinyint(4) DEFAULT NULL,
  `customer_id` varchar(50) DEFAULT NULL,
  `ingested` tinyint(1) NOT NULL DEFAULT '0',
  `searched` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `customer_username_2` (`customer_username`),
  KEY `customer_username` (`customer_username`,`partner_username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `apikeys` (
  `apikey` varchar(40) NOT NULL,
  `name` varchar(80) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `created` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`apikey`),
  KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `partner_subscription_plans` (
  `partner_username` varchar(255) NOT NULL,
  `plan_id` varchar(40) NOT NULL,
  `ai_source` varchar(40) DEFAULT NULL,
  `metadata` mediumtext,
  `name` varchar(80) DEFAULT NULL,
  `has_onboarding` tinyint(1) NOT NULL DEFAULT '0',
  KEY `partner_username` (`partner_username`,`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `partner_subscriptions` (
  `customer_username` varchar(255) NOT NULL,
  `plan_id` varchar(40) NOT NULL,
  `purchase_id` varchar(40) NOT NULL,
  `status` varchar(20) DEFAULT 'active',
  `metadata` mediumtext,
  `created` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `until` datetime DEFAULT NULL,
  `activated` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  PRIMARY KEY (`purchase_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nlp_models` (
  `model_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `type` varchar(20) NOT NULL,
  `settings` mediumtext,
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `demo_uuid` varchar(36) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `indices` varchar(10) DEFAULT NULL,
  `purpose` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`model_id`),
  KEY `username` (`username`),
  KEY `demo_uuid` (`demo_uuid`),
  CONSTRAINT `nlp_models_ibfk_1` FOREIGN KEY (`username`) REFERENCES `partner_users` (`customer_username`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11089 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `processors` (
  `name` varchar(30) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `processor_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `ptype` varchar(20) NOT NULL,
  `settings` mediumtext,
  `priority` int(10) unsigned NOT NULL DEFAULT '50',
  PRIMARY KEY (`processor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `partner_customer_ids` (
  `username` varchar(255) NOT NULL,
  `partner_id` varchar(255) NOT NULL,
  PRIMARY KEY (`username`,`partner_id`),
  CONSTRAINT `partner_customer_ids_ibfk_1` FOREIGN KEY (`username`) REFERENCES `partner_users` (`customer_username`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nlp_kits` (
  `kit_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `username` varchar(255) NOT NULL,
  `type` varchar(20) NOT NULL,
  `settings` mediumtext,
  `model_version` varchar(10) NOT NULL,
  `category` varchar(8) DEFAULT NULL,
  `indices` varchar(10) DEFAULT NULL,
  `ai_source` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`kit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `api_projects` (
  `model_id` bigint(20) unsigned NOT NULL,
  `customer_project_id` varchar(20) DEFAULT NULL,
  `name` varchar(80) DEFAULT NULL,
  `customer_username` varchar(255) NOT NULL,
  `group_id` bigint(20) unsigned DEFAULT NULL,
  KEY `model_id` (`model_id`),
  CONSTRAINT `api_projects_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `nlp_models` (`model_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nlp_model_training` (
  `model_id` bigint(20) unsigned DEFAULT NULL,
  `task_id` varchar(36) NOT NULL,
  `completed_time` datetime DEFAULT NULL,
  `started_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `username` varchar(255) NOT NULL,
  `partner_username` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL,
  `model_version` varchar(10) DEFAULT NULL,
  `metadata` mediumtext,
  `training_file` mediumtext,
  `content_file` varchar(255) DEFAULT NULL,
  `external_metadata` mediumtext,
  `demo_uuid` varchar(36) DEFAULT NULL,
  `kit_id` bigint(20) unsigned DEFAULT NULL,
  `quality_rating` float NOT NULL DEFAULT '0',
  `slack_ts` mediumtext,
  PRIMARY KEY (`task_id`),
  KEY `demo_uuid` (`demo_uuid`),
  KEY `model_id` (`model_id`),
  KEY `kit_id` (`kit_id`),
  CONSTRAINT `nlp_model_training_ibfk_2` FOREIGN KEY (`demo_uuid`) REFERENCES `nlp_models` (`demo_uuid`) ON DELETE CASCADE,
  CONSTRAINT `nlp_model_training_ibfk_3` FOREIGN KEY (`model_id`) REFERENCES `nlp_models` (`model_id`) ON DELETE CASCADE,
  CONSTRAINT `nlp_model_training_ibfk_4` FOREIGN KEY (`kit_id`) REFERENCES `nlp_kits` (`kit_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nlp_model_training_files` (
  `document_id` varchar(36) NOT NULL,
  `model_id` bigint(20) unsigned DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `content_url` varchar(1000) DEFAULT NULL,
  `training_url` varchar(1000) DEFAULT NULL,
  `ai_source` varchar(40) DEFAULT NULL,
  `status` varchar(20) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status_message` mediumtext,
  `extract_id` varchar(80) DEFAULT NULL,
  `text_url` varchar(1000) DEFAULT NULL,
  `task_id` varchar(36) DEFAULT NULL,
  `file_type` varchar(10) DEFAULT NULL,
  `source_url` varchar(1000) DEFAULT NULL,
  `custom_metadata` mediumtext,
  `file_bytes` bigint(20) unsigned DEFAULT NULL,
  `annotation` varchar(50) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_tokens` bigint(20) unsigned DEFAULT NULL,
  `annotation_status` varchar(20) DEFAULT NULL,
  `xray_url` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`document_id`),
  UNIQUE KEY `id` (`id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `nlp_model_training_files_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `nlp_models` (`model_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=716796 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nlp_model_kits` (
  `model_id` bigint(20) unsigned NOT NULL,
  `kit_id` bigint(20) unsigned DEFAULT NULL,
  `priority` tinyint(4) NOT NULL DEFAULT '30',
  `reference_model_id` bigint(20) unsigned DEFAULT NULL,
  UNIQUE KEY `model_id` (`model_id`,`reference_model_id`),
  KEY `reference_model_id` (`reference_model_id`),
  CONSTRAINT `nlp_model_kits_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `nlp_models` (`model_id`) ON DELETE CASCADE,
  CONSTRAINT `nlp_model_kits_ibfk_2` FOREIGN KEY (`reference_model_id`) REFERENCES `nlp_models` (`model_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `processor_relationships` (
  `processor_id` bigint(20) unsigned NOT NULL,
  `document_id` varchar(36) NOT NULL,
  `position` varchar(10) NOT NULL,
  `before_url` varchar(500) DEFAULT NULL,
  `after_url` varchar(500) DEFAULT NULL,
  `priority` int(10) unsigned NOT NULL DEFAULT '50',
  `status` varchar(20) NOT NULL DEFAULT 'queued',
  KEY `document_id` (`document_id`),
  KEY `processor_id` (`processor_id`,`document_id`,`position`),
  CONSTRAINT `processor_relationships_ibfk_1` FOREIGN KEY (`processor_id`) REFERENCES `processors` (`processor_id`) ON DELETE CASCADE,
  CONSTRAINT `processor_relationships_ibfk_2` FOREIGN KEY (`document_id`) REFERENCES `nlp_model_training_files` (`document_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `partner_subscription_relationships` (
  `customer_username` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned DEFAULT NULL,
  `web_id` bigint(20) unsigned DEFAULT NULL,
  `web_domain` varchar(255) DEFAULT NULL,
  `template_id` bigint(20) unsigned DEFAULT NULL,
  `live_chat_metadata` varchar(255) DEFAULT NULL,
  `purchase_id` varchar(40) NOT NULL,
  `welcome_flow` varchar(255) DEFAULT NULL,
  `type` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`purchase_id`),
  KEY `customer_username` (`customer_username`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `partner_subscription_relationships_ibfk_2` FOREIGN KEY (`customer_username`) REFERENCES `partner_users` (`customer_username`) ON DELETE CASCADE,
  CONSTRAINT `partner_subscription_relationships_ibfk_3` FOREIGN KEY (`model_id`) REFERENCES `nlp_models` (`model_id`) ON DELETE CASCADE,
  CONSTRAINT `partner_subscription_relationships_ibfk_4` FOREIGN KEY (`purchase_id`) REFERENCES `partner_subscriptions` (`purchase_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
