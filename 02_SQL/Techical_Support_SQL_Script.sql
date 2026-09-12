CREATE DATABASE technical_support_db;
USE technical_support_db;

-- Disable safety check (prevent accidental UPDATE or DELETE without a WHERE clause)
SET
    SQL_SAFE_UPDATES = 0;

-- Convert all the blanks to NULL
UPDATE
    csv_data_import
SET
    `Resolution DateTime` = NULLIF(`Resolution DateTime`, ''),
    `First Response DateTime` = NULLIF(`First Response DateTime`, ''),
    `Interaction Count` = NULLIF(`Interaction Count`, ''),
    `CSAT Score` = NULLIF(`CSAT Score`, ''),
    `Resolution Hours` = NULLIF(`Resolution Hours`, ''),
    `First Response Minutes` = NULLIF(`First Response Minutes`, ''),
    `Single Touch Flag` = NULLIF(`Single Touch Flag`, ''),
    `Res SLA Breach` = NULLIF(`Res SLA Breach`, ''),
    `FR SLA Breach` = NULLIF(`FR SLA Breach`, '');

-- Correct all datatypes of the imported fields
ALTER TABLE
    csv_data_import
MODIFY
    `Created DateTime` DATETIME,
MODIFY
    `SLA Resolve Due` DATETIME,
MODIFY
    `SLA First Response Due` DATETIME,
MODIFY
    `Resolution DateTime` DATETIME NULL,
MODIFY
    `First Response DateTime` DATETIME NULL,
MODIFY
    `Interaction Count` INT NULL,
MODIFY
    `CSAT Score` INT NULL,
MODIFY
    `Resolution Hours` DOUBLE NULL,
MODIFY
    `First Response Minutes` INT NULL,
MODIFY
    `Single Touch Flag` BOOLEAN NULL,
MODIFY
    `Res SLA Breach` BOOLEAN NULL,
MODIFY
    `FR SLA Breach` BOOLEAN NULL,
MODIFY
    `Agent Joining Date` DATE;

-- Change column name

ALTER TABLE
    csv_data_import RENAME COLUMN `ï»¿Status` TO `Status`;

-- Enable safety check which was disabled earlier
SET
    SQL_SAFE_UPDATES = 1;

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

-- A) Populate Dimension Tables with Data

-- 1. dim_agent
INSERT INTO
    dim_agent(
        agent_name,
        agent_joining_date,
        experience_level
    )
SELECT
    DISTINCT `Agent Name`,
    `Agent Joining Date`,
    `Experience Level`
FROM
    csv_data_import;

-- **********************************
-- 2. dim_product
INSERT INTO
    dim_product(product_segment)
SELECT
    DISTINCT `Product Segment`
FROM
    csv_data_import;

-- **********************************
-- 3. dim_category
INSERT INTO
    dim_category(issue_category)
SELECT
    DISTINCT `Issue Category`
FROM
    csv_data_import;

-- **********************************
-- 4. dim_channel
INSERT INTO
    dim_channel(support_channel)
SELECT
    DISTINCT `Support Channel`
FROM
    csv_data_import;

-- **********************************
-- 5. dim_priority
INSERT INTO
    dim_priority(priority_type)
SELECT
    DISTINCT `Priority`
FROM
    csv_data_import;

-- **********************************
-- 6. dim_status
INSERT INTO
    dim_status(ticket_status)
SELECT
    DISTINCT `Status`
FROM
    csv_data_import;

-- **********************************
-- 7. dim_country
INSERT INTO
    dim_country(country)
SELECT
    DISTINCT `Country`
FROM
    csv_data_import;

-- **********************************
-- 8. dim_support_tier
INSERT INTO
    dim_support_tier(support_tier)
SELECT
    DISTINCT `Support Tier`
FROM
    csv_data_import;

-- **********************************
-- 9. dim_date

