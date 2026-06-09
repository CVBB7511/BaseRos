CREATE DATABASE IF NOT EXISTS robot_db
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE robot_db;

CREATE TABLE IF NOT EXISTS robot_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    robot_name VARCHAR(100) NOT NULL,
    battery FLOAT,
    pos_x FLOAT,
    pos_y FLOAT,
    yaw FLOAT,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS robot_task (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_name VARCHAR(100) NOT NULL,
    target_x FLOAT,
    target_y FLOAT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS robot_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    robot_name VARCHAR(100) NOT NULL,
    log_level VARCHAR(50),
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS restaurant_map (
    id INT AUTO_INCREMENT PRIMARY KEY,
    map_name VARCHAR(100) NOT NULL,
    version VARCHAR(50) NOT NULL,
    map_file_path VARCHAR(255),
    map_data TEXT,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS restaurant_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nav_point_name VARCHAR(50) NOT NULL UNIQUE,
    table_display_name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL DEFAULT 1,
    pos_x FLOAT NOT NULL DEFAULT 0,
    pos_y FLOAT NOT NULL DEFAULT 0,
    status VARCHAR(50) DEFAULT 'available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS menu_category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    display_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS menu_item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    image_path VARCHAR(255),
    is_available TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_menu_item_category
        FOREIGN KEY (category_id)
        REFERENCES menu_category(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS table_session (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_id INT NOT NULL,
    session_code VARCHAR(50) NOT NULL UNIQUE,
    customer_count INT DEFAULT 1,
    status VARCHAR(50) DEFAULT 'dining',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    CONSTRAINT fk_table_session_table
        FOREIGN KEY (table_id)
        REFERENCES restaurant_table(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    INDEX idx_table_session_table_id (table_id),
    INDEX idx_table_session_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    order_status VARCHAR(50) DEFAULT 'created',
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_info_session
        FOREIGN KEY (session_id)
        REFERENCES table_session(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_order_info_session_id (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    remark VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES order_info(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_order_item_menu_item
        FOREIGN KEY (item_id)
        REFERENCES menu_item(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    INDEX idx_order_item_order_id (order_id),
    INDEX idx_order_item_item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS payment_record (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    final_amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) DEFAULT 'paid',
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_record_session
        FOREIGN KEY (session_id)
        REFERENCES table_session(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_payment_record_session_id (session_id),
    INDEX idx_payment_record_paid_at (paid_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
