/* 1. Tạo các bảng Dim trên SQL */
-- dim_product
CREATE TABLE dim_product (
	product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(255),
    unit_price INT,
    brand VARCHAR(100),
    industry VARCHAR(100),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_type VARCHAR(100),
    pack_size INT,
    unit VARCHAR(20),
    price_segment VARCHAR(10),
    is_private_label VARCHAR(10),
    is_ready_to_eat VARCHAR(10),
	shelf_life_days INT,
    supplier VARCHAR(100)
);

-- dim_store
CREATE TABLE dim_store (
	store_id VARCHAR(10) PRIMARY KEY,
    store_name VARCHAR(255),
    location_type VARCHAR(100),
    floor_area_sqm INT,
    num_pos VARCHAR(10),
    staff_count_peak INT
);

-- dim_time
CREATE TABLE dim_time (
	hour_time INT PRIMARY KEY,
    time_block VARCHAR(50),
    shift_name VARCHAR(50),
    traffic_status VARCHAR(50),
    traffic_description VARCHAR(100),
    is_peak_hour TINYINT(1)
);

-- dim_customer
CREATE TABLE dim_customer (
	customer_id VARCHAR(50) PRIMARY KEY,
    customer_type VARCHAR(50),
    occupation VARCHAR(100)
);

-- dim_promotion
CREATE TABLE dim_promotion (
	promo_id VARCHAR(100) PRIMARY KEY,
	promo_name VARCHAR(255),
	promo_type VARCHAR(100),
	promo_subtype VARCHAR(100),
	discount_type VARCHAR(100),
	discount_value DECIMAL(18, 0),
	min_purchase DECIMAL(18, 0),
	start_date DATE,
	end_date DATE,
	start_time TIME,
	end_time TIME,
	applicable_category VARCHAR(100),
	applicable_sku VARCHAR(50),
	funding_type VARCHAR(50),
	partner_name VARCHAR(100),
	is_stackable VARCHAR(10)
);
CREATE TABLE fact_wastage (
	wastage_id INT PRIMARY KEY AUTO_INCREMENT,
    waste_date DATE,
    store_id VARCHAR(10),
    product_id VARCHAR(10),
    quantity INT,
    waste_reason VARCHAR(50)
);

/* 2. Tạo bảng Fact và nạp dữ liệu trên SQL */
-- fact_transaction
CREATE TABLE fact_transaction (
	transaction_id VARCHAR(100),
	transaction_date DATE,
	transaction_hour TIME,
	store_id VARCHAR(10),
	pos_id VARCHAR(10),
	customer_id VARCHAR(50),
	product_id VARCHAR(50),
	quantity INT,
	unit_price DECIMAL(18, 0),
	gross_amount DECIMAL(18, 0),
	promo_id VARCHAR(100),
	discount_amount DECIMAL(18, 0),
	payment_method VARCHAR(50)
);

-- Nạp dữ liệu
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'D:/Portfolio Project/7-eleven/dataset_version 2/fact_transaction.csv' 
INTO TABLE fact_transaction
CHARACTER SET utf8mb4 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;

/* 3. Thiết lập Relationship */
-- 1. Nối fact với dim_product
ALTER TABLE fact_transaction
ADD CONSTRAINT fk_fact_product
FOREIGN KEY (product_id) REFERENCES dim_product(product_id);

-- 2. Nối fact với dim_store
ALTER TABLE fact_transaction
ADD CONSTRAINT fk_fact_store
FOREIGN KEY (store_id) REFERENCES dim_store(store_id);

-- 3. Nối fact với dim_promotion
ALTER TABLE fact_transaction
ADD CONSTRAINT fk_fact_promotion
FOREIGN KEY (promo_id) REFERENCES dim_promotion(promo_id);

-- Top Combo + Revenue
CREATE VIEW vw_product_combo AS
SELECT 
	p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(DISTINCT a.transaction_id) AS order_count,
    SUM(a.gross_amount - a.discount_amount
		+ b.gross_amount - b.discount_amount) AS revenue