INSERT INTO
    dim_date(
        date_key,
        full_date,
        day_of_month,
        day_of_week,
        day_name,
        week_number,
        month_number,
        month_name,
        calendar_quarter,
        calendar_year
    ) WITH RECURSIVE dates AS(
        -- Anchor (Upper Segment)
        SELECT
            DATE('2023-01-01') AS dt
        UNION ALL 
        -- Recursive Loop (Lower Segment) --> On repeat Lower, Lower, ...
        SELECT
            DATE_ADD(dt, INTERVAL 1 DAY)
        FROM
            dates
        WHERE
            dt < '2024-01-31'
    ) -- Outer Segment --> Runs once on 1D output date list
SELECT
    DATE_FORMAT(dt, '%Y%m%d') AS date_key,
    DATE(dt) AS full_date,
    DAYOFMONTH(dt) AS day_of_month,
    DAYOFWEEK(dt) AS day_of_week,
    DAYNAME(dt) AS day_name,
    WEEK(dt) AS week_number,
    MONTH(dt) AS month_number,
    MONTHNAME(dt) AS month_name,
    QUARTER(dt) AS calendar_quarter,
    YEAR(dt) AS calendar_year
FROM
    dates;

-- ===========================================================================
-- B) Populate Fact Table with Data 

-- fact_support_tickets
INSERT INTO
    fact_support_tickets(
        ticket_id,
        created_datetime,
        resolution_hours,
        first_response_minutes,
        interaction_count,
        csat_score,
        res_sla_breach,
        fr_sla_breach,
        single_touch_flag,
        date_key,
        agent_key,
        product_key,
        category_key,
        channel_key,
        priority_key,
        status_key,
        country_key,
        tier_key
    )
SELECT
    cdi.`Ticket ID`,
    cdi.`Created DateTime`,
    cdi.`Resolution Hours`,
    cdi.`First Response Minutes`,
    cdi.`Interaction Count`,
    cdi.`CSAT Score`,
    cdi.`Res SLA Breach`,
    cdi.`FR SLA Breach`,
    cdi.`Single Touch Flag`,
    dim_date.date_key,
    dim_agent.agent_key,
    dim_product.product_key,
    dim_category.category_key,
    dim_channel.channel_key,
    dim_priority.priority_key,
    dim_status.status_key,
    dim_country.country_key,
    dim_support_tier.tier_key
FROM
    csv_data_import cdi
    LEFT JOIN dim_date ON DATE(cdi.`Created DateTime`) = dim_date.full_date
    LEFT JOIN dim_agent ON cdi.`Agent Name` = dim_agent.agent_name
    LEFT JOIN dim_product ON cdi.`Product Segment` = dim_product.product_segment
    LEFT JOIN dim_category ON cdi.`Issue Category` = dim_category.issue_category
    LEFT JOIN dim_channel ON cdi.`Support Channel` = dim_channel.support_channel
    LEFT JOIN dim_priority ON cdi.`Priority` = dim_priority.priority_type
    LEFT JOIN dim_status ON cdi.`Status` = dim_status.ticket_status
    LEFT JOIN dim_country ON cdi.`Country` = dim_country.country
    LEFT JOIN dim_support_tier ON cdi.`Support Tier` = dim_support_tier.support_tier;

-- ===============================================================================================

-- BUSINESS QUERIES

-- 1. Which issue categories generate the most completed resolution effort, and what share of overall resolution effort do they represent?					
-- ========================================================================================================================================
SELECT
    dim.issue_category AS `Issue Category`,
    COUNT(fact.ticket_id) AS `Completed Tickets`,
    ROUND(SUM(fact.resolution_hours), 2) AS `Total Resolution Hours`,
    ROUND(
        100 * SUM(fact.resolution_hours) / SUM(SUM(fact.resolution_hours)) OVER(),
        2
    ) AS `Resolution Effort Share %`
FROM
    fact_support_tickets fact
    LEFT JOIN dim_category dim ON fact.category_key = dim.category_key
WHERE
    fact.resolution_hours IS NOT NULL
