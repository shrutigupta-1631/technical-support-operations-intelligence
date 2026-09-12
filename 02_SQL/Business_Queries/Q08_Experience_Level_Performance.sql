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