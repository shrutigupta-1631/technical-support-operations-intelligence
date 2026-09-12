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