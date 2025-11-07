--1
Select Distinct group_name 
From students Order by group_name ASC;
--2
Select * FROM products WHERE category='Electronics'
AND price BETWEEN (100 AND 500 ) AND in_stock= TRUE Order by price ASC,title ASC;
--3
Select * FROM products 
Order by price DESC,id ASC LIMIT 5 OFFSET 5;
--4
SELECT * FROM products WHERE title ILIKE '%pro%' 
AND price<1000 Order by title ASC Limit 20;
--5
Select group_name, COUNT(*) AS student_count 
FROM students 
GROUP BY group_name ORDER BY student_count DESC, group_name ASC;
--6
SELECT region, SUM(amount) AS total_revenue 
FROM sales
WHERE status='paid' Group by region HAVING SUM(amount)>100000
Order by total_revenue DESC;
--7
Select student_id, AVG(score) AS avg_score, COUNT(*) as attempts
FROM grades 
WHERE course='Databases' Group by student_id 
Having count(*)>=2 AND avg(score)>=85
Order by avg_score DESC LIMIT 10 OFFSET 10;
--8
SELECT COUNT(DISTINCT status) AS unique_statuses FROM sales;
--8b
Select distinct status FROM sales ORDER BY status;
--9
Select distinct user_id FROM( 
select user_id FROM web_events_2024 WHERE event_type='purchase'
UNION SELECT user_id FROM web_events_2025 WHERE event_type='purcahse')
as all_years ORDER by user_id;
--10
SELECT * FROM students 
ORDER by gpa DESC NULLS LAST, full_name LIMIT 30;
--11
INSERT INTO students (full_name, group_name, admitted_at, gpa, scholarship)
VALUES ('Aigerim Sadykova','CS-101','2024-09-01',NULL,FALSE)
RETURNING id;

SELECT * FROM students WHERE group_name='CS-101';

SELECT group_name, count(*) AS student_count
FROM students GROUP by group_name ORDER BY student_count DESC,
group_name NULLS LAST;

 