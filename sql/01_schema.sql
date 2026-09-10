-- Project 1: Business Performance & Sales Intelligence Platform
-- Oracle-compatible star-schema DDL

CREATE TABLE dim_customer (
    customer_id VARCHAR2(30) PRIMARY KEY,
    customer_name VARCHAR2(120), gender VARCHAR2(30), age NUMBER,
    city VARCHAR2(80), state VARCHAR2(80), customer_segment VARCHAR2(50),
    signup_date DATE, email VARCHAR2(160)
);

CREATE TABLE dim_product (
    product_id VARCHAR2(30) PRIMARY KEY,
    product_name VARCHAR2(160), category VARCHAR2(80), sub_category VARCHAR2(80),
    unit_cost NUMBER(12,2), unit_price NUMBER(12,2)
);

CREATE TABLE dim_store (
    store_id VARCHAR2(30) PRIMARY KEY,
    store_name VARCHAR2(120), region VARCHAR2(80), city VARCHAR2(80),
    state VARCHAR2(80), store_type VARCHAR2(50)
);

CREATE TABLE dim_date (
    date_key NUMBER PRIMARY KEY, full_date DATE NOT NULL, year NUMBER(4),
    quarter NUMBER(1), month NUMBER(2), month_name VARCHAR2(20),
    week_of_year NUMBER(2), day_of_month NUMBER(2), day_name VARCHAR2(20)
);

CREATE TABLE fact_orders (
    order_id VARCHAR2(30) PRIMARY KEY, order_date DATE NOT NULL,
    customer_id VARCHAR2(30) NOT NULL, product_id VARCHAR2(30) NOT NULL,
    store_id VARCHAR2(30) NOT NULL, quantity NUMBER NOT NULL,
    unit_price NUMBER(12,2), discount_pct NUMBER(8,4),
    sales_amount NUMBER(14,2), cost_amount NUMBER(14,2), profit NUMBER(14,2),
    return_flag NUMBER(1), payment_method VARCHAR2(40),
    order_status VARCHAR2(40), shipping_cost NUMBER(12,2),
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    CONSTRAINT fk_order_product FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    CONSTRAINT fk_order_store FOREIGN KEY (store_id) REFERENCES dim_store(store_id)
);

CREATE INDEX idx_fact_orders_date ON fact_orders(order_date);
CREATE INDEX idx_fact_orders_customer ON fact_orders(customer_id);
CREATE INDEX idx_fact_orders_product ON fact_orders(product_id);
CREATE INDEX idx_fact_orders_store ON fact_orders(store_id);
