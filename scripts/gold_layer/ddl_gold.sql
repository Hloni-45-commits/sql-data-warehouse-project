/*
****************************
Create Gold Layer -  Views
****************************

Objective : 
Create views for the gold layer in the data warehouse.
The gold layer represents the dimension and fact tables in a star schema data model.
The views can be queried directly for analytics and reporting.
*/

--===== Create Dim Table : gold.dim_customers ==========--
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers ;
GO
CREATE VIEW gold.dim_customers AS 
SELECT 
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	cl.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr ELSE COALESCE(ca.gen,'N/A') END AS gender,
	CAST(ca.bdate AS DATE) AS birth_date,
	ci.cst_create_date AS create_date 

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101  cl ON ci.cst_key = cl.cid;

GO
--===== Create Dim Table : gold.dim_products ==========--
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products ;
GO

CREATE VIEW gold.dim_products AS 
SELECT
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date	
	
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL; -- Filter out historical data 

GO
--===== Create Fact Table : gold.fact_sales ==========--
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales ;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
	sls_ord_num AS order_number,
	--pd.product_number,
	pd.product_key,
	c.customer_key,
	--sls_prd_key,
	--sls_cust_id,
	sls_order_dt AS order_date,
	sls_ship_dt AS shipping_date,
	sls_due_dt AS due_date,
	sls_sales AS sales,
	sls_quantity AS quantity,
	sls_price AS price

FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pd ON sd.sls_prd_key = pd.product_number
LEFT JOIN gold.dim_customers c ON sd.sls_cust_id = c.customer_id;

GO



