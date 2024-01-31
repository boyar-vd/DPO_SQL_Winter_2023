CREATE TABLE public.first_table (
id int4,
second_column text
);

CREATE OR REPLACE VIEW v_aircrafts_data AS 
SELECT ad.aircraft_code, "range"
  FROM bookings.aircrafts_data ad
;

CREATE MATERIALIZED VIEW mv_aircrafts_data AS 
SELECT ad.aircraft_code, "range"
  FROM bookings.aircrafts_data ad
;

SELECT *
  FROM 

SELECT *
  FROM bookings.mv_aircrafts_data;
  
REFRESH MATERIALIZED VIEW bookings.mv_aircrafts_data;


--На основе загруженных данных создадим представление:
--Наименование товара
--Текущая стоимость товара (последняя из имеющихся данных)
--Минимальная стоимость товара
--Среднегодовая стоимость товара
--Среднемесячная стоимость товара
--Макисмальная стоимость товара

--CREATE OR REPLACE VIEW public.v_goods AS

CREATE TEMP TABLE digit_months (
"month" TEXT,
"number" int2
)
;

INSERT INTO digit_months
("month", "number")
VALUES
('январь', 1),
('февраль', 2),
('март', 3),
('апрель', 4),
('май', 5),
('июнь', 6),
('июль', 7),
('август', 8),
('сентябрь', 9),
('октябрь', 10),
('ноябрь', 11),
('декабрь', 12);

SELECT * FROM digit_months;

UPDATE public.goods
   SET value = replace(value, ',', '.');

WITH max_min_value AS (
SELECT product
	  ,min(value)
	  ,max(value)
  FROM public.goods
 GROUP BY product
)
SELECT tt."Продукты"
	  ,tt.value AS "Текущая стоимость товара"
	  ,mmv."min" AS "Минимальная стоимость"
	  ,mmv."max" AS "Максимальная стоимость"
FROM (
SELECT product AS "Продукты"
	  ,g.*
	  ,dm."number"
	  ,ROW_NUMBER() over(PARTITION BY g.product ORDER BY g."year" DESC, dm."number" DESC) AS rn
  FROM public.goods g
  JOIN digit_months dm ON g."month" = dm."month"
-- WHERE product = 'Фарш мясной, кг'
) tt
JOIN max_min_value mmv ON tt.product = mmv.product
WHERE tt.rn = 1
;