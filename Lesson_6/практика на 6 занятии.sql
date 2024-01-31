INSERT INTO public.models (id, model, feature, value) 
VALUES(1, 'm1', 'f1', 'v1'),
(2, 'm1', 'f2', 'v2');
INSERT INTO public.models (id, model, feature, value) VALUES(3, 'm2', 'f1', 'v3');
INSERT INTO public.models (id, model, feature, value) VALUES(4, 'm2', 'f2', 'v4');
INSERT INTO public.models (id, model, feature, value) VALUES(5, 'm3', 'f1', 'v5');
INSERT INTO public.models (id, model, feature, value) VALUES(6, 'm3', 'f2', 'v6');
INSERT INTO bookings.aircrafts_data 
(aircraft_code, model, "range")
VALUES
('NEW', '{"new": "new"}', 100);


UPDATE bookings.aircrafts_data
   SET "range" = 200
 WHERE aircraft_code = 'NEW'
;

DELETE FROM 
bookings.aircrafts_data
WHERE 
aircraft_code = 'NEW';






SELECT *
  FROM crosstab(
'select 
	model
	,feature
	,value
   from models
  order by 1,2')
AS models(model text, f1 text, f2 text)
;




SELECT *
  FROM table1
  JOIN (SELECT * FROM table_2 WHERE ...) tt;
  
 
WITH subquery_1 AS (
SELECT * FROM table_2 WHERE ...
),
subquery_2 AS (
SELECT * .FROM t1 JOIN subquery_1..)
SELECT *
  FROM table1
  JOIN (SELECT * FROM table_2 WHERE ...)
 WHERE col_1 IN (SELECT * FROM table_2 WHERE ...)
 (SELECT * FROM table_2 WHERE ...)
 ;
 
 
SELECT abs(-5)
	  ,power(2,2)
	  ,sqrt(4)
	  ,round(2.222222, 2)
	  ,sign(-5)
	  ,least(max(1), max(2), max(3))
	  ,least('a', 'b', 'c')
	  ;
	  
SELECT *
from
(
select 'adsagdsag' AS col_1
UNION all
select 'bdsahds' AS col_1
UNION all
select 'csdahasd' AS col_1
) tt
WHERE col_1 LIKE ('^a')
;


SELECT 
substring('string' from 2 for 3),
replace('string', 's', 'aaa'),
left('2022-04-01', 4),
right('2022-04-01', 2),
lower('ASHGLAHSGHASGH'),
upper('asasgasg'),
length('12512512'),
ltrim(' 1  2  3 test_user_1', '3 21');



SELECT col_1
FROM (
SELECT '%123__125_215%' AS col_1
) tt
WHERE col_1 LIKE '\%%\%'
;


SELECT col_dt
  FROM table_1
 WHERE left(col_dt, 4) = '2024-01-23';
 
 
SELECT '2024' = '2024-01-23';


SELECT lower(author)
  FROM books
 WHERE lower(author) = 'пушкин'
;


SELECT lower('PUSHKIN') AS col_1,
	   lower('пУшКиН') AS col_2,
	   lower('Пушкин') AS col_3;
	   
	  
SELECT ..
  FROM ..
  JOIN ..
    ON col_1 = col_1
   AND COALESCE(col_2, '') = COALESCE(col_2, '')
   
;

select
CASE 
	WHEN col_1 = 1 THEN 'value_1'
	WHEN col_1 = 2 THEN 'value_2'
--	ELSE 'value_3'
END AS case_column
;


SELECT 
	CASE ad."range"::TEXT
		WHEN ad."range"::TEXT = '79%' THEN 'value_1'
	END
FROM bookings.aircrafts_data AS ad
;



WITH top_aircrafts AS (
SELECT ad.aircraft_code
	  ,ad."range"
  FROM bookings.aircrafts_data ad 
 ORDER BY ad."range" DESC
 LIMIT 3
)
SELECT *
  FROM bookings.flights f 
 WHERE f.aircraft_code IN (SELECT aircraft_code FROM top_aircrafts)
 ;


SELECT *
  FROM bookings.flights f 
  LEFT JOIN bookings.ticket_flights tf
   AND f.actual_departure IS NOT NULL 
  ;





