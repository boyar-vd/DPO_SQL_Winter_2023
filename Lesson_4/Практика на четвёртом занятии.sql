-- вычисляем среднюю оценку для студентов с помощью группировки

select sg."name"
	  ,avg(sg.grade)
  from public.student_grades sg 
 group by sg."name"
;
 

-- пример применения оконных функций агрегирования и ранжирования

select sg."name"
	  ,sg.subject 
	  ,sg.grade
	  ,sg.grade_dt 
	  ,row_number() over(partition by sg."name", sg.subject order by sg.grade_dt desc)
	  ,rank() over(partition by sg."name" order by sg.grade desc)	  
	  ,dense_rank() over(partition by sg."name" order by sg.grade desc)	
	  ,ntile(6) over(partition by sg."name" order by sg.grade_dt)
	  ,max(sg.grade) over(partition by sg."name" order by sg.subject, sg.grade_dt)
	  ,max(sg.grade) over(partition by sg."name", sg.subject)
	  ,max(sg.grade) over(partition by sg."name", sg.subject) - min(sg.grade) over(partition by sg."name", sg.subject)
	  ,avg(sg.grade) over()
	  ,avg(sg.grade) over(partition by sg."name", sg.subject) as avg_grade
	  ,sum(sg.grade) over(partition by sg."name", sg.subject) as avg_grade
  from public.student_grades sg 
  order by sg."name", sg.subject 
;
  
 
-- пример использование оконных функций смещения
 select gq."name" 
 	   ,gq.quartal 
 	   ,first_value(gq.grade) over(order by gq.quartal)
 	   ,lag(gq.grade) over(order by gq.quartal)
 	   ,gq.grade
 	   ,lead(gq.grade) over(order by gq.quartal)
 	   ,last_value(gq.grade) over(order by gq.quartal
 	   RANGE BETWEEN UNBOUNDED PRECEDING
		 AND UNBOUNDED FOLLOWING
 	   )
   from public.grades_quartal gq 
   order by 2
   ;
   
  
-- Задание:
-- 1. Вывести:
-- a. имя и фамилию пассажира
-- b. идентификаторы всех его перелётов
-- c. класс бронирования
-- d. стоимость каждого перелёта
-- e. минимальную, максимальную, среднюю и суммарную стоимость билетов пассажира с именем ADELINA ANTONOVA

 select t.passenger_name 
 	   ,tf.flight_id 
 	   ,tf.fare_conditions 
 	   ,tf.amount 
 	   ,min(tf.amount) over(partition by t.passenger_name)
 	   ,max(tf.amount) over(partition by t.passenger_name)
 	   ,avg(tf.amount) over(partition by t.passenger_name)
 	   ,sum(tf.amount) over(partition by t.passenger_name)
   from tickets t 
   join ticket_flights tf on t.ticket_no = tf.ticket_no 
  and t.passenger_name = 'ADELINA ANTONOVA'
  ;
 
 
-- Задание:
-- 2. Вывести аналогичные данные по всем пассажирам с именем ADELINA
-- 3. Вывести аналогичные данные по всем пассажирам с именем ADELINA с учётом класса бронирования
 
 select t.passenger_name 
 	   ,tf.flight_id 
 	   ,tf.fare_conditions 
 	   ,tf.amount 
 	   ,min(tf.amount) over(partition by t.passenger_name, tf.fare_conditions)
 	   ,max(tf.amount) over(partition by t.passenger_name, tf.fare_conditions)
 	   ,avg(tf.amount) over(partition by t.passenger_name, tf.fare_conditions)
 	   ,sum(tf.amount) over(partition by t.passenger_name, tf.fare_conditions)
   from tickets t 
   join ticket_flights tf on t.ticket_no = tf.ticket_no 
  and t.passenger_name like '%ADELINA%'
  ;
  
 
