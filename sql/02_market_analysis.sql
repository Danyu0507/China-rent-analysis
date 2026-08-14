-- Compare city-level pricing for entire rentals.
WITH city_pricing AS (
    SELECT
        city,
        COUNT(*) AS entire_rows,
        ROUND(AVG(rent_price_num), 2) AS avg_monthly_rent,
        MEDIAN(rent_price_num) AS median_monthly_rent,
        ROUND(
            MEDIAN(rent_price_per_sqm),
            2
        ) AS median_rent_per_sqm
    FROM rent_data
    WHERE type = '整租'
    GROUP BY city
),

-- Build the same relationship-analysis scope used in Pandas.
relationship_scope AS (
    SELECT
        city,
        rent_area_num,
        rent_price_num
    FROM rent_data
    WHERE type = '整租'
      AND NOT (
          is_small_entire
          OR is_large_area_conflict
          OR is_low_price_entire
      )
),

city_correlation AS (
    SELECT
        city,
        COUNT(*) AS relationship_rows,
        ROUND(
            CORR(rent_area_num, rent_price_num),
            3
        ) AS city_area_rent_corr
    FROM relationship_scope
    GROUP BY city
),

overall_correlation AS (
    SELECT
        ROUND(
            CORR(rent_area_num, rent_price_num),
            3
        ) AS overall_area_rent_corr
    FROM relationship_scope
)

SELECT
    city_pricing.city,
    city_pricing.entire_rows,
    city_pricing.avg_monthly_rent,
    city_pricing.median_monthly_rent,
    city_pricing.median_rent_per_sqm,
    city_correlation.relationship_rows,
    city_correlation.city_area_rent_corr,
    overall_correlation.overall_area_rent_corr
FROM city_pricing
JOIN city_correlation
    USING (city)
CROSS JOIN overall_correlation
ORDER BY
    city_pricing.median_monthly_rent DESC,
    city_pricing.city;