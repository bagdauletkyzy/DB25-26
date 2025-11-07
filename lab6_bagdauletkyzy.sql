--1
Create table students(
	id integer NOT NULL PRIMARY KEY,
	full_name TEXT NOT NULL,
	enrolled_at DATE DEFAULT CURRENT_DATE,
	email TEXT
	
);


--tasks in 1 
--4 working
insert into students(id, full_name, enrolled_at , email) values (1,'Bagdauletkyzy Akbota', '01-09-2024', 'abagdauletkyzy@kbtu.kz');
--5 working
insert into students(id, full_name,email) values (2,'Manapaly Zhanerke', 'zmanapaly@kbtu.kz');
--6 ERROR:  null value in column "full_name" of relation "students" violates not-null constraint
insert into students(id, enrolled_at , email) values (3, '01-09-2024','amaksat@kbtu.kz');

--2
Create table courses(
	course_id integer Primary key,
	course_name text not null
	
);
--tasks in 2
--1 
insert into courses(course_id, course_name) values (1,'Machine learning');
--2 ERROR:  duplicate key Key (course_id)=(1) already exists. 
insert into courses(course_id, course_name) values (1,'Robotics');

 
--3 
create table passengers(
	passenger_id SERIAL PRIMARY key,
	email text unique
);

--tasks in 3
insert into passengers(passenger_id, email) values (1,'test@mail.com');
--ERROR:  duplicate key Key (email)=(test@mail.com) already exists. 
insert into passengers(passenger_id, email) values (2,'test@mail.com');
insert into passengers(passenger_id, email) values (3,NULL),(4, NULL);


--4

create table employees(
	emp_id SERIAL PRIMARY key,
	age integer check(age>=18),
	salary NUMERIC(10,2) check(salary>0)
);
--tasks in 4
--ERROR: age<18
insert into employees(age, salary) values (16,1000000);
--ERROR: salary=0
insert into employees(age, salary) values(24, 0);
insert into employees(age, salary) values (30,5000.00);

--5
create table products(
	product_id serial primary key,
	regular_price numeric(10,2 ) NOT NULL,
	discount_price  numeric(10,2) NOT NULL,
	check(discount_price<regular_price)
);

--tasks in 5
--error discount_price>regular_price
insert into products(regular_price, discount_price ) values(100, 150);
insert into products(regular_price, discount_price ) values(150, 100);

--6
create table customers(
	customer_id SERIAL primary key,
	full_name text not null
	
);

create table orders(
	order_id SERIAL primary key,
	customer_id integer not null,
	order_total numeric(10,2) check(order_total>0),
	foreign key(customer_id ) references customers(customer_id)
);

--tasks in 6
--error: нету такого кастомер 20
insert into customers(customer_id, order_total) values(20, 800.00);

insert into customers(full_name) values('Miles Morales');
--there are cus_id
insert into orders(customer_id, order_total) values(1, 400.00);

--7
create table tickets(
	ticket_id serial primary key,
	price numeric(10,2),
	constraint positive_price check(price>0)
);

--tasks
--error: nonpositive
insert into tickets(price) values(-5);
ALTER table tickets drop constraint positive_price;
--and this is working after dropping
insert into tickets(price) values(-5);

--8
CREATE TABLE accounts ( 

    account_id SERIAL PRIMARY KEY, 

    balance    NUMERIC(12,2), 

    email      TEXT 

)

alter table accounts add constraint not_allow check(balance>=0);
alter table accounts add constraint u_email unique(email);
insert into accounts (balance, email) values(1000.00, 'abagdauletkyzy@mail.com');
--ERROR:  duplicate key
insert into accounts (balance, email) values(100.00, 'abagdauletkyzy@mail.com');
--error: balance<0
insert into accounts (balance, email) values(-100, 'sbagdauletkyzy@mail.com');


--9
create table drivers(
	driver_id serial primary key,
	license_number text not null,
	phone_number text
);
--ERROR:  null value in column "license_number" 
insert into drivers(phone_number) values('+777777777');

insert into drivers(license_number) values('+7999999999');

--10
create table user_profiles(
	user_id serial primary key,
	email text not null,
	first_name text not null,
	constraint aaaaa check(position('@' in email)>1)
);

insert into user_profiles(email,first_name) values('alice@gmail.com','yuri');
--errror: no symbol @ check aaaaa
insert into user_profiles(email,first_name) values('not_an_email','yuri');





