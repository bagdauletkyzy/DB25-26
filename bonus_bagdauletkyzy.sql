														  
--task1 статусы актив шыгару
select s.full_name as student_name, s.email, c.title as course_title, c.category, e.enrolled_at
from enrollments e join students s on s.student_id=e.student_id
join courses c  on c.course_id=e.course_id where s.status='active' 
and c.is_active=true order by s.full_name, c.title, e.enrolled_at;

s_name              email                         course_title                   category       enrolled_at 
"Amy Dunn"	      "amy@example.com"	              "Intro to Databases"	         "Databases"	  "2022-09-01"
"Amy Dunn"	      "amy@example.com"	              "Python for Data Analysis"	   "Programming"	"2023-10-05"
"Amy Dunn"	      "amy@example.com"	              "SQL for Developers"	         "Databases"	  "2023-02-10"
"Bruce Wayne"	    "batman@example.com"	          "Intro to Cybersecurity"	     "Security"	    "2023-03-20"
"Bruce Wayne"	    "batman@example.com"	          "Intro to Databases"	         "Databases"	  "2021-09-10"
"Bruce Wayne"	    "batman@example.com"	          "Python Basics"	               "Programming"	"2022-01-15"
"Ellen Ripley"	  "alien_hunter@example.com"	    "Intro to Cybersecurity"	     "Security"	    "2021-09-01"
"Ellen Ripley"	  "alien_hunter@example.com"	    "Machine Learning 101"	       "AI"	          "2022-02-01"
"Elliot Alderson"	"mr.robot@example.com"	        "Python Basics"	               "Programming"	"2023-03-01"
"Elliot Alderson"	"mr.robot@example.com"	        "Web Development with JS"	     "Web"	        "2023-05-01"
"Gustavo Fring"	  "just_call_me_gus@example.com"	"Python Basics"	               "Programming"	"2023-02-01"
"Gustavo Fring"	  "just_call_me_gus@example.com"	"Python for Data Analysis"	   "Programming"	"2023-09-01"
"Sarah Connor"	  "terminator@example.com"	      "Intro to Databases"	         "Databases"	  "2022-09-15"
"Sarah Connor"	  "terminator@example.com"	      "Web Development with JS"	     "Web"	        "2023-01-20"
"Tyler Durden"	  "i_m_not_real@example.com"	    "Python for Data Analysis"	   "Programming"	"2023-02-01"
"Tyler Durden"	  "i_m_not_real@example.com"	    "SQL for Developers"	         "Databases"	  "2022-11-01"

--task2 для каждого курса вывести количество завершенных студ и ср балл
select c.course_id, c.title 
count(*) filter(where e.status='completed') as completed_student_count, --считает только завершённые записи
avg(e.final_grade) filter (where e.status='completed') as avg_final_grade_completed --среднее только по завершённым.
from courses c left join enrollments e on e.course_id=c.course_id
group by c.course_id, c.title order by c.course_is;

id title                 сompl_stu_count  avg_final_grade_comp
1	"Intro to Databases"	  4	              8.3750000000000000
2	"SQL for Developers"	  3	              8.0000000000000000
3	"Advanced PostgreSQL"	  2	              7.2500000000000000
4	"Python Basics"	        2	              8.7500000000000000
5	"Python for Data Analysis"	1	          8.0000000000000000
6	"Web Development with JS"	1	            8.0000000000000000
7	"Intro to Cybersecurity"	2	            7.7500000000000000
8	"Machine Learning 101"	2	              8.5000000000000000

