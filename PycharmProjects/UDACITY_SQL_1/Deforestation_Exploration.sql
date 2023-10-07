
-- Creating a view containing all data in 1 table:
CREATE OR REPLACE VIEW forestation
AS (
SELECT fa.*,
	   la.total_area_sq_mi*2.59 AS land_area_sqkm,
	   r.region,
	   r.income_group,
       100*(fa.forest_area_sqkm/(la.total_area_sq_mi*2.59)) AS percent_forest
    FROM forest_area fa
    FULL OUTER JOIN land_area la ON fa.country_code = la.country_code
    AND fa.year = la.year
    JOIN regions r ON r.country_code = la.country_code);

------------------------------------------------------------------------------
-- 1 - Global Situation

-- Query 1.1
-- Comparing global forest area data from 1990 to 2016:
SELECT *,100*(new_forest_area-old_forest_area)/old_forest_area AS global_fa_change_pc,
new_forest_area - old_forest_area AS global_fa_change_km
FROM (
SELECT tt1.country_name,
tt2. forest_area_sqkm AS old_forest_area,
tt1.forest_area_sqkm AS new_forest_area
       FROM forestation tt1
       JOIN forestation tt2 ON tt1.country_name = tt2.country_name
       WHERE tt1.country_name = 'World'
       AND tt1.year = '2016'
       AND tt2.year = '1990'
       AND tt1.forest_area_sqkm IS NOT NULL
       AND tt2.forest_area_sqkm IS NOT NULL) global_forest_area

-- Query 1.2
-- Identifying the country with the total land area just below
-- the area of forest lost globally from 1990 to 2016:
SELECT  country_name,
        land_area_sqkm
     FROM forestation
     WHERE land_area_sqkm <= (
     SELECT ABS(tt1.forest_area_sqkm - tt2.forest_area_sqkm) AS forest_area_loss
           FROM forestation tt1
           JOIN forestation tt2 ON tt1.country_name = tt2.country_name
           WHERE tt1.country_name = 'World'
           AND tt1.year = '2016'
           AND tt2.year = '1990'
           AND tt1.forest_area_sqkm IS NOT NULL
           AND tt2.forest_area_sqkm IS NOT NULL)
     AND year = '2016'
     ORDER BY land_area_sqkm DESC
     LIMIT 1;


------------------------------------------------------------------------------
-- 2 - Regional Outlook

-- 2.1
-- Percent forest area for each region:
SELECT tt1.region,
       100*SUM(tt1.forest_area_sqkm)/SUM(tt1.land_area_sqkm) AS old_percent_forest,
       100*SUM(tt2.forest_area_sqkm)/SUM(tt2.land_area_sqkm) AS new_percent_forest
FROM forestation tt1
JOIN forestation tt2 ON tt1.country_name = tt2.country_name
WHERE tt1.year = '1990'
AND tt2.year = '2016'
AND tt1.forest_area_sqkm IS NOT NULL AND tt1.land_area_sqkm IS NOT NULL
AND tt2.forest_area_sqkm IS NOT NULL AND tt2.land_area_sqkm IS NOT NULL

GROUP BY tt1.region
ORDER BY old_percent_forest DESC;


------------------------------------------------------------------------------
-- 3 - Country-Level Detail

--3.A and 3.B

-- Query 3.1
-- Finding the forest area change in sqkm for each country:
SELECT country_name,
    region,
    new_data-old_data AS forest_area_change_sqkm
FROM(
    SELECT tt1.country_name,
           tt1.region,
           tt1.forest_area_sqkm AS old_data,
           tt2.forest_area_sqkm AS new_data
    FROM forestation tt1
    JOIN forestation tt2 ON tt1.country_name = tt2.country_name
    WHERE tt1.year = '1990'
    AND tt2.year = '2016'
        AND tt1.forest_area_sqkm IS NOT NULL
        AND tt2.forest_area_sqkm IS NOT NULL
        AND tt1.country_name NOT LIKE 'World') self_join

ORDER by forest_area_change_sqkm ASC;


-- Query 3.2
-- Finding the forest area change as a percentage for each country:

SELECT tt1.country_name,
       tt1.region,
      100*(tt2.forest_area_sqkm - tt1.forest_area_sqkm)/tt1.forest_area_sqkm AS percentage_change
FROM forestation tt1
JOIN forestation tt2 ON tt1.country_name = tt2.country_name
WHERE tt1.year = '1990'
AND tt2.year = '2016'
    AND tt1.forest_area_sqkm IS NOT NULL
    AND tt2.forest_area_sqkm IS NOT NULL
    AND tt1.country_name NOT LIKE 'World'
    ORDER BY percentage_change ASC;


-- 3.C

-- Query 3.3
-- Finding number of countries in each quartile:
SELECT quartile,
       COUNT(*)
FROM(
SELECT country_name,
	region,
    percent_forest,
	CASE
	    WHEN percent_forest > 75 AND percent_forest <=100 THEN 4
	    WHEN percent_forest > 50 AND percent_forest <= 75 THEN 3
	    WHEN percent_forest > 25 AND percent_forest <= 50 THEN 2
	    WHEN percent_forest >= 0 AND percent_forest <=25 THEN 1
	    END AS quartile
    FROM forestation
    WHERE year = '2016'
    AND country_name NOT LIKE 'World'
    AND forest_area_sqkm IS NOT NULL
    AND land_area_sqkm IS NOT NULL) ranking

    GROUP BY quartile
    ORDER BY quartile DESC;

-- Query 3.4
-- Displaying the country names, their respective region and forest coverage
-- for all countries in the TOP quartile:
SELECT country_name,
       region,
       percent_forest
FROM(
SELECT country_name,
	region,
    percent_forest,
	CASE
	    WHEN percent_forest > 75 AND percent_forest <=100 THEN 4
	    WHEN percent_forest > 50 AND percent_forest <= 75 THEN 3
	    WHEN percent_forest > 25 AND percent_forest <= 50 THEN 2
	    WHEN percent_forest >= 0 AND percent_forest <=25 THEN 1
	    END AS quartile
    FROM forestation
    WHERE year = '2016'
    AND country_name NOT LIKE 'World'
    AND forest_area_sqkm IS NOT NULL
    AND land_area_sqkm IS NOT NULL
    ) ranking

    WHERE quartile = 4
    ORDER BY percent_forest DESC;