FROM fact_transaction a
JOIN fact_transaction b
	ON a.transaction_id = b.transaction_id
JOIN dim_product p1
	ON a.product_id = p1.product_id
JOIN dim_product p2
	ON b.product_id = p2.product_id
WHERE a.product_id < b.product_id
GROUP BY product_1, product_2
ORDER BY order_count DESC;

SELECT * FROM vw_product_combo;
--

/* 3. Câu hỏi phân tích */
-- 1. Peak Hour Optimization
-- Q1.1. Lượng đơn hàng và doanh thu phân bổ theo từng giờ trong ngày như thế nào? (Đỉnh điểm có đúng là 12:00 - 12:30 không?)
SELECT
    dt.hour_time,
    dt.time_block,
    COUNT(DISTINCT ft.transaction_id) AS total_orders,
    SUM(ft.gross_amount - ft.discount_amount) AS total_revenue
FROM fact_transaction ft
JOIN dim_time dt
ON HOUR(ft.transaction_hour) = dt.time_block
GROUP BY dt.hour_time, dt.time_block
ORDER BY total_revenue DESC, total_orders DESC;

-- Q1.2. Vào buổi sáng (6:00 - 9:00), sản phẩm nào đang mang lại doanh thu cao nhất?
SELECT 
    dp.product_name,
    SUM(ft.gross_amount - ft.discount_amount) AS total_revenue
FROM fact_transaction ft
JOIN dim_product dp
ON dp.product_id = ft.product_id
WHERE HOUR(ft.transaction_hour) BETWEEN 6 AND 9
GROUP BY dp.product_name
ORDER BY total_revenue DESC;

-- Q1.3. Khách hàng thường mua kết hợp những món nào với nhau vào buổi sáng? (Để tìm ra "tổ hợp" làm Combo chuẩn nhất, ví dụ: Bánh mì + Cà phê).
WITH MorningSales AS (
SELECT 
	ft.transaction_id,
    dp.product_name,
    SUM(ft.gross_amount - ft.discount_amount) AS total_revenue
FROM fact_transaction ft
JOIN dim_product dp
ON dp.product_id = ft.product_id
WHERE HOUR(ft.transaction_hour) BETWEEN 6 AND 9
)
SELECT * FROM vw_product_combo
limit 10;

-- Q1.4. Giá trị đơn hàng trung bình (AOV - Average Order Value) trong các khung giờ cao điểm là bao nhiêu?
SELECT
	SUM(gross_amount - discount_amount) / COUNT(DISTINCT transaction_id) AS Peak_Hour_AOV
FROM fact_transaction
WHERE (HOUR(transaction_hour) BETWEEN 7 AND 9)
OR (HOUR(transaction_hour) BETWEEN 10 AND 11);

-- 2. Sales velocity
-- Q2.1. Tốc độ bán (Sales velocity) của các món "Best-seller" diễn ra như thế nào từ 7:00 đến 9:00 sáng?
WITH BestSellers AS (
SELECT product_id
FROM fact_transaction
GROUP BY product_id
ORDER BY SUM(quantity) DESC
LIMIT 3
)
SELECT 
    dp.product_name,
CONCAT(HOUR(ft.transaction_hour), ':', LPAD(FLOOR(MINUTE(ft.transaction_hour) / 15) * 15, 2, '0')) AS Time_Block_15Min,
    SUM(ft.quantity) AS Units_Sold
FROM fact_transaction ft
JOIN dim_product dp ON ft.product_id = dp.product_id
WHERE HOUR(ft.transaction_hour) BETWEEN 7 AND 8 -- Khung 7:00:00 đến 8:59:59
  AND ft.product_id IN (SELECT product_id FROM BestSellers)
GROUP BY 
    dp.product_name, 
    Time_Block_15Min
