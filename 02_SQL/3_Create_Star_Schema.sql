-- A) Create Dimension Tables 

-- 1. dim_agent
CREATE TABLE IF NOT EXISTS dim_agent(
    agent_key INT AUTO_INCREMENT PRIMARY KEY,
    agent_name VARCHAR(30) NOT NULL,
    agent_joining_date DATE NOT NULL,
    experience_level VARCHAR(20) NOT NULL
);

-- 2. dim_product
CREATE TABLE IF NOT EXISTS dim_product(
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_segment VARCHAR(100) NOT NULL UNIQUE
);

-- 3. dim_category
CREATE TABLE IF NOT EXISTS dim_category(
    category_key INT AUTO_INCREMENT PRIMARY KEY,
    issue_category VARCHAR(100) NOT NULL UNIQUE
);

-- 4. dim_channel
CREATE TABLE IF NOT EXISTS dim_channel(
    channel_key INT AUTO_INCREMENT PRIMARY KEY,
    support_channel VARCHAR(50) NOT NULL UNIQUE
);

-- 5. dim_priority
CREATE TABLE IF NOT EXISTS dim_priority(
    priority_key INT AUTO_INCREMENT PRIMARY KEY,
    priority_type VARCHAR(50) NOT NULL UNIQUE
);

-- 6. dim_status
CREATE TABLE IF NOT EXISTS dim_status(
    status_key INT AUTO_INCREMENT PRIMARY KEY,
    ticket_status VARCHAR(50) NOT NULL UNIQUE
);

-- 7. dim_country
CREATE TABLE IF NOT EXISTS dim_country(
    country_key INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(100) NOT NULL UNIQUE
);

-- 8. dim_support_tier
CREATE TABLE IF NOT EXISTS dim_support_tier(
    tier_key INT AUTO_INCREMENT PRIMARY KEY,
    support_tier VARCHAR(50) NOT NULL UNIQUE
);

-- 9. dim_date
CREATE TABLE IF NOT EXISTS dim_date(
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    week_number INT NOT NULL,
    month_number INT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    calendar_quarter INT NOT NULL,
    calendar_year INT NOT NULL
);

-- B) Create Fact Table

-- fact_support_tickets
CREATE TABLE fact_support_tickets(
    ticket_id VARCHAR(20) PRIMARY KEY,
    date_key INT NOT NULL,
    agent_key INT NOT NULL,
    product_key INT NOT NULL,
    category_key INT NOT NULL,
    channel_key INT NOT NULL,
    priority_key INT NOT NULL,
    status_key INT NOT NULL,
    country_key INT NOT NULL,
    tier_key INT NOT NULL,
    created_datetime DATETIME NOT NULL,
    resolution_hours DOUBLE NULL,
    first_response_minutes INT NULL,
    interaction_count INT NULL,
    csat_score INT NULL,
    res_sla_breach BOOLEAN NULL,
    fr_sla_breach BOOLEAN NULL,
    single_touch_flag BOOLEAN NULL,
    
    CONSTRAINT fk_date_key FOREIGN KEY(date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_agent_key FOREIGN KEY(agent_key) REFERENCES dim_agent(agent_key),
    CONSTRAINT fk_product_key FOREIGN KEY(product_key) REFERENCES dim_product(product_key),
    CONSTRAINT fk_category_key FOREIGN KEY(category_key) REFERENCES dim_category(category_key),
    CONSTRAINT fk_channel_key FOREIGN KEY(channel_key) REFERENCES dim_channel(channel_key),
    CONSTRAINT fk_priority_key FOREIGN KEY(priority_key) REFERENCES dim_priority(priority_key),
    CONSTRAINT fk_status_key FOREIGN KEY(status_key) REFERENCES dim_status(status_key),
    CONSTRAINT fk_country_key FOREIGN KEY(country_key) REFERENCES dim_country(country_key),
    CONSTRAINT fk_tier_key FOREIGN KEY(tier_key) REFERENCES dim_support_tier(tier_key)
);