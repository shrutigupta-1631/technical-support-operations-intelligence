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

-- ========================================================
-- Check if our final fact table is correct

/*
SELECT COUNT(*) AS missing_product_keys
FROM fact_support_tickets
WHERE 
    date_key IS NULL
        OR agent_key IS NULL
        OR product_key IS NULL
        OR category_key IS NULL
        OR channel_key IS NULL
        OR priority_key IS NULL
        OR status_key IS NULL
        OR country_key IS NULL
        OR tier_key IS NULL;
 */