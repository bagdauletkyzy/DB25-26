
DROP TABLE IF EXISTS order_items    CASCADE;
DROP TABLE IF EXISTS orders         CASCADE;
DROP TABLE IF EXISTS products       CASCADE;
DROP TABLE IF EXISTS addresses      CASCADE;
DROP TABLE IF EXISTS customers      CASCADE;
DROP TABLE IF EXISTS articles       CASCADE;
DROP TABLE IF EXISTS logs           CASCADE;
DROP TABLE IF EXISTS events         CASCADE;

CREATE TABLE customers (
                           id          BIGSERIAL PRIMARY KEY,
                           name        TEXT        NOT NULL,
                           email       TEXT        NOT NULL UNIQUE,   
                           created_at  DATE        NOT NULL
);

CREATE TABLE addresses (
                           id           BIGSERIAL PRIMARY KEY,
                           customer_id  BIGINT     NOT NULL REFERENCES customers(id),
                           city         TEXT       NOT NULL,
                           street       TEXT       NOT NULL
);

CREATE TABLE products (
                          id      BIGSERIAL PRIMARY KEY,
                          name    TEXT            NOT NULL,
                          category TEXT           NOT NULL,
                          price   NUMERIC(10,2)   NOT NULL
);

CREATE TABLE orders (
                        id           BIGINT PRIMARY KEY,
                        customer_id  BIGINT            NOT NULL REFERENCES customers(id),
                        created_at   TIMESTAMP         NOT NULL,
                        status       TEXT              NOT NULL CHECK (status IN ('new','paid','shipped','canceled')),
                        total_amount NUMERIC(12,2)     NOT NULL
);

CREATE TABLE order_items (
                             order_id   BIGINT      NOT NULL REFERENCES orders(id),
                             product_id BIGINT      NOT NULL REFERENCES products(id),
                             qty        INT         NOT NULL,
                             price      NUMERIC(10,2) NOT NULL,
                             PRIMARY KEY (order_id, product_id)
);

CREATE TABLE articles (
                          id            BIGSERIAL PRIMARY KEY,
                          title         TEXT        NOT NULL,
                          body          TEXT        NOT NULL,
                          published_at  TIMESTAMP   NOT NULL
);

CREATE TABLE logs (
                      id           BIGSERIAL PRIMARY KEY,
                      customer_id  BIGINT      REFERENCES customers(id),
                      action       TEXT        NOT NULL,
                      payload      JSONB       NOT NULL,
                      created_at   TIMESTAMP   NOT NULL
);

CREATE TABLE events (
                        id     BIGSERIAL PRIMARY KEY,
                        room   TEXT       NOT NULL,
                        period TSRANGE    NOT NULL               
);


-- ---------- customers ----------
INSERT INTO customers (name, email, created_at)
SELECT 'User '||gs,
       'user'||gs||'@ex.com',
       DATE '2024-01-01' + ((gs % 180))  
FROM generate_series(1, 10000) AS gs;

-- ---------- addresses ----------
INSERT INTO addresses (customer_id, city, street)
SELECT c.id,
       CASE (c.id % 5)
           WHEN 0 THEN 'Almaty'
           WHEN 1 THEN 'ALMATY'
           WHEN 2 THEN 'almaty'
           WHEN 3 THEN 'Astana'
           ELSE 'Shymkent'
           END,
       'Street '||((random()*1000)::int)
FROM customers c;

-- ---------- products ----------
INSERT INTO products (name, category, price)
SELECT 'Product '||gs,
       (ARRAY['Electronics','Books','Grocery','Furniture','Toys'])[(gs % 5)+1],
       round((1000 + random()*500000)::numeric, 2)
FROM generate_series(1, 1000) AS gs;

-- ---------- orders----------
INSERT INTO orders (id, customer_id, created_at, status, total_amount)
SELECT 200000 + gs,                                      
       1 + (random()*9999)::int,
       TIMESTAMP '2025-01-01'
           + (gs % 180) * INTERVAL '1 day'
           + (random()*86400 || ' seconds')::interval,
       (ARRAY['new','paid','shipped','canceled'])[1 + (random()*3)::int],
       round((10000 + random()*500000)::numeric, 2)
FROM generate_series(1, 100000) AS gs;

