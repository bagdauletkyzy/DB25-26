CREATE TABLE customers (
                           id        serial PRIMARY KEY,
                           first_name text,
                           last_name  text,
                           email      text,
                           city       text
);

INSERT INTO customers (first_name,last_name,email,city) VALUES
                                                            ('Ayan','Akhmetov','ayan@example.com','Almaty'),
                                                            ('Dana','Sadykova','DANA@MAIL.KZ','Astana'),
                                                            ('Jasur','Tulegenov','jasur@uni.edu','Shymkent'),
                                                            ('Maria','Ivanova','maria@site.kz','Almaty'),
                                                            ('Timur','Bek','timur@nowhere.kz','Karaganda'),
                                                            ('Alina','Orlova',NULL,'astana');  -- нижний регистр для ILIKE


CREATE TABLE products (
                          id       serial PRIMARY KEY,
                          name     text,
                          category text,
                          price    numeric(10,2),
                          status   text,
                          rating   int,
                          sku      text
);

INSERT INTO products (name,category,price,status,rating,sku) VALUES
                                                                 ('Phone','Electronics', 900,'active',   5,'EL-001-PHN'),
                                                                 ('Laptop','Electronics',1500,'active',  5,'EL-002-LPT'),
                                                                 ('Watch','Wearables',   200,'draft',    4,'AC-010-WCH'),
                                                                 ('Camera','Electronics',450,'active',   3,'EL-011-CAM'),
                                                                 ('Mouse','Accessories',  20,'archived', 5,'AC-100-MSE'),
                                                                 ('Keyboard','Accessories',35,'active',  4,'AC-200-KBD');


CREATE TABLE orders (
                        id         serial PRIMARY KEY,
                        customer_id int REFERENCES customers(id),
                        product_id  int REFERENCES products(id),
                        quantity    int,
                        order_date  date
);

INSERT INTO orders (customer_id,product_id,quantity,order_date) VALUES
                                                                    (1,1, 2,'2025-01-05'),
                                                                    (2,1,10,'2025-02-01'),
                                                                    (3,2, 1,'2025-01-15'),
                                                                    (5,4, 0,'2025-02-14');  -- ноль для демонстрации NULLIF


CREATE TABLE competitor_offers (
                                   product_id int REFERENCES products(id),
                                   price      numeric(10,2)
);

INSERT INTO competitor_offers (product_id,price) VALUES
                                                     (1,800),(1,950),
                                                     (2,1400),
                                                     (3,NULL),
                                                     (4,480),
                                                     (5,25),
                                                     (6,30);

--1

Select id,name,price, ROUND(price*1.12, 2) as price_withvat, 
POWER(2,rating) AS score_pow FROM products;

--2

SELECT id,name, FLOOR(price/100) as floor_hundreds,
CEIL(price/3.0) as ceil_div FROM products;

--3

SELECT id, first_name || ' ' || last_name as full_name,
LENGTH(first_name)+ LENGTH(last_name) as name_len,
SPLIT_PART(email, '@',2) as email_domain FROM customers;

--4
SELECT id, first_name,city FROM customers WHERE city ILIKE 'astana';

--5

SELECT id,name,price, CASE WHEN price>=1000 THEN 'premium'
WHEN price>=200 THEN 'mid' ELSE 'budget'
END AS price_segment FROM products;

--6
SELECT o.id as order_id, 
c.first_name || ' ' || c.last_name as customer,
p.name as product, o.quantity, 
p.price / NULLIF(o.quantity, 0) as unit_price,
COALESCE(c.email, 'n/a') as email_safe FROM orders o 
JOIN customers c ON o.customer_id=c.id
JOIN products p ON o.product_id=p.id;

--7
--a)
SELECT category, COUNT(*) as cnt,
ROUND(AVG(price),2) as avg_price 
FROM products GROUP BY category ORDER BY avg_price DESC;

--b
SELECT category, COUNT(*) as cnt,
ROUND(avg(price),2) as avg_price
FROM products GROUP BY category 
Having avg(price)>100 ORDER BY avg_price DESC;

--8
SELECT p.id as product_id, p.name FROM products p
where exists(select 1 FROM order o where o.product_id=p.id );

--9
SELECT id,first_name, last_name FROM customers
WHERE id not in(SELECT customer_id FROM orders
WHERE customer_id is not null);

--10
SELECT p.id,p.name,p.price
FROM products p where p.price>any(
select c.price FROM competitor_offers c
where c.product_id=p.id and c.price is not null
);

--11
Insert into customers (first_name, last_name, email, city)
values ('Aruzhan','Sapar','aruzhan@outlook.kz', 'Astana'),
('Daniyar','Tulegenov', NULL,'astana'),
('Mariya', 'Kim','mariya.kim@gmail.com','ASTANA'),
('Nurzhan','Abilov','nurzhan@kbtu.edu.kz','Almaty');



