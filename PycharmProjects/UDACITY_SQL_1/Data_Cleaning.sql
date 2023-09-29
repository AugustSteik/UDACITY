-- LEFT, RIGHT, SUBSTR

--QUIZ
--1
SELECT domain, COUNT(*)
FROM (SELECT right(website, 3) AS domain
      FROM accounts) temp1

      GROUP BY domain
--correct

--2
SELECT letter, COUNT(*)
FROM (SELECT LEFT(name, 1) AS letter
      FROM accounts) temp1

      GROUP BY letter
      ORDER BY letter ASC;
--correct

--3

SELECT LEFT(name, 1) AS char_one,
COUNT(*),
CASE WHEN LEFT(name, 1) ~ '[0-9]' THEN 'number'
ELSE 'letter' END AS char_or_int
FROM accounts

GROUP BY char_one
ORDER BY char_or_int DESC;
--Correct

--4
WITH tt1 AS
(
SELECT COUNT(*), LEFT(name, 1) AS char_one,
CASE WHEN LEFT(name, 1) ~ '[A,a,E,e,I,i,O,o,U,u]'
THEN 'vowel' WHEN LEFT(name, 1) ~ '[0-9]' THEN 'number'
ELSE 'consonant' END AS char_check

FROM accounts
GROUP BY char_check, char_one
)


SELECT char_check, SUM(count)
FROM tt1

GROUP BY char_check
--Correct


--QUIZ CONCAT, SUBSTR ...

--1
SELECT CONCAT(sr.id,'_',reg.name) AS EMP_ID_REGION
FROM sales_reps sr
JOIN region reg
ON reg.id = sr.region_id
--Correct

--2
SELECT a.name, CONCAT(a.lat,a.long) AS coordiante,
CONCAT(LEFT(a.primary_poc, 1),RIGHT(a.primary_poc, 1),'@',a.website) AS email_id
FROM accounts a
--Correct

--3
SELECT CONCAT(a.id,'_', we.channel,'_',COUNT(*))
FROM accounts a
JOIN web_events we
ON a.id = we.account_id
GROUP BY a.id, we.channel

--Not quite:

WITH T1 AS (
    SELECT ACCOUNT_ID, CHANNEL, COUNT(*)
    FROM WEB_EVENTS
    GROUP BY ACCOUNT_ID, CHANNEL
    ORDER BY ACCOUNT_ID
)
SELECT CONCAT(T1.ACCOUNT_ID, '_', T1.CHANNEL, '_', COUNT)
FROM T1;


--CASE quiz

--1
SELECT CONCAT(year,'/',month,'/',day) AS date
FROM (SELECT SUBSTR(date,1,2) AS day,
      SUBSTR(date,4,2) AS month,
      SUBSTR(date,7,4) AS year
     FROM sf_crime_data) tt1

--2
SELECT CAST(CONCAT(year,'-',month,'-',day) AS DATE) AS date

FROM (SELECT SUBSTR(date,1,2) AS month,
      SUBSTR(date,4,2) AS day,
      SUBSTR(date,7,4) AS year
     FROM sf_crime_data) tt1
     --OR:


SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2)) new_date
FROM sf_crime_data;


--Now we can use DATE TRUNC and DATE PART functions


--STRPOS and POSITON

--Quiz
--1

SELECT LEFT(primary_poc,POSITION(' ' IN primary_poc)) AS fist_name,
	   RIGHT(primary_poc,LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) AS last_name

FROM accounts

-- with STRPOS:


SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name,
   RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts;



--2
SELECT LEFT(name,POSITION(' ' IN name)) AS fist_name,
	   RIGHT(name,LENGTH(name)-POSITION(' ' IN name)) AS last_name

FROM sales_reps

--again:


SELECT LEFT(name, STRPOS(name, ' ') -1 ) first_name,
          RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) last_name
FROM sales_reps;

--STRPOS and POSITION return the same value in this case


--CONCAT quiz

--1
SELECT CONCAT(first_name,'.',last_name,'@',name,'.com')
FROM (SELECT
      LEFT(primary_poc, POSITION(' ' IN primary_poc)-1) AS first_name,
      RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) AS last_name,
      name
      FROM accounts) tt1
--good

--2
SELECT CONCAT(first_name,'.',last_name,'@',namea,'.com')
FROM (SELECT
      LEFT(primary_poc, POSITION(' ' IN primary_poc)-1) AS first_name,
      RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) AS last_name,

      CASE WHEN POSITION(' ' IN name) != 0 THEN OVERLAY(name PLACING '' FROM POSITION(' ' IN name) FOR 1)
      END AS namea

      FROM accounts) tt1
--Similar as q3

--3

SELECT lower(fl1) || lower(ll1) || lower(fl2) || lower(ll2) || nochars1 || nochars2 || UPPER(coname) AS password,
conamee,
primary_poc
FROM (SELECT
      LEFT(primary_poc,1) AS fl1,
      RIGHT(primary_poc,1) AS ll2,
      SUBSTR(primary_poc, POSITION(' ' IN primary_poc)-1, 1) AS ll1,
      SUBSTR(primary_poc, POSITION(' ' IN primary_poc)+1, 1) AS fl2,
      POSITION(' ' IN primary_poc)-1 AS nochars1,

      CASE WHEN POSITION(' ' IN name) != 0 THEN OVERLAY(name PLACING '' FROM POSITION(' ' IN name) FOR 1) END AS coname,
      LENGTH(primary_poc)-POSITION(' ' IN primary_poc) AS nochars2,
      name AS conamee,
      primary_poc

      FROM accounts) tt1
--Nearly, but overcomplicated... Use: REPLACE(UPPER(name), ' ', '')
-- Solution:
WITH t1 AS (
    SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,
    RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name,
    name
    FROM accounts)
    SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'),
    LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;

--COALESCE

--1
SELECT COALESCE(o.account_id, a.id) AS id
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

--2
SELECT *, COALESCE(o.standard_qty,0) AS stdq,
COALESCE(o.gloss_qty,0) AS glossq,
COALESCE(o.poster_qty,0) AS posterq,
COALESCE(o.total,0) AS totalq,
COALESCE(o.standard_amt_usd,0) AS stdusd,
COALESCE(o.gloss_amt_usd,0) AS glossusd,
COALESCE(o.poster_amt_usd,0) AS posterusd,
COALESCE(o.total_amt_usd, 0) AS totalusd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

--3
SELECT COALESCE(o.account_id, a.id) AS id, COALESCE(o.standard_qty,0) AS stdq,
COALESCE(o.gloss_qty,0) AS glossq,
COALESCE(o.poster_qty,0) AS posterq,
COALESCE(o.total,0) AS totalq,
COALESCE(o.standard_amt_usd,0) AS stdusd, COALESCE(o.gloss_amt_usd,0) AS glossusd,
COALESCE(o.poster_amt_usd,0) AS posterusd,
COALESCE(o.total_amt_usd, 0) AS totalusd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;

