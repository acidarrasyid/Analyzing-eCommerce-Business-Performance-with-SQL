select *
from customers;

select *
from orders;

select
	count (1) as tot_baris,
	count (distinct customer_id) as ci,
	count (distinct customer_unique_id) as cui
from customers;

select customer_unique_id, count (1)
from customers
group by 1
order by 2 desc;

select customer_id, count (1)
from customers
group by 1
order by 2 desc;

select order_purchase_timestamp, date_part('day', order_purchase_timestamp) as day
from orders;

--menampilkan jumlah customer aktif bulanan
select
	date_part('year', od.order_purchase_timestamp) as year,
	date_part('month', od.order_purchase_timestamp) as month,
	count (distinct cus.customer_unique_id) as mau
from orders as od
join customers as cus on cus.customer_id = od.customer_id
group by 1,2;

select year, round(avg(mau), 2) as avg_mau
from
	(select
		date_part('year', od.order_purchase_timestamp) as year,
		date_part('month', od.order_purchase_timestamp) as month,
		count (distinct cus.customer_unique_id) as mau
	from orders as od
	join customers as cus on od.customer_id = cus.customer_id
	group by 1,2) as tmp
group by 1;

--customer baru tiap tahun
select date_part ('year', first_time_purchase) as year,
count (1) as new_customers
from
(	select customer_unique_id,
	min (od.order_purchase_timestamp) as first_time_purchase
	from orders as od
	join customers as cus on cus.customer_id = od.customer_id
	group by 1) as tmp
group by 1
order by 1;

-- repeat order
select year,
count (distinct customer_unique_id) as repeat_customer
from
	(select date_part('year', od.order_purchase_timestamp) as year, cus.customer_unique_id,
	count (1) as purchase_frequency
	from orders as od
	join customers as cus on cus.customer_id = od.customer_id
	group by 1,2
	having count (1) > 1) as tmp
group by 1;

-- ratarata jumlah order
select year, round (avg(purchase_frequency),3) as avg_order_cust
from
(	select date_part('year', od.order_purchase_timestamp) as year, cus.customer_unique_id,
	count (1) as purchase_frequency
	from orders as od
	join customers as cus on cus.customer_id = od.customer_id
	group by 1,2
) as tmp
group by 1
order by 1

--XXXXXXXX
with cal_mau as( 
select year, round(avg(mau), 2) as avg_mau
from
(	select
		date_part('year', od.order_purchase_timestamp) as year,
		date_part('month', od.order_purchase_timestamp) as month,
		count (distinct cus.customer_unique_id) as mau
	from orders as od
	join customers as cus on od.customer_id = cus.customer_id
	group by 1,2
) as tmp
group by 1
),
cal_new_cust as( 
select date_part ('year', first_time_purchase) as year,
count (1) as new_customer
from
(	select customer_unique_id,
	min (od.order_purchase_timestamp) as first_time_purchase
	from orders as od
	join customers as cus on cus.customer_id = od.customer_id
	group by 1
) as tmp
group by 1
),
cal_repeat as (
select year,
count (distinct customer_unique_id) as repeating_customer
from
(	select date_part('year', od.order_purchase_timestamp) as year, cus.customer_unique_id,
	count (1) as purchase_frequency
	from orders as od
	join customers as cus on cus.customer_id = od.customer_id
	group by 1,2
	having count (1) > 1
) as tmp
group by 1
),
cal_aov as(
select year, round (avg(purchase_frequency),3) as avg_order_customer
from
(	select date_part('year', od.order_purchase_timestamp) as year, cus.customer_unique_id,
	count (1) as purchase_frequency
	from orders as od
	join customers as cus on cus.customer_id = od.customer_id
	group by 1,2
) as tmp
group by 1
)

select
	mau.year,
	mau.avg_mau,
	newc.new_customer,
	rep.repeating_customer,
	aov.avg_order_customer
from cal_mau as mau
join cal_new_cust as newc on mau.year = newc.year
join cal_repeat as rep on rep.year = mau.year
join cal_aov as aov on aov.year = mau.year