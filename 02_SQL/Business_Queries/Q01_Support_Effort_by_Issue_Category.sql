-- 1. Which issue categories generate the most completed resolution effort, and what share of overall resolution effort do they represent?					
-- =============================================================================================================================

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