create database ecommerce_db;
use ecommerce_db;

create table customers(
customer_id int primary key,
customer_name varchar(100),
email varchar(100),
city varchar(50),
signup_date date
);

create table products(
product_id int primary key,
product_name varchar(50),
category varchar(50),
price decimal(10,2)
);

create table orders(
order_id int primary key,
customer_id int,
order_date date,
order_amount decimal(10,2),
foreign key (customer_id) references customers(customer_id)
);

create table order_items(
order_item_id int primary key,
order_id int,
product_id int,
quantity int,
foreign key (order_id) references orders(order_id),
foreign key (product_id) references products(product_id)
);


create table payments(
payment_id int primary key,
order_id int,
payment_method varchar(30),
payment_status varchar(30),
foreign key (order_id) references orders(order_id)
);

INSERT INTO customers VALUES
(1, 'Amit Sharma', 'amit@gmail.com', 'Delhi', '2023-01-10'),
(2, 'Riya Singh', 'riya@gmail.com', 'Mumbai', '2023-01-15'),
(3, 'Rahul Verma', 'rahul@gmail.com', 'Bangalore', '2023-02-05'),
(4, 'Neha Patel', 'neha@gmail.com', 'Ahmedabad', '2023-02-20'),
(5, 'Karan Mehta', 'karan@gmail.com', 'Delhi', '2023-03-01'),
(6, 'Simran Kaur', 'simran@gmail.com', 'Chandigarh', '2023-03-10'),
(7, 'Ankit Jain', 'ankit@gmail.com', 'Jaipur', '2023-03-18'),
(8, 'Pooja Nair', 'pooja@gmail.com', 'Kochi', '2023-04-01');

INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 60000),
(102, 'Smartphone', 'Electronics', 25000),
(103, 'Headphones', 'Electronics', 3000),
(104, 'Office Chair', 'Furniture', 7000),
(105, 'Dining Table', 'Furniture', 20000),
(106, 'T-Shirt', 'Clothing', 800),
(107, 'Jeans', 'Clothing', 2000),
(108, 'Shoes', 'Clothing', 3500);

INSERT INTO orders VALUES
(1001, 1, '2023-01-12', 63000),
(1002, 2, '2023-01-20', 25000),
(1003, 3, '2023-02-10', 28000),
(1004, 1, '2023-02-25', 7000),
(1005, 4, '2023-03-05', 20000),
(1006, 5, '2023-03-15', 4300),
(1007, 6, '2023-03-20', 3500),
(1008, 7, '2023-04-05', 60000),
(1009, 1, '2023-04-10', 25000);

INSERT INTO order_items VALUES
(1, 1001, 101, 1),
(2, 1001, 103, 1),
(3, 1002, 102, 1),
(4, 1003, 102, 1),
(5, 1003, 103, 1),
(6, 1004, 104, 1),
(7, 1005, 105, 1),
(8, 1006, 106, 2),
(9, 1006, 107, 1),
(10, 1007, 108, 1),
(11, 1008, 101, 1),
(12, 1009, 102, 1);

INSERT INTO payments VALUES
(1, 1001, 'Card', 'Success'),
(2, 1002, 'UPI', 'Success'),
(3, 1003, 'Card', 'Success'),
(4, 1004, 'NetBanking', 'Failed'),
(5, 1005, 'UPI', 'Success'),
(6, 1006, 'UPI', 'Success'),
(7, 1007, 'Card', 'Success'),
(8, 1008, 'Card', 'Success'),
(9, 1009, 'UPI', 'Failed');

-- total no of customers 
select count(customer_id) from customers;

-- total revenue 
select sum(order_amount) from orders;

-- orders by city
select c.city,count(o.order_id) as no_of_orders
from customers c
join orders o
on c.customer_id = o.customer_id
group by city;

-- monthly revenue
select * from orders;
select date_format(order_date, '%y-%m') as month, sum(order_amount) as monthly_revenue from orders
group by month
order by month;

-- Top 5 customers by total spend
select o.customer_id,c.customer_name,sum(o.order_amount) as total_spent from orders o 
join customers c
on o.customer_id = c.customer_id
group by customer_id
order by total_spent desc
limit 5;

-- most sold products
select * from order_items;

select o.product_id,p.product_name,sum(o.quantity) as total_sold from order_items as o
join products p 
on o.product_id = p.product_id
group by product_id
order by total_sold desc;

-- Average order value
select avg(order_amount) as avg_order_value from orders;

-- Orders by payment method
select * from payment;

select payment_method,count(order_id) as no_of_orders from payments
group by payment_method;

-- Repeat vs one-time customers
select customer_id,count(order_id) as total_no_of_purchase,
case 
when count(order_id)>1 then "Repeat Customer"
else "One-Time Customer"
end as customer_type    
from orders
group by customer_id;

-- Customers who never ordered
select c.* from customers c
left join orders o
on c.customer_id = o.customer_id
where o.customer_id is null;

-- Category-wise revenue
select p.category,sum(o.order_amount) as total_revenue from order_items oi 
join products p 
on oi.product_id = p.product_id
join orders o
on oi.order_id = o.order_id
group by p.category
order by total_revenue desc;

-- Failed payment orders
select * from payments
where payment_status = "Failed";

-- Month-over-month growth

select month,revenue,
		revenue - lag(revenue) over(order by month) as prev_revenue
from (
select date_format(order_date,"%y-%m") as month,
		sum(order_amount) as revenue
from orders
group by month) x;

-- Top 3 products per category

select*from products;

select p.product_name,p.category,total_sold from 
(select p.product_name,p.category,sum(oi.quantity) as total_sold,
rank() over(partition by p.category order by sum(oi.quantity) desc  ) as rnk
from order_items oi
join products p
using (product_id)
group by  p.product_name,p.category
) ranked_products
where rnk<4
