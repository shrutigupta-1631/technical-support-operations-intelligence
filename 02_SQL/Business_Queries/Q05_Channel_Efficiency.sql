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