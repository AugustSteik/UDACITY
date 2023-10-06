
-- Creating a view containing all data in 1 table:
CREATE OR REPLACE VIEW forestation
AS (
SELECT fa.*,
	   la.total_area_sq_mi*2.59 AS land_area_sqkm,
	   r.region,
	   r.income_group,
       100*(fa.forest_area_sqkm/(la.total_area_sq_mi*2.59)) AS percent_forest
    FROM forest_area fa
    JOIN land_area la ON fa.country_code = la.country_code
    AND fa.year = la.year
    JOIN regions r ON r.country_code = la.country_code
    WHERE forest_area_sqkm IS NOT NULL
    AND la.total_area_sq_mi IS NOT NULL);

------------------------------------------------------------------------------
-- 1 - Global Situation

-- Query 1.1
-- Finding the total forest area of the world in 1990:
SELECT country_name, forest_area_sqkm
     FROM forestation
     WHERE country_name = 'World'
     AND year = '1990'

-- Query 1.2
-- Finding the total forest area of the world in 2016:
SELECT country_name, forest_area_sqkm
     FROM forestation
     WHERE country_name = 'World'
     AND year = '2016'
--39958245.9- 41282694.9 = -1,324,449sqkm

-- Query 1.3
WITH tt1 AS(
SELECT country_name, forest_area_sqkm
     FROM forestation
     WHERE country_name = 'World'
     AND year = '2016'),

tt2 AS(
SELECT country_name, forest_area_sqkm
     FROM forestation
     WHERE country_name = 'World'
     AND year = '1990'),

tt3 AS(
SELECT tt1.forest_area_sqkm - tt2.forest_area_sqkm AS forest_area_loss,
       (100*(tt1.forest_area_sqkm - tt2.forest_area_sqkm)/tt2.forest_area_sqkm) AS percentage_change
     FROM tt1
     JOIN tt2 ON tt1.country_name = tt2.country_name)

-- Use the subqueries above with either 1.3.a or 1.3.b to answer different parts of the question

-- Query 1.3.a
-- Global forest area decrease from 1990 to 2016 as the area in km^2 and a percentage:
SELECT tt1.forest_area_sqkm - tt2.forest_area_sqkm AS forest_area_loss,
       (100*(tt1.forest_area_sqkm - tt2.forest_area_sqkm)/tt2.forest_area_sqkm) AS percentage_change
     FROM tt1
     JOIN tt2 ON tt1.country_name = tt2.country_name;

-- Query 1.3.b
-- Identifying the country with the total land area just below
-- the area of forest lost globally from 1990 to 2016:
SELECT  country_name,
        land_area_sqkm
     FROM forestation
     WHERE land_area_sqkm <= (SELECT -1*(forest_area_loss) FROM tt3)
     AND year = '2016'
     ORDER BY land_area_sqkm DESC
     LIMIT 1;

------------------------------------------------------------------------------
-- 2 - Regional Outlook

-- Query 2.1
-- Percentage forest area by region for 1990:
--SELECT region,
--       100*(SUM(forest_area_sqkm)/SUM(land_area_sqkm)) AS percent_forest
--    FROM forestation
--    WHERE year = '1990'
--    AND forest_area_sqkm IS NOT NULL
--    AND land_area_sqkm IS NOT NULL
--    GROUP BY region
--    ORDER BY percent_forest DESC;
--
---- Query 2.2
---- Percentage forest area by region for 2016:
--SELECT region,
--       100*(SUM(forest_area_sqkm)/SUM(land_area_sqkm)) AS percent_forest
--    FROM forestation
--    WHERE year = '2016'
--    AND forest_area_sqkm IS NOT NULL
--    AND land_area_sqkm IS NOT NULL
--    GROUP BY region
--    ORDER BY percent_forest DESC;

SELECT tt1.region,
       AVG(tt1.percent_forest) AS old_data,
       AVG(tt2.percent_forest) AS new_data
FROM forestation tt1
JOIN forestation tt2 ON tt1.country_name = tt2.country_name
WHERE tt1.year = '1990'
AND tt2.year = '2016'
GROUP BY tt1.region
ORDER BY tt1.region ASC;

------------------------------------------------------------------------------
-- 3 - Country-Level Detail

-- Query 3.1
SELECT tt1.country_name,
       tt1.region,
       tt1.forest_area_sqkm AS old_data,
       tt2.forest_area_sqkm AS new_data
FROM forestation tt1
JOIN forestation tt2 ON tt1.country_name = tt2.country_name
WHERE tt1.year = '1990'
AND tt2.year = '2016'
ORDER BY tt1.country_name ASC


-- Query 3.2
 --Finding the forest area change as a percentage for each country:


SELECT tt1.country_name,
       tt1.region,
      100*(tt2.forest_area_sqkm - tt1.forest_area_sqkm)/tt1.forest_area_sqkm AS percentage_change
FROM forestation tt1
JOIN forestation tt2 ON tt1.country_name = tt2.country_name
WHERE tt1.year = '1990'
AND tt2.year = '2016'
    AND tt1.forest_area_sqkm IS NOT NULL
    AND tt2.forest_area_sqkm IS NOT NULL
ORDER BY percentage_change DESC;

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
    AND country_name NOT LIKE 'World') ranking

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
    ) ranking

    WHERE quartile = 4
    ORDER BY percent_forest DESC;
