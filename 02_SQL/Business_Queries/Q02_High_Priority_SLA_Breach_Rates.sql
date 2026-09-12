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