
select * --Selects all rows from both tables
from accounts
join orders
on orders.id = accounts.id; -- Where id from orders == id from accounts




-- Notice the order of the columns dictates the order at which they
-- will be displayed.


select r.name RN, sr.*
from region r -- If we do this we must change the table names in the SELECT
join sales_reps sr
on r.id = sr.region_id;


-- Selecting data across tables for Walmart

select a.name,
web_events.channel,
a.primary_poc

from accounts a
join web_events --reversed
on a.id = web_events.account_id --reversed

where a.name in ('Walmart');


-- Joining 3 tables
select region.name Region_Name,
sales_reps.name Rep,
accounts.name Account -- If they are all left as 'name', it doesn't work well

from region
join sales_reps -- reversed
on region.id = sales_reps.region_id

join accounts
on sales_reps.id = accounts.sales_rep_id -- They seem to have these reversed in the answers i.e. FK = PK

order by accounts.name;


--Nice

select region.name Region,
accounts.name Account,
round(orders.total_amt_usd/(orders.total+0.01), 1) as Unit_Price

      from region -- Yes
      join sales_reps -- Yes
      on region.id = sales_reps.region_id

      join accounts -- Yes
      on sales_reps.id = accounts.sales_rep_id

      join orders -- Yes
      on accounts.id = orders.account_id -- all reversed

      order by Account
--correct


-----------------------------
-- Other Joins---------------
-----------------------------

--Quiz

--1)
SELECT region.name RegionName,
sales_reps.name SalesRepName,
accounts.name AccountName

FROM accounts
JOIN sales_reps
ON sales_reps.id = accounts.sales_rep_id

JOIN region
ON region.id = sales_reps.region_id
WHERE region.name = 'Midwest'

ORDER BY AccountName;

--2)
SELECT region.name RegionName,
sales_reps.name SalesRepName,
accounts.name AccountName

FROM accounts
JOIN sales_reps
ON sales_reps.id = accounts.sales_rep_id

JOIN region
ON region.id = sales_reps.region_id
WHERE region.name = 'Midwest' AND
sales_reps.name LIKE 'S%'

ORDER BY AccountName;

--3)
SELECT region.name RegionName,
sales_reps.name SalesRepName,
accounts.name AccountName

FROM accounts
JOIN sales_reps
ON sales_reps.id = accounts.sales_rep_id

JOIN region
ON region.id = sales_reps.region_id
WHERE region.name = 'Midwest' AND
sales_reps.name LIKE '%K%'

ORDER BY AccountName;\

--4)
SELECT region.name region_name,
accounts.name accounts_name,
round((orders.total_amt_usd/(orders.total)),1) unit_price

FROM orders
JOIN accounts
ON accounts.id = orders.account_id

JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id

JOIN region
ON region.id = sales_reps.region_id

WHERE orders.standard_qty > 100
AND orders.total != 0
ORDER BY unit_price;

--5, 6)
SELECT region.name region_name,
accounts.name accounts_name,
round((orders.total_amt_usd/(orders.total)),1) unit_price

FROM orders
JOIN accounts
ON accounts.id = orders.account_id

JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id

JOIN region
ON region.id = sales_reps.region_id

WHERE (orders.standard_qty > 100)
AND (orders.poster_qty > 50)
AND (orders.total != 0)
ORDER BY unit_price;
--correct i think, they used different order:

--FROM region r
--JOIN sales_reps s
--ON s.region_id = r.id
--JOIN accounts a
--ON a.sales_rep_id = s.id
--JOIN orders o
--ON o.account_id = a.id

--7)
SELECT DISTINCT accounts.name, -- This omits the repeating rows according to the channel column.
web_events.channel

FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id

WHERE accounts.id = 1001;
--correct

--8)
SELECT orders.occurred_at timee,
accounts.name,
orders.total,
orders.total_amt_usd

FROM accounts
JOIN orders
ON accounts.id = orders.account_id

WHERE orders.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
--WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016' also works
ORDER BY orders.occurred_at;--DESC
--correct

