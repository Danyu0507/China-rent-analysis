-- Validate the cleaned dataset scope.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT city) AS city_count,
    COUNT(DISTINCT type) AS rental_type_count,

    COUNT(*) FILTER (WHERE city = '北京') AS beijing_rows,
    COUNT(*) FILTER (WHERE city = '上海') AS shanghai_rows,
    COUNT(*) FILTER (WHERE city = '广州') AS guangzhou_rows,
    COUNT(*) FILTER (WHERE city = '深圳') AS shenzhen_rows,

    COUNT(*) FILTER (WHERE type = '整租') AS entire_rows,
    COUNT(*) FILTER (WHERE type = '合租') AS shared_rows,

    SUM(
        CASE WHEN is_small_entire
        THEN 1 ELSE 0 END
    ) AS small_entire_rows,

    SUM(
        CASE WHEN is_large_area_conflict
        THEN 1 ELSE 0 END
    ) AS large_area_conflict_rows,

    SUM(
        CASE WHEN is_low_price_entire
        THEN 1 ELSE 0 END
    ) AS low_price_entire_rows,

    SUM(
        CASE
            WHEN is_small_entire
              OR is_large_area_conflict
              OR is_low_price_entire
            THEN 1
            ELSE 0
        END
    ) AS any_existing_anomaly_rows
FROM rent_data;