select payment_type, count (1) as total
from payments
group by 1
order by 2 desc;

WITH num_payment as(
select payment_type, count (1) as total
from payments
group by 1
order by 2 desc
),
type_payment as(
select payment_type,
       sum(case when(date_part('year', order_purchase_timestamp)) = 2016 then 1 else 0 end) as year_2016,
       sum(case when(date_part('year', order_purchase_timestamp)) = 2017 then 1 else 0 end) as year_2017,
       sum(case when(date_part('year', order_purchase_timestamp)) = 2018 then 1 else 0 end) as year_2018
from payments as pay
join orders od on pay.order_id = od.order_id 
group by 1
order by 2 desc
)
select np.payment_type, tp.year_2016, tp.year_2017, tp.year_2018
from num_payment as np
join type_payment as tp on np.payment_type = tp.payment_type
