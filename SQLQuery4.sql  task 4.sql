
-- 1. Total number of products in the catalog
SELECT COUNT(*) AS total_products_count
FROM production.products;

-- 2. Display average, lowest, and highest product price
SELECT 
    AVG(list_price) AS average_price,
    MIN(list_price) AS minimum_price,
    MAX(list_price) AS maximum_price
FROM production.products;

-- 3. How many products are there per category?
SELECT c.category_name, COUNT(*) AS number_of_products
FROM production.products p
INNER JOIN production.categories c ON p.category_id = c.category_id
GROUP BY c.category_name;

-- 4. Orders placed at each store location
SELECT s.store_name, COUNT(o.order_id) AS orders_count
FROM sales.orders o
INNER JOIN sales.stores s ON o.store_id = s.store_id
GROUP BY s.store_name;

-- 5. Display formatted customer names (UPPER first name, lower last name)
SELECT TOP 10 
    UPPER(c.first_name) AS first_name,
    LOWER(c.last_name) AS last_name
FROM sales.customers c;

-- 6. First 10 products and how many characters in their names
SELECT TOP 10 
    p.product_name,
    LEN(p.product_name) AS name_length
FROM production.products p;

-- 7. Extract area code from phone numbers of first 15 customers
SELECT TOP 15 
    customer_id,
    phone,
    LEFT(phone, 3) AS area_code_prefix
FROM sales.customers;

-- 8. Order dates with extracted year and month, plus today’s date
SELECT TOP 10 
    order_id,
    order_date,
    YEAR(order_date) AS year_part,
    MONTH(order_date) AS month_part,
    GETDATE() AS today_date
FROM sales.orders;

-- 9. Products and their categories - sample of 10
SELECT TOP 10 
    p.product_name,
    c.category_name
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id;

-- 10. Orders with customer full names - top 10
SELECT TOP 10 
    c.first_name + ' ' + c.last_name AS full_customer_name,
    o.order_date
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id;

-- 11. List products with associated brands, fallback if missing
SELECT 
    p.product_name,
    COALESCE(b.brand_name, 'No Brand') AS associated_brand
FROM production.products p
LEFT JOIN production.brands b ON p.brand_id = b.brand_id;

-- 12. Products priced above average
SELECT 
    product_name,
    list_price
FROM production.products
WHERE list_price > (
    SELECT AVG(list_price) FROM production.products
);

-- 13. Customers who have made purchases (using IN with subquery)
SELECT customer_id, first_name + ' ' + last_name AS full_name
FROM sales.customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id FROM sales.orders
);

-- 14. For each customer, how many orders have they placed?
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    (SELECT COUNT(*) FROM sales.orders o WHERE o.customer_id = c.customer_id) AS orders_total
FROM sales.customers c;

-- 15. Create view for easy product lookup and query expensive ones
CREATE VIEW production.easy_product_list AS
SELECT 
    p.product_name,
    c.category_name,
    p.list_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id;

-- Select from view where price is over 100
SELECT * FROM production.easy_product_list WHERE list_price > 100;

-- 16. Create view for customer contact info, then find California customers
CREATE VIEW  sales.customer_info AS
SELECT 
    customer_id,
    first_name + ' ' + last_name AS full_name,
    email,
    city + ', ' + state AS location
FROM sales.customers;

-- Query customers based in CA
SELECT * FROM sales.customer_info WHERE location LIKE '%, CA';

-- 17. Products priced from $50 to $200, sorted cheapest first
SELECT 
    product_name,
    list_price
FROM production.products
WHERE list_price BETWEEN 50 AND 200
ORDER BY list_price;

-- 18. Count customers by state, most populous states on top
SELECT 
    state,
    COUNT(*) AS customers_count
FROM sales.customers
GROUP BY state
ORDER BY customers_count DESC;

-- 19. Most expensive item in each category group
SELECT 
    c.category_name,
    p.product_name,
    p.list_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
WHERE p.list_price = (
    SELECT MAX(p2.list_price)
    FROM production.products p2
    WHERE p2.category_id = p.category_id
);

-- 20. Show each store, its city, and number of orders received
SELECT 
    s.store_name,
    s.city,
    COUNT(o.order_id) AS orders_placed
FROM sales.stores s
LEFT JOIN sales.orders o ON s.store_id = o.store_id
GROUP BY s.store_name, s.city;

-- End of version 2 queries
