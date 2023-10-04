------------------------------------------------------------------------------

--tt3 AS(
--SELECT tt1.forest_area_sqkm - tt2.forest_area_sqkm AS forest_area_loss, (100*(tt1.forest_area_sqkm - tt2.forest_area_sqkm)/tt2.forest_area_sqkm) AS percentage_change
--         FROM tt1
--         JOIN tt2 ON tt1.country_name = tt2.country_name)

--SELECT  country_name,
--         land_area_sqkm
--         FROM forestation
--         WHERE land_area_sqkm <= (SELECT -1*(forest_area_loss) FROM tt3)
--         AND year = '2016'
--         ORDER BY land_area_sqkm DESC
--         LIMIT 1;
------------------------------------------


--SELECT year, country_name,land_area_sqkm
--         FROM forestation
--         WHERE year = '2016'
--         AND land_area_sqkm <= --2191039
--         ORDER BY land_area_sqkm DESC
--         LIMIT 1;











--WITH tt1 AS (
--SELECT country_name,
--  forest_area_sqkm
--    FROM forestation
--    WHERE year = '2016'
--    AND forest_area_sqkm IS NOT NULL
--    ORDER BY percent_forest DESC),
--
--tt2 AS (
--SELECT country_name, forest_area_sqkm
--    FROM forestation
--    WHERE year = '1990'
--    AND forest_area_sqkm IS NOT NULL
--    ORDER BY percent_forest DESC)
--
--SELECT tt1.country_name, tt1.forest_area_sqkm - tt2.forest_area_sqkm AS forest_area_change
--    FROM tt1
--    JOIN tt2 ON tt1.country_name = tt2.country_name
--    ORDER BY forest_area_change DESC;

------------------------------------------

--WITH tt1 AS (
--SELECT country_name,
--   100*(forest_area_sqkm/land_area_sqkm) AS percent_forest
--    FROM forestation
--    WHERE year = '2016'
--    AND forest_area_sqkm IS NOT NULL
--    AND land_area_sqkm IS NOT NULL
--    ORDER BY percent_forest DESC),
--
--tt2 AS (
--SELECT country_name,
--    100*(forest_area_sqkm/land_area_sqkm) AS percent_forest
--    FROM forestation
--    WHERE year = '1990'
--    AND forest_area_sqkm IS NOT NULL
--    AND land_area_sqkm IS NOT NULL
--    ORDER BY percent_forest DESC)
--
--SELECT tt1.country_name, tt1.percent_forest - tt2.percent_forest AS forest_area_percentage_change
--    FROM tt1
--    JOIN tt2 ON tt1.country_name = tt2.country_name
--    ORDER BY forest_area_percentage_change DESC;
---------------------------------------------

--------------------HMM
--WITH tt1 AS (
--SELECT country_name,
--  	region,
--    100*(forest_area_sqkm/land_area_sqkm) AS percent_forest
--    FROM forestation
--    WHERE year = '2016'
--    AND forest_area_sqkm IS NOT NULL
--    AND land_area_sqkm IS NOT NULL
--    ORDER BY percent_forest DESC),
--
--tt2 AS (
--SELECT country_name,
--    100*(forest_area_sqkm/land_area_sqkm) AS percent_forest
--    FROM forestation
--    WHERE year = '1990'
--    AND forest_area_sqkm IS NOT NULL
--    AND land_area_sqkm IS NOT NULL
--    ORDER BY percent_forest DESC)
--
--SELECT tt1.country_name, tt1.region, tt1.percent_forest - tt2.percent_forest AS forest_area_percentage_change
--    FROM tt1
--    JOIN tt2 ON tt1.country_name = tt2.country_name
--    ORDER BY forest_area_percentage_change ASC;
------------------------------------------------------------------------------






------------------------------------------------------------------------------

---------QUARTILES
--WITH tt1 AS(
--SELECT country_name,
--	region,
--    percent_forest,
--	NTILE(4) OVER (ORDER BY percent_forest) AS quartile
--FROM(SELECT country_name,
--    region,
--    100*(forest_area_sqkm/land_area_sqkm) AS percent_forest
--    FROM forestation
--    WHERE year = '2016'
--    AND forest_area_sqkm IS NOT NULL
--    AND land_area_sqkm IS NOT NULL
--    ORDER BY percent_forest DESC) tt1
--
--   ORDER BY quartile DESC, percent_forest DESC)
--
--   SELECT quartile, COUNT(*)
--   FROM tt1
--   GROUP BY quartile
--   ORDER BY quartile;
--NTILE(4) OVER (PARTITION BY country_name ORDER BY percent_forest) AS quartile

--WITH num_rows AS (
--SELECT COUNT(*)
--FROM forestation
--        WHERE year = '2016'
--    	AND forest_area_sqkm IS NOT NULL
--    	AND land_area_sqkm IS NOT NULL
--    )--,

--tt2 AS(

------------------------------------------------------------------------------