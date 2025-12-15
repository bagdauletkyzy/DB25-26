

--task1
create or replace function get_customer_full_name(p_customer_id INT)
returns text as $$ declare full_name text; --возвращает строку full_name
begin 
select last_name || ' ' || first_name 
into full_name from customers where customer_id=p_customer_id;
return full_name;
end;
$$ language plpgsql;

SELECT get_customer_full_name(1);
"Smith John" 

SELECT get_customer_full_name(999);
null


--task2
create or replace function get_rental_duration(p_customer_id INT)
returns int as $$ declare total_days INT;
begin 
select  coalesce(sum(return_date-rental_date),0) --разница дат в днях (сколько длилась аренда)
into total_days from rentals where customer_id=p_customer_id and return_date is not null; --Возвращаем итоговое количество дней аренды
return total_days;
end;
$$ language plpgsql;

SELECT get_rental_duration(1);
11--сумма дней аренды клиента1 (3-1+10-5+5-1=2+5+4=11)

SELECT get_rental_duration(2);
10--сумма дней аренды клиента2 (2+3+5=10)


--task3 с датой
create or replace function get_rental_duration(p_customer_id INT, p_from_date DATE)
returns int as $$ declare total_days INT;
begin 
select  coalesce(sum(return_date-rental_date),0) --cчитаем только аренды после указанной даты
into total_days from rentals where customer_id=p_customer_id 
and rental_date>=p_from_date and return_date is not null;
return total_days;
end;
$$ language plpgsql;

SELECT get_rental_duration(1, '2023-08-01');

4 --считает только аренды после 1 августа 5-1=4

--task4
create or replace function get_rental_hi_lo(p_customer_id int, out max_days int, out min_days int )--выходные параметры
as $$ begin 
select  max(return_date-rental_date),min(return_date-rental_date) --самая длинная и короткая аренда
into max_days,min_days from rentals where customer_id=p_customer_id 
and returun_date is not null;--только завершённые аренды
end;
$$ language plpgsql;

SELECT * FROM get_rental_hi_lo(1);
max    min   --
5      2


--task5 применяет скидку к цене, используя параметр inout
create or replace function apply_discount(inout p_rate numeric, p_discount_percent numeric) --входной и выходной он автоматически возвращается из функции
as $$ begin p_rate:=p_rate-(p_rate*p_discount_percent/100) --новая цена=цена-(цена*скидка/100)
end;
$$ language plpgsql;

SELECT apply_discount(30, 10);
27.0000000000000000 --30-(30*10/100)
SELECT apply_discount(10, 25);
7.5000000000000000 

--task6 сумму и среднее значение для набора чисел
create or replace function sum_and_avg(variadic p_values numeric[], out total numeric, out avg_value numeric) --можно передавать любое количество аргументов
as $$ begin 
if array_length(p_values, 1 ) is null then 
total:=null; avg_value:=null;
else select sum(val), avg(val) into total, avg_value from unnest(p_values) as val; --превращает массив в строки
end if;
$$ language plpgsql;

SELECT * FROM sum_and_avg(1,2,3);
total     avg_val
6	      2.0000000000000000

SELECT * FROM sum_and_avg(10.5,20.5,30.0,40.0);
total         avg_val
101,0	      2.25.2500000000000000

--task7 ищет фильмы по шаблону названия
create or replace function get_films_by_pattern(p_pattern varchar)--строка-шаблон для поиска
returns table(film_id int, film_title text, film_year int, film_rating text) 
as $$ begin 
return query--возврата набора строk
select film_id, title, release_year, rating from films where title like p_pattern;
end;
$$ language plpgsql;

SELECT * FROM get_films_by_pattern('A%');
film_id  film_title.        film_year  film_rating
1	      "Alien Adventure"	2001	    "PG-13"
10	      "Alpine Legend"	2004	    "PG"

SELECT * FROM get_films_by_pattern('%land%');
9	"Island of Dreams"	2019	"PG-13"


--task8 возвращает список аренд клиента
create or replace function get_customer_rentals(p_customer_id int)
returns table(rental_id int, film_title text, rental_date date, return_date date, rental_days int) 
as $$ begin 
return query
select r.rental_id, f.title, r.rental_date, r.return_date,
case when r.return_date is not null --условная конструкция
then (r.return_date-r.rental_date)--Если return_date есть считаем разницу дат (количество дней аренды)
else 0 end as rental_days--return_date = null возвращаем 0
from rentals r join films f on r.film_id=f.film_id
where r.customer_id=p_customer_id;
end;
$$ language plpgsql;  

SELECT * FROM get_customer_rentals(1);
r_id  film_title          rental_date    return_date    rental_days
1	  "Alien Adventure"	  "2023-07-01"	"2023-07-03"	2
2	  "Brave Hearts"	  "2023-07-05"	"2023-07-10"	5
3	  "Island of Dreams"  "2023-08-01"	"2023-08-05"	4
--таблица с 3 строками: аренды клиента1 с названиями фильмов и рассчитанными днями
--

--task 9 возвращает статистику по арендам клиента
create or replace function get_customer_stats(p_customer_id int )
returns text as $$ declare rental_count int, total_days int;
begin declare tmp_count int; tmp_days int ; --временные переменные для выборки из базы
begin select count(*), coalesce(sum(return_date-rental_date),0) --количество завершённых аренд и сцмма
into tmp_count, tmp_days from rentals where customer_id=p_customer_id
and return_date is not null;
rental_count:=tmp_count; total_days:=tmp_days; --переносим значения из временных переменных в основные
end;
return 'customer' || p_customer_id || ':rentals =' || rental_count || ', total days=' || total_days;
end;
$$ language plpgsql;

SELECT get_customer_stats(1);
"customer1:rentals =3, total days=11"

--task10
create or replace function get_customer_rentals_count(p_customer_id int, 
p_only_returned boolean default true)--true → считаем только завершённые аренды false → считаем все аренды
returns int as $$  declare cnt int;
begin 
if p_only_returned then --фильтруем где return_date is not null
    select count(*) into cnt from rentals 
    where customer_id = p_customer_id and return_date is not null;
else 
    select count(*) into cnt --считаем все аренды клиента
    from rentals where customer_id = p_customer_id;
end if;
return coalesce(cnt, 0);
end;
$$ language plpgsql;

SELECT get_customer_rentals_count(1);
3 --по умолчанию считает только завершённые аренды → 3

SELECT get_customer_rentals_count(10, false);

2 --➝ считает все аренды клиента №10 → 2
