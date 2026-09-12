USE ecommerce_logistics;

-- ==========================================================
-- E-COMMERCE LOGISTICS ANALYTICS PROJECT
-- BUSINESS ANALYTICS QUERIES
-- Author : Nunavath Manojkumar
-- ==========================================================


-- ==========================================================
-- SECTION 1 : DELIVERY PERFORMANCE ANALYSIS
-- ==========================================================

-- Query 1 : Total Orders by Delivery Status

SELECT
    delivery_status,
    COUNT(*) AS total_orders
FROM Shipments
GROUP BY delivery_status;


-- Query 2 : Overall On-Time Delivery KPI

SELECT
ROUND(
SUM(CASE
        WHEN delivery_status='On Time' THEN 1
        ELSE 0
    END)*100.0/COUNT(*),2
) AS on_time_delivery_rate
FROM Shipments;


-- Query 3 : Shipment Mode vs Delivery Status

SELECT
    shipment_mode,
    delivery_status,
    COUNT(*) AS total_orders
FROM Shipments
GROUP BY shipment_mode, delivery_status
ORDER BY shipment_mode;


-- Query 4 : On-Time Rate by Shipment Mode

SELECT
    shipment_mode,

ROUND(
SUM(CASE
        WHEN delivery_status='On Time' THEN 1
        ELSE 0
    END)*100.0/COUNT(*),2
) AS on_time_rate

FROM Shipments
GROUP BY shipment_mode
ORDER BY on_time_rate DESC;


-- Query 5 : Warehouse-wise Delay Count

SELECT
    o.warehouse_block,
    s.delivery_status,
    COUNT(*) AS total_orders

FROM Orders o
JOIN Shipments s
ON o.order_id=s.order_id

GROUP BY o.warehouse_block,s.delivery_status
ORDER BY o.warehouse_block;


-- Query 6 : Warehouse Performance Ranking

SELECT
    o.warehouse_block,

ROUND(
SUM(CASE
        WHEN s.delivery_status='On Time' THEN 1
        ELSE 0
    END)*100.0/COUNT(*),2
) AS on_time_rate

FROM Orders o
JOIN Shipments s
ON o.order_id=s.order_id

GROUP BY o.warehouse_block
ORDER BY on_time_rate DESC;



-- ==========================================================
-- SECTION 2 : CUSTOMER ANALYTICS
-- ==========================================================

-- Query 7 : Average Customer Rating by Delivery Status

SELECT
    s.delivery_status,
    ROUND(AVG(c.customer_rating),2) AS avg_customer_rating

FROM Customers c
JOIN Shipments s
ON c.order_id=s.order_id

GROUP BY s.delivery_status;


-- Query 8 : Customer Care Calls Analysis

SELECT
    s.delivery_status,
    ROUND(AVG(c.customer_care_calls),2) AS avg_care_calls

FROM Customers c
JOIN Shipments s
ON c.order_id=s.order_id

GROUP BY s.delivery_status;


-- ==========================================================
-- SECTION 3 : PRODUCT & DISCOUNT ANALYTICS
-- ==========================================================

-- Query 9 : Product Importance vs Delivery

SELECT
    o.product_importance,
    s.delivery_status,
    COUNT(*) AS total_orders

FROM Orders o
JOIN Shipments s
ON o.order_id=s.order_id

GROUP BY o.product_importance,s.delivery_status
ORDER BY o.product_importance;


-- Query 10 : Discount Band Performance

SELECT

CASE
    WHEN discount_offered<10 THEN 'Low'
    WHEN discount_offered BETWEEN 10 AND 20 THEN 'Medium'
    ELSE 'High'
END AS discount_band,

ROUND(
SUM(CASE
        WHEN s.delivery_status='On Time' THEN 1
        ELSE 0
    END)*100.0/COUNT(*),2
) AS on_time_rate

FROM Orders o
JOIN Shipments s
ON o.order_id=s.order_id

GROUP BY discount_band
ORDER BY on_time_rate DESC;



-- ==========================================================
-- SECTION 4 : ADVANCED SQL
-- ==========================================================

-- Query 11 : Top 5 Heaviest Delayed Orders

SELECT
    o.order_id,
    o.weight_in_gms,
    o.cost_of_product,
    o.warehouse_block

FROM Orders o
JOIN Shipments s
ON o.order_id=s.order_id

WHERE s.delivery_status='Delayed'

ORDER BY o.weight_in_gms DESC
LIMIT 5;


-- Query 12 : Rank Warehouses using Window Function

SELECT
    warehouse_block,
    on_time_rate,

RANK() OVER(
ORDER BY on_time_rate DESC
) AS warehouse_rank

FROM(

SELECT
    o.warehouse_block,

ROUND(
SUM(CASE
        WHEN s.delivery_status='On Time' THEN 1
        ELSE 0
    END)*100.0/COUNT(*),2
) AS on_time_rate

FROM Orders o
JOIN Shipments s
ON o.order_id=s.order_id

GROUP BY o.warehouse_block

) AS warehouse_summary;