--task3 показать все платежи с именами студента курса препод дата сумм
select s.full_name as student_name,c.title as course_title, p.amount as payment_amount,
p.paid_at as payment_date,i.full_name as instructor_name from payments p
join students s on s.student_id=p.student_id 
join courses c on c.course_id=p.course_id
join instructors i on i.instructor_id =c.instructor_id 
order by p.paid_at, s.full_name, c.title;
"Bellatrix Lestrange"	"Intro to Databases"	150.00	"2020-01-25"	"Hannibal Lecter"
"Bellatrix Lestrange"	"SQL for Developers"	200.00	"2020-08-25"	"Hannibal Lecter"
"Nolan Grayson"	"Advanced PostgreSQL"	250.00	"2020-09-25"	"Hannibal Lecter"
"Bellatrix Lestrange"	"Advanced PostgreSQL"	250.00	"2021-02-20"	"Hannibal Lecter"
"Nolan Grayson"	"Machine Learning 101"	220.00	"2021-03-25"	"Dexter Morgan"
"John Wick"	"Intro to Cybersecurity"	160.00	"2021-04-05"	"Tony Soprano"
"Ellen Ripley"	"Intro to Cybersecurity"	160.00	"2021-08-25"	"Tony Soprano"
"Bruce Wayne"	"Intro to Databases"	150.00	"2021-09-05"	"Hannibal Lecter"
"Bruce Wayne"	"Python Basics"	120.00	"2022-01-10"	"Dolores Umbridge"
"Ellen Ripley"	"Machine Learning 101"	220.00	"2022-01-25"	"Dexter Morgan"
"Amy Dunn"	"Intro to Databases"	150.00	"2022-08-25"	"Hannibal Lecter"
"Sarah Connor"	"Intro to Databases"	150.00	"2022-09-10"	"Hannibal Lecter"
"Tyler Durden"	"SQL for Developers"	200.00	"2022-10-25"	"Hannibal Lecter"
"Sarah Connor"	"Web Development with JS"	190.00	"2023-01-15"	"Lisbeth Salander"
"Gustavo Fring"	"Python Basics"	120.00	"2023-01-25"	"Dolores Umbridge"
"Tyler Durden"	"Python for Data Analysis"	180.00	"2023-01-25"	"Dolores Umbridge"
"Amy Dunn"	"SQL for Developers"	200.00	"2023-02-05"	"Hannibal Lecter"
"Bruce Wayne"	"Intro to Cybersecurity"	160.00	"2023-03-15"	"Tony Soprano"
"Gustavo Fring"	"Python for Data Analysis"	180.00	"2023-08-25"	"Dolores Umbridge"
"Amy Dunn"	"Python for Data Analysis"	180.00	"2023-10-01"	"Dolores Umbridge"

--task4 собрать в отдельное представление записи где студент неактивен а курс активен


create view active_course_enrollments as
select s.student_id,s.full_name as student_full_name,c.course_id,
c.title as course_title,e.enrolled_at,e.status as enrollment_status
from enrollments e join students s on s.student_id = e.student_id
join courses c on c.course_id=e.course_id
where s.status <> 'active' and c.is_active=TRUE; --студент не активен а курс активен

select * from active_course_enrollments;
4	"Bellatrix Lestrange"	1	"Intro to Databases"	"2020-02-01"	"completed"
4	"Bellatrix Lestrange"	2	"SQL for Developers"	"2020-09-01"	"completed"
4	"Bellatrix Lestrange"	3	"Advanced PostgreSQL"	"2021-03-01"	"completed"
5	"John Wick"	7	"Intro to Cybersecurity"	"2021-04-10"	"completed"
7	"Nolan Grayson"	3	"Advanced PostgreSQL"	"2020-10-01"	"completed"
7	"Nolan Grayson"	8	"Machine Learning 101"	"2021-04-01"	"completed"

--task5 создать view через которое можно писать данные но исключительно такие что остаются видимыми в этом view

create view only_active_students as
select student_id,full_name,email,enrollment_year,status
from students where status = 'active' 
with local check option; --представление будет содержать только активных студентов

