CREATE TABLE departments ( 
  id SERIAL PRIMARY KEY, 
  department_name TEXT NOT NULL 

); 

CREATE TABLE employees ( 
  id SERIAL PRIMARY KEY, 
  name TEXT NOT NULL, 
  department TEXT,          -- for simple examples 
  department_id INT,        -- for examples with USING 
  salary NUMERIC(12,2), 
  active BOOLEAN DEFAULT TRUE, 
  city TEXT 
); 

CREATE TABLE students ( 
  stu_id SERIAL PRIMARY KEY, 
  stu_name TEXT NOT NULL, 
  age INT, 
  gpa NUMERIC(3,2), 
  active BOOLEAN DEFAULT TRUE, 
  city TEXT 
); 

--1
Insert into students(stu_name,age) Values ('akbota',18);
Update students Set age=age+1 Where stu_name='akbota';
Select * from students Where stu_name='akbota';

--2
Insert into employees (salary,name,department) Values (65000,'Symbat','Finance');

Insert into employees Values (Default, 'Dana', null,null,null,default,null);

--3
Insert into employees (name, department, salary, city) Values ('Diana', 'IT', '55000', 'Almaty');

Insert into employees (name, department, salary,active, city) Values ('Masha', 'IT', default, default, default);

--4
Insert into students(stu_name,age,city) Select stu_name,age,'Almaty' From (Values('Aruzhan',19),('Dias', 20)) As s(stu_name,age)

--5
Select * From students Where active=TRUE AND age> 18 OR age<10 AND city='London';

Select * From students Where active=TRUE AND (age> 18 OR age<10) AND city='London';

--6
Update employees SET salary=salary*1.10 Where (department='IT') and (active=TRUE);

--7 екі кестедегі ортақ баған
Delete from employees e USING departments d Where e.department_id=d.id AND d.department_name='Marketing';

--8
Insert into employees(name, department, salary, active,city) Values ('Aisha','Finance',70000, TRUE,'Almaty') Returning id,name,(salary*12) AS annual_salary;

--9
Update employees e SET salary=e.salary + 5000 WHERE e.department = 'HR' 
RETURNING e.id, e.name,(e.salary - 5000) AS old_salary,e.salary AS new_salary;

--10
Delete From students Where gpa IS NOT NULL AND gpa<2.00 returning stu_id,stu_name,gpa;

SELECT COUNT(*) AS remaining_students FROM students;