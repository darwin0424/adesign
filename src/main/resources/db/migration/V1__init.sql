-- Flyway V1 migration: initial schema for IM prototype

-- user 表
CREATE TABLE IF NOT EXISTS `user` (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(255) NOT NULL,
  nickname VARCHAR(50),
  avatar VARCHAR(255),
  status TINYINT DEFAULT 0,
  deleted_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (username)
);

-- message 表
CREATE TABLE IF NOT EXISTS message (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  message_id VARCHAR(64) NOT NULL,
  from_user BIGINT NOT NULL,
  conversation_id BIGINT NOT NULL,
  conversation_type TINYINT NOT NULL,
  conversation_pair VARCHAR(64),
  content_type VARCHAR(50),
  content TEXT,
  timestamp BIGINT,
  status TINYINT DEFAULT 0,
  recalled BOOLEAN DEFAULT FALSE,
  recalled_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (message_id)
);
CREATE INDEX idx_message_conversation ON message(conversation_id, conversation_type, created_at DESC);
CREATE INDEX idx_message_from_user ON message(from_user, created_at DESC);
CREATE INDEX idx_message_pair ON message(conversation_pair);

-- offline_message
CREATE TABLE IF NOT EXISTS offline_message (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  message_id VARCHAR(64) NOT NULL,
  conversation_type TINYINT NOT NULL,
  conversation_id BIGINT NOT NULL,
  from_user BIGINT NOT NULL,
  content_type VARCHAR(50),
  content TEXT,
  timestamp BIGINT,
  expire_at TIMESTAMP,
  status TINYINT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_offline_user ON offline_message(user_id, status, created_at DESC);

-- token_blacklist
CREATE TABLE IF NOT EXISTS token_blacklist (
  token_hash VARCHAR(128) PRIMARY KEY,
  user_id BIGINT,
  expire_at TIMESTAMP,
  reason VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_token_user ON token_blacklist(user_id);

-- file_metadata
CREATE TABLE IF NOT EXISTS file_metadata (
  id VARCHAR(36) PRIMARY KEY,
  original_name VARCHAR(255),
  stored_name VARCHAR(255),
  file_path VARCHAR(500),
  file_size BIGINT,
  mime_type VARCHAR(100),
  uploader_id BIGINT,
  upload_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expire_at TIMESTAMP NULL
);
CREATE INDEX idx_file_uploader ON file_metadata(uploader_id, upload_time DESC);

-- group_message_read
CREATE TABLE IF NOT EXISTS group_message_read (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  message_id VARCHAR(64),
  group_id BIGINT,
  user_id BIGINT,
  read_time TIMESTAMP
);
CREATE INDEX idx_group_read_user ON group_message_read(user_id);

-- system_notification
CREATE TABLE IF NOT EXISTS system_notification (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT,
  type VARCHAR(50),
  content TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  priority TINYINT DEFAULT 0,
  expire_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_notification_user ON system_notification(user_id, is_read, created_at DESC);