-- ---------- order_items ----------
WITH pm AS (SELECT max(id) AS n FROM products)
INSERT INTO order_items (order_id, product_id, qty, price)
SELECT o.id,
       ((o.id * 97 + s * 13) % pm.n) + 1 AS product_id,
       1 + (random()*3)::int          AS qty,
       p.price
FROM orders o
         CROSS JOIN generate_series(1, 3) AS s
         CROSS JOIN pm
         JOIN products p ON p.id = ((o.id * 97 + s * 13) % pm.n) + 1;

-- ---------- articles ----------
INSERT INTO articles (title, body, published_at)
SELECT 'Article '||gs,
       'Body '||gs,
       TIMESTAMP '2025-01-01' + (gs % 180) * INTERVAL '1 day'
FROM generate_series(1, 10000) AS gs;

-- ---------- logs ----------
INSERT INTO logs (customer_id, action, payload, created_at)
SELECT 1 + (random()*9999)::int,
       (ARRAY['login','search','purchase'])[1 + (random()*2)::int],
       jsonb_build_object(
               'ip', '10.0.'||(gs % 255)||'.'||(1+(gs%200)),
               'success', (random() > 0.2),
               'tags', jsonb_build_array('auth','web'),
               'props', jsonb_build_object(
                       'browser', (ARRAY['Chrome','Safari','Firefox'])[1+(gs%3)],
                       'os', (ARRAY['Windows','macOS','Linux'])[1+((gs+1)%3)]
                        )
       ),
       TIMESTAMP '2025-01-01' + (gs % 180) * INTERVAL '1 day'
FROM generate_series(1, 100000) AS gs;

-- ---------- events ----------
INSERT INTO events (room, period)
SELECT lpad(((gs % 300)+100)::text, 3, '0') AS room,
       tsrange(
               TIMESTAMP '2025-11-01' + (gs % 7) * INTERVAL '1 day'
                   + ((gs % 480) * 3) * INTERVAL '1 minute',
               TIMESTAMP '2025-11-01' + (gs % 7) * INTERVAL '1 day'
                   + (((gs % 480) * 3) + 30) * INTERVAL '1 minute',
               '[)'
       )
FROM generate_series(1, 50000) AS gs;

--1 o(n)
Explain analyze select * from orders where created_at
Between '2025-03-01' and '2025-03-31' ;

"Seq Scan on orders  (cost=0.00..1960.27 rows=358 width=72) (actual time=0.050..16.721 rows=16680 loops=1)"
"  Filter: ((created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at <= '2025-03-31 00:00:00'::timestamp without time zone))"
"  Rows Removed by Filter: 83320"
"Planning Time: 0.165 ms"
"Execution Time: 17.541 ms"

--index O(logn+m) 2x
create index idx_orders_created on orders(created_at);
"Bitmap Heap Scan on orders  (cost=359.88..1495.98 rows=16740 width=38) (actual time=3.846..7.254 rows=16680 loops=1)"
"  Recheck Cond: ((created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at <= '2025-03-31 00:00:00'::timestamp without time zone))"
"  Heap Blocks: exact=697"
"  ->  Bitmap Index Scan on idx_orders_created  (cost=0.00..355.69 rows=16740 width=0) (actual time=3.695..3.696 rows=16680 loops=1)"
"        Index Cond: ((created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at <= '2025-03-31 00:00:00'::timestamp without time zone))"
"Planning Time: 4.008 ms"
"Execution Time: 8.666 ms"
--ндекс, потом чтение блоков

--2 sort+seq scan O(n log n)
Explain analyze select * from articles order by published_at
desc limit 50;

"Limit  (cost=516.19..516.32 rows=50 width=37) (actual time=3.177..3.193 rows=50 loops=1)"
"  ->  Sort  (cost=516.19..541.19 rows=10000 width=37) (actual time=3.174..3.181 rows=50 loops=1)"
"        Sort Key: published_at DESC"
"        Sort Method: top-N heapsort  Memory: 32kB"
"        ->  Seq Scan on articles  (cost=0.00..184.00 rows=10000 width=37) (actual time=0.066..1.593 rows=10000 loops=1)"
"Planning Time: 0.912 ms"
"Execution Time: 3.525 ms"

