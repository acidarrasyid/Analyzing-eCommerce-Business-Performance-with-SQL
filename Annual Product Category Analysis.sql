create table total_revenue_year as
select date_part('year', od.order_purchase_timestamp) as year,
sum (revenue_per_order) as revenue
from
(	select order_id,
	sum (price) as revenue_per_order
	from order_item
	group by 1
) as tmp
join orders as od on tmp.order_id = od.order_id
where od.order_status = 'delivered'
group by 1;

create table cancel_order_year as
select date_part('year', order_purchase_timestamp) as year,
count (1) as canceled_order
from orders
where order_status = 'canceled'
group by 1;

create table product_top_category_year as
select year, product_category_name, revenue
from
(	select 	date_part ('year', od.order_purchase_timestamp) as year,
			pd.product_category_name,
			sum (oi.price + oi.freight_value) as revenue,
			rank() over (partition by date_part ('year', od.order_purchase_timestamp) order by sum (oi.price + oi.freight_value) desc) as rangking
	from order_item as oi
	join orders as od on od.order_id = oi.order_id
	join product as pd on pd.product_id = oi.product_id
	where od.order_status = 'delivered'
	group by 1,2
	order by 1
) as tmp
where rangking = 1;

create table product_top_cancel_year as
select year, product_category_name, num_canceled
from
(	select 	date_part ('year', od.order_purchase_timestamp) as year,
			pd.product_category_name,
			count (1) as num_canceled,
			rank() over (partition by date_part ('year', od.order_purchase_timestamp) order by count (1) desc) as rangking
	from order_item as oi
	join orders as od on od.order_id = oi.order_id
	join product as pd on pd.product_id = oi.product_id
	where od.order_status = 'canceled'
	group by 1,2
) as tmp
where rangking = 1;

select
	ptcy.year,
	ptcy.product_category_name as top_product_revenue,
	ptcy.revenue as category_revenue,
	try.revenue as total_revenue,
	ptc.product_category_name as cancel_product_category,
	ptc.num_canceled as category_num_cancel,
	coy.canceled_order as total_cancel
from product_top_category_year as ptcy
join total_revenue_year as try on ptcy.year = try.year
join product_top_cancel_year as ptc on ptcy.year = ptc.year
join cancel_order_year as coy on coy.year = ptcy.year;
