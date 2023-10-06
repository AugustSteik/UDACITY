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






------------------------1st try:

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
    JOIN regions r ON r.country_code = la.country_code);

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
SELECT tt1.forest_area_sqkm - tt2.forest_area_sqkm AS forest_area_loss, (100*(tt1.forest_area_sqkm - tt2.forest_area_sqkm)/tt2.forest_area_sqkm) AS percentage_change
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
SELECT region,
       100*(SUM(forest_area_sqkm)/SUM(land_area_sqkm)) AS percent_forest
    FROM forestation
    WHERE year = '1990'
    AND forest_area_sqkm IS NOT NULL
    AND land_area_sqkm IS NOT NULL
    GROUP BY region
    ORDER BY percent_forest DESC;

-- Query 2.2
-- Percentage forest area by region for 2016:
SELECT region,
       100*(SUM(forest_area_sqkm)/SUM(land_area_sqkm)) AS percent_forest
    FROM forestation
    WHERE year = '2016'
    AND forest_area_sqkm IS NOT NULL
    AND land_area_sqkm IS NOT NULL
    GROUP BY region
    ORDER BY percent_forest DESC;

------------------------------------------------------------------------------
-- 3 - Country-Level Detail

-- Query 3.1
-- Finding the forest area change for all countries in km^2:
WITH tt1 AS (
SELECT country_name,
  	   region,
       forest_area_sqkm,
  	   land_area_sqkm
    FROM forestation
    WHERE year = '2016'
    AND forest_area_sqkm IS NOT NULL
    AND land_area_sqkm IS NOT NULL
    ),

tt2 AS (
SELECT country_name,
  	   region,
       forest_area_sqkm,
  	   land_area_sqkm
    FROM forestation
    WHERE year = '1990'
    AND forest_area_sqkm IS NOT NULL
    AND land_area_sqkm IS NOT NULL
    )

SELECT tt1.country_name, tt1.region, (tt1.forest_area_sqkm - tt2.forest_area_sqkm) AS forest_area_change
    FROM tt1
    JOIN tt2 ON tt1.country_name = tt2.country_name
    ORDER BY forest_area_change ASC;


-- Query 3.2
-- Finding the forest area change as a percentage for each country:
WITH tt1 AS (
SELECT country_name,
  	   region,
       forest_area_sqkm,
  	   land_area_sqkm
    FROM forestation
    WHERE year = '2016'
    AND forest_area_sqkm IS NOT NULL
    AND land_area_sqkm IS NOT NULL
    ),

tt2 AS (
SELECT country_name,
  	   region,
       forest_area_sqkm,
  	   land_area_sqkm
    FROM forestation
    WHERE year = '1990'
    AND forest_area_sqkm IS NOT NULL
    AND land_area_sqkm IS NOT NULL
    )

SELECT tt1.country_name, tt1.region,
       100*((tt1.forest_area_sqkm - tt2.forest_area_sqkm)/tt2.forest_area_sqkm) AS forest_area_percentage_change
    FROM tt1
    JOIN tt2 ON tt1.country_name = tt2.country_name
    ORDER BY forest_area_percentage_change ASC;

-- Query 3.3
-- 3.C
WITH ranked_table AS
(
SELECT country_name,
	region,
    percent_forest,
	CASE
	    WHEN ranking >= 0.75*max_rank THEN 1
	    WHEN ranking < 0.75*max_rank AND ranking >=0.5*max_rank THEN 2
	    WHEN ranking < 0.5*max_rank AND ranking >=0.25*max_rank THEN 3
	    ELSE 4
	    END AS quartile

    FROM    (SELECT country_name,
            region,land_area_sqkm,forest_area_sqkm,
            100*(forest_area_sqkm/land_area_sqkm) AS percent_forest,
            ROW_NUMBER() OVER (ORDER BY 100*(forest_area_sqkm/land_area_sqkm)) AS ranking,

            (SELECT COUNT(*) FROM forestation WHERE year = '2016'
            AND forest_area_sqkm IS NOT NULL
            AND land_area_sqkm IS NOT NULL) AS max_rank

                FROM forestation
                WHERE year = '2016'
                AND forest_area_sqkm IS NOT NULL
                AND land_area_sqkm IS NOT NULL
            ) tt1
)

-- Use the subqueries above with either 3.3.a or 3.3.b to answer different parts of the question

-- Query 3.3.a
-- Finding number of countries in each quartile:
SELECT quartile,
       COUNT(*)
    FROM ranked_table
    GROUP BY quartile
    ORDER BY quartile ASC;

-- Query 3.3.b
-- Displaying the country names, their respective region and forest coverage
-- for all countries in the TOP quartile:
SELECT country_name,
       region,
       percent_forest
    FROM ranked_table
    WHERE quartile = 1
    ORDER BY percent_forest DESC;
