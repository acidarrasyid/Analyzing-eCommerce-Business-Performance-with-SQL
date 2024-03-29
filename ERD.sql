create table customers (
	customer_id varchar,
	customer_unique_id varchar,
	customer_zip_code_prefix int,
	customer_city varchar,
	customer_state varchar
);
create table geolocation (
	geo_zip_code_prefix varchar,
	geo_lat varchar,
	geo_lng varchar,
	geo_city varchar,
	geo_state varchar
);
create table order_item (
	order_id varchar,
	order_item_id int,
	product_id varchar,
	seller_id varchar,
	shipping_limit_date timestamp,
	price float8,
	freight_value float8
);
create table payments (
	order_id varchar,
	payment_sequential int,
	payment_type varchar,
	payment_installment int,
	payment_value float8
);
create table reviews (
	review_id varchar,
	order_id varchar,
	review_score int, 
	review_comment_title varchar,
	review_comment_message varchar,
	review_creation_date timestamp,
	review_answer timestamp
);
create table orders (
	order_id varchar,
	customer_id varchar,
	order_status varchar,
	order_purchase_timestamp timestamp,
	order_approved_at timestamp,
	order_delivered_carrier_date timestamp,
	order_delivered_customer_date timestamp,
	order_estimated_delivered_date timestamp
);
create table product (
index int,
product_id varchar,
product_category_name varchar,
product_name_lenght float8,
product_description_lenght float8,
product_photos_qty float8,
product_weight_g float8,
product_length_cm float8,
product_height_cm float8,
product_width_cm float8
);
create table sellers (
	seller_id varchar,
	seller_zip_code int,
	seller_city varchar,
	seller_state varchar
);

--alter table PK & FK
alter table customers add primary key (customer_id);
alter table orders add foreign key (customer_id) references customers;
alter table orders add primary key (order_id);
alter table order_item add foreign key (order_id) references orders;
alter table payments add foreign key (order_id) references orders;
alter table reviews add foreign key (order_id) references orders;
alter table sellers add primary key (seller_id);
alter table order_item add foreign key (seller_id) references sellers;
alter table product add primary key (product_id);
alter table order_item add foreign key (product_id) references product;
alter table geolocation add primary key (geo_zip_code_prefix);
alter table customers add foreign key (customer_zip_code_prefix) references geolocation;