CREATE TABLE customers (
                           customer_id INT PRIMARY KEY,
                           full_name   TEXT NOT NULL,
                           city        TEXT
);

CREATE TABLE orders (
                        order_id    INT PRIMARY KEY,
                        customer_id INT,
                        order_date  DATE,
                        status      TEXT
);

CREATE TABLE products (
                          product_id   INT PRIMARY KEY,
                          product_name TEXT NOT NULL,
                          category     TEXT
);

CREATE TABLE order_items (
                             order_id   INT,
                             product_id INT,
                             quantity   INT,
                             unit_price NUMERIC(10,2)
);


INSERT INTO customers (customer_id, full_name, city) VALUES
                                                         (1,'Alice','Almaty'),
                                                         (2,'Beka','Astana'),
                                                         (3,'Dana','Shymkent'),
                                                         (4,'Emir','Almaty');

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
                                                                   (100, 1, '2025-01-10', 'paid'),
                                                                   (101, 1, '2025-02-15', 'pending'),
                                                                   (102, 2, '2025-03-01', 'cancelled'),
                                                                   (103, 5, '2025-03-05', 'paid'),
                                                                   (104, 3, '2025-03-07', 'paid');

INSERT INTO products (product_id, product_name, category) VALUES
                                                              (10,'Laptop','Electronics'),
                                                              (20,'Mouse','Accessories'),
                                                              (30,'Keyboard','Accessories'),
                                                              (40,'Desk','Furniture'),
                                                              (50,'Monitor','Electronics');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
                                                                         (100, 10, 1, 500.00),
                                                                         (100, 20, 2,  25.00),
                                                                         (101, 50, 1, 150.00),
                                                                         (102, 20, 1,  25.00),
                                                                         (106, 30, 1,  30.00);

--task1
SELECT o.order_id, o.order_date,o.status, c.full_name from orders o join customers c ON o.customer_id=c.customer_id;

"order_id","order_date","status","full_name"
100,"2025-01-10","paid","Alice"
101,"2025-02-15","pending","Alice"
102,"2025-03-01","cancelled","Beka"
104,"2025-03-07","paid","Dana"


--task2 
Select o.order_id, c.full_name, count(o.order_id) as orders_count from orders o join customers c on c.customer_id=o.customer_id GROUP by o.order_id, c.full_name;

104	"Dana"	1
100	"Alice"	1
102	"Beka"	1
101	"Alice"	1
--3
Select o.order_id, o.customer_id from customers c right join orders o on c.customer_id=o.customer_id where c.customer_id is null;

103	5
--4
Select i.order_id, i.product_id, i.quantity , i.unit_price, p.product_name from order_items i join products p using(product_id) ;
100	10	1	500.00	"Laptop"
100	20	2	25.00	"Mouse"
101	50	1	150.00	"Monitor"
102	20	1	25.00	"Mouse"
106	30	1	30.00	"Keyboard"
--5
Select o.order_id, c.full_name, p.product_name, i.quantity from orders o 
join customers c on o.customer_id=c.customer_id   join order_items i on o.order_id=i.order_id join products p on p.product_id=i.product_id where o.status='paid';

100	"Alice"	"Mouse"	  2
100	"Alice"	"Laptop"	1

--6
Select orders.order_id, Coalesce(SUM(order_items.quantity*order_items.unit_price),0) as order_tottal 
from orders left join order_items on orders.order_id=order_items.order_id group by orders.order_id;

102	25.00
101	150.00
103	0
104	0
100	550.00

--7
Select c.customer_id,c.full_name,o.order_id, o.status from customers c full join orders o on c.customer_id=o.customer_id order by coalesce(c.customer_id, o.order_id);

1	"Alice"	100	"paid"
1	"Alice"	101	"pending"
2	"Beka"	102	"cancelled"
3	"Dana"	104	"paid"
4	"Emir"	null null
null null	103	"paid"

--8
SElect o.order_id, o.customer_id, c.full_name, o.status from orders o left join customers c on c.customer_id=o.customer_id ;

100	1	"Alice"	"paid"
101	1	"Alice"	"pending"
102	2	"Beka"	"cancelled"
103	5	null    "paid"
104	3	"Dana"	"paid"

--9
select i.order_id,  count(*) as order_count, sum(i.quantity) as total_qty from order_items i group by i.order_id; 

101	1	1
102	1	1
100	2	3
106	1	1

--10
select p.product_id, p.product_name, coalesce(sum(i.quantity),0) as total_sold from products p 
left JOIN order_items i on p.product_id=i.product_id group by p.product_id, p.product_name;

40	"Desk"	    0
10	"Laptop"	1
50	"Monitor"	1
30	"Keyboard"	1
20	"Mouse"	    3