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