GROUP BY
    dim.issue_category
ORDER BY
    `Total Resolution Hours` DESC;

-- =============================================================================================================================
-- 2. Which issue categories have the highest SLA breach rates on High-priority tickets, for both First Response and Resolution?
-- =============================================================================================================================
SELECT
    c.issue_category AS `Issue Category`,
    COUNT(fact.fr_sla_breach) AS `High-Priority FR Eligible Tickets`,
    ROUND(100 * AVG(fact.fr_sla_breach), 2) AS `First Response SLA Breach %`,
    COUNT(fact.res_sla_breach) AS `High-Priority Resolution Eligible Tickets`,
    ROUND(100 * AVG(fact.res_sla_breach), 2) AS `Resolution SLA Breach %`
FROM
    fact_support_tickets fact
    LEFT JOIN dim_category c ON fact.category_key = c.category_key
    LEFT JOIN dim_priority p ON fact.priority_key = p.priority_key
WHERE
    p.priority_type = 'High'
GROUP BY
    c.issue_category
ORDER BY
    `Resolution SLA Breach %` DESC,
    `First Response SLA Breach %` DESC;

-- =============================================================================================================================
-- Q3. Which product business units drive the highest ticket volume and total resolution effort?
-- =============================================================================================================================
SELECT
    dim.product_segment AS `Product Segment`,
    COUNT(fact.ticket_id) AS `Total Tickets`,
    ROUND(
        100 * COUNT(fact.ticket_id) / SUM(COUNT(fact.ticket_id)) OVER(),
        2
    ) AS `Ticket Volume Share %`,
    ROUND(SUM(fact.resolution_hours), 2) AS `Total Resolution Hours`,
    ROUND(
        100 * SUM(fact.resolution_hours) / SUM(SUM(fact.resolution_hours)) OVER (),
        2
    ) AS `Resolution Effort Share %`
FROM
    fact_support_tickets fact
    LEFT JOIN dim_product dim ON fact.product_key = dim.product_key
GROUP BY
    dim.product_segment
ORDER BY
    `Ticket Volume Share %` DESC,
    `Resolution Effort Share %` DESC;

-- =============================================================================================================================
-- Q4. Which support tier handles the highest workload complexity based on average resolution time and touchpoints?
-- =============================================================================================================================
SELECT
    dim.support_tier AS `Support Tier`,
    COUNT(fact.ticket_id) AS `Completed Tickets`,
    ROUND(AVG(fact.resolution_hours), 2) AS `Avg Resolution Hours`,
    ROUND(AVG(fact.interaction_count), 2) AS `Avg Interaction Count`
FROM
    fact_support_tickets fact
    LEFT JOIN dim_support_tier dim ON fact.tier_key = dim.tier_key
WHERE
    fact.resolution_hours IS NOT NULL
GROUP BY
    dim.support_tier
ORDER BY
    `Avg Resolution Hours` DESC,
    `Avg Interaction Count` DESC;

-- =============================================================================================================================
-- Q5. Which Support Channels Have the Best Resolution Time, First Response Time and CSAT Performance?
-- =============================================================================================================================
SELECT
    dim.support_channel AS `Support Channel`,
    COUNT(
        CASE
            WHEN fact.resolution_hours IS NOT NULL THEN fact.ticket_id
        END
    ) AS `Completed Tickets`,
    ROUND(AVG(fact.resolution_hours), 2) AS `Avg Resolution Hours`,
    ROUND(AVG(fact.first_response_minutes), 2) AS `Avg FR Minutes`,
    COUNT(fact.csat_score) AS `CSAT Responses`,
    ROUND(AVG(fact.csat_score), 2) AS `Avg CSAT`
FROM
    fact_support_tickets fact
    LEFT JOIN dim_channel dim ON fact.channel_key = dim.channel_key
GROUP BY
    dim.support_channel
ORDER BY
    `Avg Resolution Hours`,
    `Avg FR Minutes`,
    `Avg CSAT` DESC;