--index Scan Backward → O(log n + k) 15x
create index idx_arti_publ on articles(published_at);
"Limit  (cost=0.29..2.93 rows=50 width=37) (actual time=0.072..0.174 rows=50 loops=1)"
"  ->  Index Scan Backward using idx_arti_publ on articles  (cost=0.29..530.26 rows=10000 width=37) (actual time=0.070..0.164 rows=50 loops=1)"
"Planning Time: 0.889 ms"
"Execution Time: 0.217 ms"

--3 Seq Scan → O(n).
Explain analyze select * from articles where title='Article 9999';

"Seq Scan on articles  (cost=0.00..209.00 rows=1 width=37) (actual time=2.148..2.151 rows=1 loops=1)"
"  Filter: (title = 'Article 9999'::text)"
"  Rows Removed by Filter: 9999"
"Planning Time: 2.945 ms"
"Execution Time: 2.941 ms"

--ind hash ind o(1) 20x
create index idx_arti_titlehash on articles using hash(title);
"Index Scan using idx_arti_titlehash on articles  (cost=0.00..8.02 rows=1 width=37) (actual time=0.110..0.112 rows=1 loops=1)"
"  Index Cond: (title = 'Article 9999'::text)"
"Planning Time: 0.562 ms"
"Execution Time: 0.156 ms"

--4
Explain analyze select * from products where name='Product 777';
"Seq Scan on products  (cost=0.00..21.50 rows=1 width=35) (actual time=0.142..0.173 rows=1 loops=1)"
"  Filter: (name = 'Product 777'::text)"
"  Rows Removed by Filter: 999"
"Planning Time: 0.881 ms"
"Execution Time: 0.201 ms"

--index hash 
create index idx_products_name on products using hash(name);
"Index Scan using idx_products_name on products  (cost=0.00..8.02 rows=1 width=35) (actual time=0.035..0.036 rows=1 loops=1)"
"  Index Cond: (name = 'Product 777'::text)"
"Planning Time: 0.308 ms"
"Execution Time: 0.064 ms"

--5 
Explain analyze select * from orders where customer_id=1234 and 
created_at between '2025-03-01' and '2025-03-08' order by created_at;

"Sort  (cost=1035.29..1035.29 rows=1 width=38) (actual time=4.539..4.540 rows=1 loops=1)"
"  Sort Key: created_at"
"  Sort Method: quicksort  Memory: 25kB"
"  ->  Bitmap Heap Scan on orders  (cost=82.83..1035.28 rows=1 width=38) (actual time=1.416..3.929 rows=1 loops=1)"
"        Recheck Cond: ((created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at <= '2025-03-08 00:00:00'::timestamp without time zone))"
"        Filter: (customer_id = 1234)"
"        Rows Removed by Filter: 3891"
"        Heap Blocks: exact=585"
"        ->  Bitmap Index Scan on idx_orders_created  (cost=0.00..82.83 rows=3854 width=0) (actual time=0.551..0.551 rows=3892 loops=1)"
"              Index Cond: ((created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at <= '2025-03-08 00:00:00'::timestamp without time zone))"
"Planning Time: 0.621 ms"
"Execution Time: 4.858 ms"

--ind 

create index idx_orders_cus_created on orders(customer_id, created_at);

"Index Scan using idx_orders_cus_created on orders  (cost=0.42..8.44 rows=1 width=38) (actual time=0.466..0.467 rows=1 loops=1)"
"  Index Cond: ((customer_id = 1234) AND (created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at <= '2025-03-08 00:00:00'::timestamp without time zone))"
"Planning Time: 4.768 ms"
"Execution Time: 0.714 ms"


--6
Explain analyze select id,customer_id, created_at, status, total_amount
from orders where status='paid' order by created_at desc limit 100;


"Limit  (cost=0.29..19.48 rows=100 width=38) (actual time=1.775..5.673 rows=100 loops=1)"
"  ->  Index Scan Backward using idx_orders_created on orders  (cost=0.29..6394.29 rows=33317 width=38) (actual time=1.774..5.651 rows=100 loops=1)"
"        Filter: (status = 'paid'::text)"
"        Rows Removed by Filter: 200"
"Planning Time: 0.228 ms"
"Execution Time: 5.728 ms"

--Composite index (status, created_at) o(logn+m) 13x

