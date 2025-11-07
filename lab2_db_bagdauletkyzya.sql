
Create Table departments( --task1
       dept_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
       dept_name VARCHAR(255) NOT NULL UNIQUE
);
Create Table employees( --task2
       emp_id SERIAL PRIMARY KEY,
       first_name VARCHAR(50) NOT NULL,
	   last_name VARCHAR(50) NOT NULL,
	   salary NUMERIC(12,2),
	   dept_id int,
	   FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
	   
);
ALTER TABLE employees ADD COLUMN email VARCHAR(100) NOT NULL UNIQUE; --task3
ALTER TABLE employees RENAME COLUMN email TO work_email; --task4
ALTER TABLE employees ALTER  COLUMN work_email TYPE TEXT ;--task5
ALTER TABLE employees ALTER COLUMN work_email SET DEFAULT 'UNKNOWM'; --task6
ALTER TABLE employees DROP COLUMN work_email; --task7
ALTER TABLE employees ADD CHECK (salary>0);--task8
ALTER tABLE employees ALTER COLUMN salary SET NOT NULL;--task9
ALTER TABLE employees ALTER COLUMN salary DROP NOT NULL;--task10
Create table projects( --task11
project_id SERIAL PRIMARY KEY,
project_name VARCHAR(100) NOT NULL UNIQUE,
budget NUMERIC(12,2) CHECK(budget>1000)
);
CReate table employee_projects(
emp_id INT REFERENCES employees(emp_id) ON DELETE CASCADE,
project_id INT REFERENCES projects(project_id) ON DELETE CASCADE,
PRIMARY KEY(emp_id, project_id)
);-- task12
ALTER TABLE employees ADD CONSTRAINT department_employees UNIQUE (first_name,last_name,dept_id);
Create index idx_employees_last_name ON employees(last_name);--task14
Insert INTO departments(dept_name) Values ('IT'),('HR'),('Finance');--15
INSERT INTO employees(first_name, last_name, dept_id, salary, work_email) 
VALUES 
('Sanji','Vinsmoke',(SELECT dept_id FROM departments WHERE dept_name='IT'), 70000,'sanji@company.com'),
('Luffy','Monkey',(SELECT dept_id FROM departments WHERE dept_name='HR'), 75000,'luffymonkeyd@company.com'),
('Zoro','Roronoa',(SELECT dept_id FROM departments WHERE dept_name='HR'), 65000,'zorororonoa@company.com'),
('Robin','Nico',(SELECT dept_id FROM departments WHERE dept_name='Finance'), 80000,'nicoroin@company.com'),
('Chopper','Tony',(SELECT dept_id FROM departments WHERE dept_name='IT'), 10000,'tonychopper@company.com');

UPDATE employees e SET salary = salary*1.1 FROM departments d WHERE e.dept_id=d.dept_id AND d.dept_name= 'IT';
SELECT first_name,last_name,salary FROM employees ORDER BY salary desc;--18
DELETE FROM employees WHERE salary<1000;--19
DROP table employee_projects;--20