-- ================================================================================================================================
-- Q6. Which issue categories achieve the highest FCR rate, using single-touch resolution, and how does FCR relate to average CSAT?
-- =================================================================================================================================
WITH csat_info AS (
    SELECT
        dim.issue_category AS `Issue Category`,
        COUNT(fact.ticket_id) AS `Total Tickets`,
        COUNT(
            CASE
                WHEN fact.single_touch_flag IS NOT NULL THEN fact.ticket_id
            END
        ) AS `FCR Eligible Tickets`,
        SUM(fact.single_touch_flag) AS `Single Touch Tickets`,
        ROUND(100 * AVG(fact.single_touch_flag), 2) AS `FCR Rate %`,
        ROUND(
            AVG(
                CASE
                    WHEN fact.single_touch_flag = 1 THEN fact.csat_score
                END
            ),
            2
        ) AS `Avg CSAT - FCR`,
        ROUND(
            AVG(
                CASE
                    WHEN fact.single_touch_flag = 0 THEN fact.csat_score
                END
            ),
            2
        ) AS `Avg CSAT - Non FCR`
    FROM
        fact_support_tickets fact
        LEFT JOIN dim_category dim ON fact.category_key = dim.category_key
    GROUP BY
        dim.issue_category
)
SELECT
    *,
    `Avg CSAT - FCR` - `Avg CSAT - Non FCR` AS `CSAT Difference`
FROM
    csat_info
ORDER BY
    `FCR Rate %` DESC;

-- =============================================================================================================================
-- 7. Which agents meet or fall below the CSAT KPI target of 60%?
-- =============================================================================================================================
WITH CSAT_info AS(
    SELECT
        dim.agent_name AS `Agent`,
        COUNT(fact.ticket_id) AS `Total Tickets`,
        COUNT(fact.csat_score) AS `CSAT Responses`,
        COUNT(
            CASE
                WHEN fact.csat_score >= 4 THEN fact.csat_score
            END
        ) AS `Satisfied Responses`
    FROM
        fact_support_tickets fact
        LEFT JOIN dim_agent dim ON fact.agent_key = dim.agent_key
    GROUP BY
        dim.agent_name
),
CSAT_percent AS(
    SELECT
        *,
        ROUND(
            100 * `Satisfied Responses` / `CSAT Responses`,
            2
        ) AS `CSAT %`,
        60 AS `CSAT Target`
    FROM
        CSAT_info
)
SELECT
    `Agent`,
    `Total Tickets`,
    `CSAT Responses`,
    `Satisfied Responses`,
    `CSAT %`,
    ROUND(`CSAT %` - `CSAT Target`, 2) AS `Achievement vs Target`,
    CASE
        WHEN `CSAT %` >= `CSAT Target` THEN 'Meets Target'
        ELSE 'Below Target'
    END AS `KPI Status`
FROM
    CSAT_percent
ORDER BY
    `Achievement vs Target` DESC;

-- =============================================================================================================================
-- Q8. How does agent experience level impact resolution speed, CSAT, and SLA compliance?
-- =============================================================================================================================
SELECT
    dim.experience_level AS `Experience Level`,
    ROUND(AVG(fact.resolution_hours), 2) AS `Avg Resolution Hours`,
    ROUND(AVG(fact.csat_score), 2) AS `Avg CSAT`,
    COUNT(fact.fr_sla_breach) AS `FR Eligible Tickets`,
    ROUND(100 * AVG(fact.fr_sla_breach), 2) AS `First Response SLA Breach %`,
    COUNT(fact.res_sla_breach) AS `Resolution Eligible Tickets`,
    ROUND(100 * AVG(fact.res_sla_breach), 2) AS `Resolution SLA Breach %`
FROM
    fact_support_tickets fact
    LEFT JOIN dim_agent dim ON fact.agent_key = dim.agent_key
GROUP BY
    dim.experience_level
ORDER BY
    dim.experience_level;