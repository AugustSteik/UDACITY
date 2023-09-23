
--1, normal query
SELECT channel, COUNT(*) AS sum, DATE_PART('dow', occurred_at) AS day
 FROM web_events
GROUP BY 1, 3
ORDER BY 1, 3;


--2, inline subquery
SELECT channel, sum, day
FROM
(SELECT channel, COUNT(*) AS sum, DATE_TRUNC('day', occurred_at) AS day
 FROM web_events
GROUP BY 1, 3) sub
GROUP BY channel, sum, day
ORDER BY sum DESC, channel;


--3
SELECT channel,
AVG(sum)
FROM

(SELECT channel, COUNT(*) AS sum, DATE_TRUNC('day', occurred_at) AS day
FROM web_events
GROUP BY 3,1) sub

GROUP BY channel
ORDER BY channel;

-- All correct