create index if not exists idx_orderds_status  on orders(status,created_at);
"Limit  (cost=0.42..13.99 rows=100 width=38) (actual time=0.146..0.376 rows=100 loops=1)"
"  ->  Index Scan Backward using idx_orderds_status on orders  (cost=0.42..4522.44 rows=33317 width=38) (actual time=0.144..0.360 rows=100 loops=1)"
"        Index Cond: (status = 'paid'::text)"
"Planning Time: 0.576 ms"
"Execution Time: 0.442 ms"

--7 sort+seq sqan O(n log n)
Explain analyze select * from products where category='Electronics' 
order by price desc limit 100;

"Limit  (cost=29.14..29.39 rows=100 width=35) (actual time=1.848..1.863 rows=100 loops=1)"
"  ->  Sort  (cost=29.14..29.64 rows=200 width=35) (actual time=1.847..1.854 rows=100 loops=1)"
"        Sort Key: price DESC"
"        Sort Method: quicksort  Memory: 39kB"
"        ->  Seq Scan on products  (cost=0.00..21.50 rows=200 width=35) (actual time=0.044..0.215 rows=200 loops=1)"
"              Filter: (category = 'Electronics'::text)"
"              Rows Removed by Filter: 800"
"Planning Time: 0.172 ms"
"Execution Time: 1.893 ms"

--comp index(category price desc) logn+k

create index idx_products_price on products (category, price desc);
"Limit  (cost=0.28..23.67 rows=100 width=35) (actual time=0.126..0.208 rows=100 loops=1)"
"  ->  Index Scan using idx_products_price on products  (cost=0.28..47.07 rows=200 width=35) (actual time=0.105..0.179 rows=100 loops=1)"
"        Index Cond: (category = 'Electronics'::text)"
"Planning Time: 0.687 ms"
"Execution Time: 0.251 ms"

--8 
insert into addresses(customer_id, city, street) values
(10,'astana','kereykhan 13');

create unique index ux_addr on addresses(customer_id, lower(city), street);

insert into addresses(customer_id, city, street) values
(10,'ASTANA','kereykhan 13');
--ERROR:  duplicate key value violates unique constraint "ux_addr"
--Key (customer_id, lower(city), street)=(10, astana, kereykhan 13) already exists. 

--9 Seq Scan → O n
Explain analyze select * from addresses where lower(city)='astana';

"Seq Scan on addresses  (cost=0.00..234.01 rows=50 width=33) (actual time=0.043..4.334 rows=2001 loops=1)"
"  Filter: (lower(city) = 'astana'::text)"
"  Rows Removed by Filter: 8000"
"Planning Time: 0.797 ms"
"Execution Time: 4.493 ms"

--functioal index logn+m

create index idx_addr_city on addresses(lower(city));
"Bitmap Heap Scan on addresses  (cost=4.67..81.70 rows=50 width=33) (actual time=0.175..0.954 rows=2001 loops=1)"
"  Recheck Cond: (lower(city) = 'astana'::text)"
"  Heap Blocks: exact=84"
"  ->  Bitmap Index Scan on idx_addr_city  (cost=0.00..4.66 rows=50 width=0) (actual time=0.151..0.152 rows=2001 loops=1)"
"        Index Cond: (lower(city) = 'astana'::text)"
"Planning Time: 0.527 ms"
"Execution Time: 1.077 ms"

--10  обрезает значение created_at до начала дня.
Explain analyze select * from orders where date_trunc('day',created_at)=DATE '2025-03-15';
"Seq Scan on orders  (cost=0.00..2385.00 rows=500 width=38) (actual time=1.359..22.464 rows=556 loops=1)"
"  Filter: (date_trunc('day'::text, created_at) = '2025-03-15'::date)"
"  Rows Removed by Filter: 99444"
"Planning Time: 0.396 ms"
"Execution Time: 22.552 ms"

--ind 
create index idx_orders_day on orders(date_trunc('day',created_at));

"Bitmap Heap Scan on orders  (cost=8.17..798.98 rows=500 width=38) (actual time=0.587..3.285 rows=556 loops=1)"
"  Recheck Cond: (date_trunc('day'::text, created_at) = '2025-03-15'::date)"
"  Heap Blocks: exact=556"
"  ->  Bitmap Index Scan on idx_orders_day  (cost=0.00..8.04 rows=500 width=0) (actual time=0.519..0.520 rows=556 loops=1)"
"        Index Cond: (date_trunc('day'::text, created_at) = '2025-03-15'::date)"
"Planning Time: 1.246 ms"
"Execution Time: 3.352 ms"