insert into only_active_students (full_name, email, enrollment_year, status)
values ('Bagdauletkyzy Akbota', 'abagdaulet@kbtu.com', 2025, 'active'); --if it is not "active " output errror
1	"Amy Dunn"	"amy@example.com"	2022	"active"
2	"Bruce Wayne"	"batman@example.com"	2021	"active"
3	"Gustavo Fring"	"just_call_me_gus@example.com"	2023	"active"
6	"Sarah Connor"	"terminator@example.com"	2022	"active"
8	"Elliot Alderson"	"mr.robot@example.com"	2023	"active"
9	"Tyler Durden"	"i_m_not_real@example.com"	2022	"active"
10	"Ellen Ripley"	"alien_hunter@example.com"	2021	"active"
11	"Bagdauletkyzy Akbota"	"abagdaulet@kbtu.com"	2025	"active"


--task6 ускорить частые точечные выборки по email
create index if not exists idx_students_email on students using btree (email); --универсален
select * from students where email='amy@example.com';
1	"Amy Dunn"	"amy@example.com"	2022	"active"

--task7 получить общую сумму всех платежей конкретного студента

create or replace function get_student_total_paid(p_student_id int)
returns numeric language plpgsql --возвращает число
as $$ declare v_total numeric := 0; --бъявляем переменную для хранения суммы.     
begin select coalesce(sum(amount), 0) into v_total --считаем сумму всех платежей студента возвращает 0 если платежей нет
from payments where student_id = p_student_id; 
return v_total;
end;
$$;
select get_student_total_paid(1);
530.00 --150+200+180=530.00

--task8 вернуть общую сумму платежей и количество курсов ]а которые платил студент

create or replace function get_student_stats(
p_student_id int, out total_paid numeric,out course_count int)
language plpgsql as $$
begin select coalesce(sum(amount), 0),coalesce(count(distinct course_id), 0) --сумма всех платежей студента и кол курсв за которые студент платил. если нет платежей its 0
into total_paid, course_count from payments where student_id=p_student_id; --сохраняем результаты в выходные параметры
end;
$$;

select * from get_student_stats(1);
t_paid. course_count
530.00	3


--9 уменьшить цены курсов категории Databases на 10% показать до и после

create or replace function apply_discount(inout price numeric)--одновременно входной и выходной
language plpgsql as $$
begin price:=round(price * 0.9, 2); --уменьшаем цену на 10% и округляем до двух знаков после запятой
end;
$$;

select course_id,title,price from courses where category='Databases';
1	"Intro to Databases"	150.00
2	"SQL for Developers"	200.00
3	"Advanced PostgreSQL"	250.00

update courses set price=apply_discount(price) where category='Databases';

select course_id,title,price from courses where category='Databases';

1	"Intro to Databases"	135.00
2	"SQL for Developers"	180.00
3	"Advanced PostgreSQL"	225.00

--10 создать групповую роль без логина дать ей права только на чтение нужных таблиц добавить пользователей и дать им запрос по доходам
create role los_pollos_hermanos nologin; --роль не может сама входить в систему используется как группа

grant select on courses,instructors,payments to los_pollos_hermanos;--привелегия 

create user hacker1 with login password 'hacker1_pass'; 
create user hacker2 with login password 'hacker2_pass';

grant los_pollos_hermanos to hacker1, hacker2; --могут читать таблицы courses, instructors, payments

select c.title as course_title, i.full_name as instructor_name, 
sum(p.amount) as total_revenue from payments p --суммирует все платежи в каждой группе
join courses c on c.course_id = p.course_id
join instructors i on i.instructor_id = c.instructor_id
group by c.title, i.full_name order by total_revenue desc;

c_title                instr_name        total_revenue
"SQL for Developers"	"Hannibal Lecter"	600.00
"Intro to Databases"	"Hannibal Lecter"	600.00
"Python for Data Analysis"	"Dolores Umbridge"	540.00
"Advanced PostgreSQL"	"Hannibal Lecter"	500.00
"Intro to Cybersecurity"	"Tony Soprano"	480.00
"Machine Learning 101"	"Dexter Morgan"	440.00
"Python Basics"	"Dolores Umbridge"	240.00
"Web Development with JS"	"Lisbeth Salander"	190.00

