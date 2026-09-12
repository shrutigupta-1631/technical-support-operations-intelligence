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