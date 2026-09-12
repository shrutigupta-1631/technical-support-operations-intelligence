-- Q6. Which issue categories achieve the highest FCR rate, using single-touch resolution, and how does FCR relate to average CSAT?
-- =============================================================================================================================

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