ORDER BY 
    Time_Block_15Min;
--
SELECT 
    dp.product_name,
    SUM(ft.quantity) AS Total_Units_Sold,
    SUM(ft.quantity) / 2.0 AS Velocity_Per_Hour
FROM fact_transaction ft
JOIN dim_product dp ON ft.product_id = dp.product_id
WHERE HOUR(ft.transaction_hour) BETWEEN 7 AND 9
GROUP BY 
    dp.product_name
ORDER BY 
    Velocity_Per_Hour DESC
LIMIT 5;

-- Q2.2. Tốc độ bán (Sales velocity) của các món "Best-seller" diễn ra như thế nào từ 10:00 đến 12:00 trua?
SELECT 
    dp.product_name,
    SUM(ft.quantity) AS Total_Units_Sold,
    SUM(ft.quantity) / 2.0 AS Velocity_Per_Hour
FROM fact_transaction ft
JOIN dim_product dp ON ft.product_id = dp.product_id
WHERE HOUR(ft.transaction_hour) BETWEEN 10 AND 12
GROUP BY 
    dp.product_name
ORDER BY 
    Velocity_Per_Hour DESC
LIMIT 5;

-- 3. Category Performance
-- Q3.1. Đóng góp doanh thu của nhóm "Ready-to-eat" (Thức ăn chế biến sẵn) chiếm bao nhiêu % trong toàn bộ ngành hàng Food?
SELECT 
    SUM(CASE WHEN dp.category = 'Ready-to-eat' THEN (ft.gross_amount - ft.discount_amount) ELSE 0 END) AS RTE_Revenue,  -- 1. Tính doanh thu riêng nhóm Ready-to-eat
    SUM(ft.gross_amount - ft.discount_amount) AS Total_Food_Revenue, -- 2. Tính tổng doanh thu toàn bộ nhóm Food
    ROUND(
        (SUM(CASE WHEN dp.category = 'Ready-to-eat' THEN (ft.gross_amount - ft.discount_amount) ELSE 0 END) * 100.0) 
        / SUM(ft.gross_amount - ft.discount_amount), 
    2) AS RTE_Contribution_Pct -- 3. Tính phần trăm đóng góp
FROM fact_transaction ft
JOIN dim_product dp ON ft.product_id = dp.product_id
WHERE dp.industry = 'Food';

-- Q3.2. Top 5 sản phẩm mang lại doanh thu tốt trong nhóm Ready-to-eat là gì để ưu tiên diện tích kệ trưng bày?
SELECT 
    dp.product_name,
    SUM(ft.quantity) AS Total_Units_Sold,
    SUM(ft.gross_amount - ft.discount_amount) AS Net_Revenue
FROM fact_transaction ft
JOIN dim_product dp ON ft.product_id = dp.product_id
WHERE dp.category = 'Ready-to-eat'
GROUP BY 
    dp.product_name
ORDER BY 
    Net_Revenue DESC
LIMIT 5;

-- Q3.3. Tỷ trọng doanh thu của hàng Nhãn riêng (Private Label Sales Share - tức là hàng do chính Fast24h sản xuất) so với hàng của các thương hiệu khác là bao nhiêu?
SELECT 
    SUM(CASE WHEN dp.is_private_label = 'TRUE' THEN (ft.gross_amount - ft.discount_amount) ELSE 0 END) AS Private_Label_Revenue,
    SUM(ft.gross_amount - ft.discount_amount) AS Total_Revenue,
    ROUND(
        (SUM(CASE WHEN dp.is_private_label = 'TRUE' THEN (ft.gross_amount - ft.discount_amount) ELSE 0 END) * 100.0) 
        / NULLIF(SUM(ft.gross_amount - ft.discount_amount), 0), 
    2) AS Private_Label_Share_Pct
FROM fact_transaction ft
JOIN dim_product dp ON ft.product_id = dp.product_id;

select * from dim_product;