-- Задание:
-- 1. Вывести по каждому пассажиру:
-- a. Имяифамилию
-- b. Дату отправления
-- c. Времяотправления
-- d. Класс бронирования
-- e. Суммуперелёта
-- f. Текущую сумму перелётов нарастающим итогом начиная от самого раннего перелёта
-- g. Общую сумму перелётов

 select t.passenger_name 
 	   ,extract('year' from f.scheduled_departure)
 	   ,f.scheduled_departure::date as dep_date
 	   ,to_char(f.scheduled_departure, 'hh:mm:ss') as dep_time
 	   ,tf.fare_conditions 
 	   ,tf.amount
 	   ,sum(tf.amount) over(partition by t.passenger_name 
 	   							order by f.scheduled_departure)
 	   ,sum(tf.amount) over(partition by t.passenger_name)
   from (select *
   		   from tickets t
   		   limit 10000) as t
   join ticket_flights tf using(ticket_no)
   join flights f using(flight_id)
  ;
  
 
 -- Задание:
 -- 1. Вывести данные о первом полёте каждой модели самолёта: 
 -- a. Название модели самолёта на английском языке
 -- b. Дата и время первого полёта самолёта
 select temp_table.model_en
 	   ,temp_table.scheduled_departure
   from 
 (
 select ad.model->>'en' as model_en
 		,f.scheduled_departure
 		,row_number() over(partition by f.aircraft_code 
 								order by f.scheduled_departure) as rn
   from flights f 
   join aircrafts_data ad on f.aircraft_code = ad.aircraft_code 
   ) as temp_table
 where temp_table.rn = 1
 ;
 

 -- Задание:
 -- 2. Вывести аналогичные данные о крайнем полёте каждой модели самолёта
 
 select temp_table.model_en
 	   ,temp_table.scheduled_departure
   from 
 (
 select ad.model->>'en' as model_en
 		,f.scheduled_departure
 		,row_number() over(partition by f.aircraft_code 
 								order by f.scheduled_departure desc) as rn
   from flights f 
   join aircrafts_data ad on f.aircraft_code = ad.aircraft_code 
   ) as temp_table
 where temp_table.rn = 1
 ;
 

-- Задание:
-- 3. Составим рейтинг моделей самолётов по количеству перелётов. 
-- Вывести:
-- a. Название модели самолёта на английском языке
-- b. Общее количество перелётов данной модели самолёта 
-- c. Рейтинг модели самолёта по количеству перелётов

select ad.model->>'en' as model_en
	  ,count(f.flight_id) as flights_count
	  ,rank() over(order by count(f.flight_id) desc)
  from flights f 
  join aircrafts_data ad on f.aircraft_code = ad.aircraft_code
  group by ad.model
  ;
 
 
-- Задание:
-- Построим таблицу для моделей самолёта с использованием оконных функций смещения:
-- 1. Наименование модели самолёта на русском языке
-- 2. Номер первого полёта + Дата первого полёта в одной колонке
-- 3. Номер предыдущего полёта + Дата предыдущего полёта в одной колонке
-- 4. Номер текущего полёта + Дата текущего полёта в одной колонке
-- 5. Номер следующего полёта + Дата следующего полёта в одной колонке
-- 6. Номер крайнего полёта + Дата первого крайнего в одной колонке
 
 select ad.model->>'ru' as model_ru
 		,first_value(concat(f.flight_no, ' ', f.scheduled_departure::date)) over(partition by ad.model order by f.scheduled_departure) as first_val
 		,lag(concat(f.flight_no, ' ', f.scheduled_departure::date)) over(partition by ad.model order by f.scheduled_departure) as prev_val
 		,concat(f.flight_no, ' ', f.scheduled_departure::date) as current_val
 		,lead(concat(f.flight_no, ' ', f.scheduled_departure::date)) over(partition by ad.model order by f.scheduled_departure) as lead_val
 		,last_value(concat(f.flight_no, ' ', f.scheduled_departure::date)) over(partition by ad.model order by f.scheduled_departure
 		RANGE BETWEEN UNBOUNDED PRECEDING
		 AND UNBOUNDED FOLLOWING) as last_val
  from flights f 
  join aircrafts_data ad on f.aircraft_code = ad.aircraft_code
  order by 1
  ;
