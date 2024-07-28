-- !ВАЖНО
-- Если планируете запускать запросы, то нажмите ctr+f 
-- и замените "public." на название своей схемы


-- Создадим таблицу для экспериментов и заполним её данными
DROP TABLE IF EXISTS public.ticket_flights_copy;

CREATE TABLE public.ticket_flights_copy
 (LIKE bookings.ticket_flights);
 
INSERT INTO public.ticket_flights_copy
SELECT * FROM bookings.ticket_flights;


-- Посмотрим кол-во записей в созданной таблице
 SELECT count(*)
   FROM public.ticket_flights_copy;

  
-- Сделаем запрос на поиск данных по перелету с идентификатором 130525
EXPLAIN ANALYZE
 SELECT * 
   FROM public.ticket_flights_copy tfc
  WHERE tfc.flight_id = 130525;
  
 
-- Попробуем использовать нечеткий поиск, посмотрим как изменлось время выполнения запроса
EXPLAIN ANALYZE 
 SELECT * 
   FROM public.ticket_flights_copy tfc
  WHERE tfc.flight_id::text like '%130525%';
  
 
-- Создадим индекс на поле bookings.ticket_flights_copy.flight_id
DROP INDEX IF EXISTS ticket_flights_copy_flight_id_index;

CREATE INDEX ticket_flights_copy_flight_id_index 
          ON public.ticket_flights_copy (flight_id);
          
         
-- Выполним запросы после создания индекса, сравним время выполнения с предыдущими результатом
EXPLAIN ANALYZE
 SELECT * 
   FROM public.ticket_flights_copy tfc
  WHERE tfc.flight_id = 130525;
  
 
EXPLAIN ANALYZE 
 SELECT * 
   FROM public.ticket_flights_copy tfc
  WHERE tfc.flight_id::text like '%130525%';
  
 
-- Создадим копию таблицы flights и выполним запрос с фильтрацией по двум атрибутам
DROP TABLE IF EXISTS public.flights_copy;

CREATE TABLE public.flights_copy
 (LIKE bookings.flights);
 
INSERT INTO public.flights_copy
SELECT * FROM bookings.flights;


EXPLAIN ANALYZE
 SELECT * 
   FROM public.flights_copy fc
  WHERE fc.departure_airport = 'DME'
    AND fc.arrival_airport = 'LED';
    
   
-- Создадим составной индекс
DROP INDEX IF EXISTS flights_copy_airports_index;

CREATE INDEX flights_copy_airports_index 
          ON public.flights_copy (departure_airport, arrival_airport);
     
         
-- Выполним этот запрос повторно
EXPLAIN ANALYZE
 SELECT * 
   FROM public.flights_copy fc
  WHERE fc.departure_airport = 'DME'
    AND fc.arrival_airport = 'LED';
   
   
-- Выведем только те поля, которые участвуют в индексе
EXPLAIN ANALYZE
 SELECT fc.departure_airport
       ,fc.arrival_airport
   FROM public.flights_copy fc
  WHERE fc.departure_airport = 'DME'
    AND fc.arrival_airport = 'LED';
    
   
-- Допустим, нам необходимо посмотреть данные за определённую дату о совершенных полётах
EXPLAIN ANALYZE
 SELECT * 
   FROM public.flights_copy fc
  WHERE DATE(fc.actual_departure) = '2017-09-06';
  
 
-- Сравним время выполнения фильтрации по равенству и наравенству
EXPLAIN ANALYZE
 SELECT * 
   FROM public.flights_copy fc
  WHERE DATE(fc.actual_departure) > '2017-09-06';
  
 
-- Создадим индекс на колонку с датой отправления
DROP INDEX IF EXISTS flights_copy_actual_departure_index;

CREATE INDEX flights_copy_actual_departure_index ON public.flights_copy (actual_departure);


-- Проверим, ускорился ли наш запрос
EXPLAIN ANALYZE
 SELECT * 
   FROM public.flights_copy fc
  WHERE fc.actual_departure = '2017-09-06';
  
 
-- Сравним время выполнения фильтрации по равенству и наравенству на индексе
EXPLAIN ANALYZE
 SELECT * 
   FROM public.flights_copy fc
  WHERE fc.actual_departure > '2017-09-06';
  
 
-- UNION vs UNION ALL
EXPLAIN ANALYZE
 SELECT * 
   FROM public.flights_copy fc
  WHERE fc.scheduled_departure < '2017-01-01 00:00:00.000 +0300'
 UNION
 SELECT * 
   FROM public.flights_copy fc2
  WHERE fc2.scheduled_departure >= '2017-01-01 00:00:00.000 +0300'
;


EXPLAIN ANALYZE 
 SELECT * 
   FROM public.flights_copy fc
  WHERE fc.scheduled_departure < '2017-01-01 00:00:00.000 +0300'
 UNION ALL
 SELECT * 
   FROM public.flights_copy fc2
  WHERE fc2.scheduled_departure >= '2017-01-01 00:00:00.000 +0300'
;


-- Временные таблицы
EXPLAIN ANALYSE
SELECT fc.*
      ,tfc.ticket_no
      ,tfc.fare_conditions 
      ,tfc.amount 
FROM public.flights_copy fc
JOIN public.ticket_flights_copy tfc ON tfc.flight_id = fc.flight_id
;

-- Создаём временную таблицу
CREATE TEMPORARY TABLE ticket_flights_materialized_public AS 
SELECT fc.*
      ,tfc.ticket_no
      ,tfc.fare_conditions 
      ,tfc.amount 
  FROM public.flights_copy fc
  JOIN public.ticket_flights_copy tfc ON tfc.flight_id = fc.flight_id;
  
-- Сделаем запрос к веременной таблице. Как изменилось время выполнения?
EXPLAIN ANALYSE
 SELECT tfm.*
   FROM ticket_flights_materialized_public tfm;
   
-- Финальный запрос на удаление временных таблиц
DROP TABLE IF EXISTS public.ticket_flights_copy;
DROP INDEX IF EXISTS ticket_flights_copy_flight_id_index;
DROP TABLE IF EXISTS public.flights_copy;
DROP INDEX IF EXISTS flights_copy_airports_index;
DROP INDEX IF EXISTS flights_copy_actual_departure_index;
DROP TABLE IF EXISTS ticket_flights_materialized_public;

