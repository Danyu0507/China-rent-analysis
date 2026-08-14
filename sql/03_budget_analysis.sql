-- Rank districts by entire-rental availability under CNY 5,000.
WITH budget_scope AS (
    SELECT
        city,
        dist,
        rent_price_num
    FROM rent_data
    WHERE type = '整租'
      AND NOT (
          is_small_entire
          OR is_large_area_conflict
          OR is_low_price_entire
      )
),

city_budget AS (
    SELECT
        city,
        COUNT(*) AS analysis_rows,
        COUNT(*) FILTER (
            WHERE rent_price_num <= 5000
        ) AS budget_rows
    FROM budget_scope
    GROUP BY city
),

district_budget AS (
    SELECT
        city,
        dist,
        COUNT(*) AS district_analysis_rows,
        COUNT(*) FILTER (
            WHERE rent_price_num <= 5000
        ) AS district_budget_rows
    FROM budget_scope
    GROUP BY
        city,
        dist
),

district_metrics AS (
    SELECT
        city,
        dist,
        district_analysis_rows,
        district_budget_rows,
        ROUND(
            district_budget_rows * 100.0
            / district_analysis_rows,
            2
        ) AS district_budget_share_pct
    FROM district_budget
),

ranked_districts AS (
    SELECT
        city,
        dist,
        district_analysis_rows,
        district_budget_rows,
        district_budget_share_pct,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY
                district_budget_rows DESC,
                district_budget_share_pct DESC,
                dist
        ) AS city_district_rank
    FROM district_metrics
)

SELECT
    ranked_districts.city,
    city_budget.analysis_rows AS city_analysis_rows,
    city_budget.budget_rows AS city_budget_rows,
    ROUND(
        city_budget.budget_rows * 100.0
        / city_budget.analysis_rows,
        2
    ) AS city_budget_share_pct,
    ranked_districts.dist,
    ranked_districts.district_analysis_rows,
    ranked_districts.district_budget_rows,
    ranked_districts.district_budget_share_pct,
    ranked_districts.city_district_rank
FROM ranked_districts
JOIN city_budget
    USING (city)
ORDER BY
    ranked_districts.city,
    ranked_districts.city_district_rank,
    ranked_districts.dist;