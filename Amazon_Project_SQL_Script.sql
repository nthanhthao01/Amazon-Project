--View dataset
SELECT * 
FROM [Amazon_Sale] 

--Standardize Date Format
SELECT Date, TRY_CONVERT(date, Date)
FROM Amazon_Sale

UPDATE Amazon_Sale
SET Date = TRY_CONVERT(date, Date)

--Standardize [Amount] to 2 decimal places
UPDATE Amazon_Sale 
SET Amount = ROUND(Amount,2)

--Change 0 and 1 to Yes and No in [B2B] column
SELECT B2B, CASE WHEN B2B = 1 THEN 'Yes' ELSE 'No' END 
FROM Amazon_Sale

ALTER TABLE Amazon_Sale
ALTER COLUMN B2B VARCHAR(3);

UPDATE Amazon_Sale
SET B2B = CASE WHEN B2B = 1 THEN 'Yes' ELSE 'No' END 

/* 
Drop unneeded cols:
   - [New], [PendinngS]: all NULL.
   - [fulfilled_by], index: not needed.
   - [ship_city]: mix of city, district, post office, not reliable for analysis.
   - [currency]: only contains 'INR' or NULL, no analytical value.
   - [ship_country]: only contains 'IN' or NULL, no analytical value.
*/
ALTER TABLE Amazon_Sale
DROP COLUMN New, PendingS, fulfilled_by, [index], ship_city, currency, ship_country

--Update values in [ship_state] column  
	-- 11 - Delhi
UPDATE Amazon_Sale
SET ship_state = 'Delhi'
WHERE ship_postal_code BETWEEN 110000 AND 119999;

	-- 12 and 13 - Haryana
UPDATE Amazon_Sale
SET ship_state = 'Haryana'
WHERE ship_postal_code BETWEEN 120000 AND 139999;

	-- 14 to 16 - Punjab
UPDATE Amazon_Sale
SET ship_state = 'Punjab'
WHERE ship_postal_code BETWEEN 140000 AND 169999;

	-- 17 - Himachal Pradesh
UPDATE Amazon_Sale
SET ship_state = 'Himachal Pradesh'
WHERE ship_postal_code BETWEEN 170000 AND 179999;

	-- 18 to 19 - Jammu & Kashmir
UPDATE Amazon_Sale
SET ship_state = 'Jammu & Kashmir'
WHERE ship_postal_code BETWEEN 180000 AND 199999;

	-- 20 to 28 - Uttar Pradesh and Uttaranchal
UPDATE Amazon_Sale
SET ship_state = 'Uttar Pradesh & Uttaranchal'
WHERE ship_postal_code BETWEEN 200000 AND 289999;

	-- 30 to 34 - Rajasthan
UPDATE Amazon_Sale
SET ship_state = 'Rajasthan'
WHERE ship_postal_code BETWEEN 300000 AND 349999;

	-- 36 to 39 - Gujarat
UPDATE Amazon_Sale
SET ship_state = 'Gujarat'
WHERE ship_postal_code BETWEEN 360000 AND 399999;

	-- 40 to 44 - Maharashtra
UPDATE Amazon_Sale
SET ship_state = 'Maharashtra'
WHERE ship_postal_code BETWEEN 400000 AND 449999;

	-- 45 to 49 - Madhya Pradesh and Chhattisgarh
UPDATE Amazon_Sale
SET ship_state = 'Madhya Pradesh & Chhattisgarh'
WHERE ship_postal_code BETWEEN 450000 AND 499999;

	-- 50 to 53 - Andhra Pradesh
UPDATE Amazon_Sale
SET ship_state = 'Andhra Pradesh'
WHERE ship_postal_code BETWEEN 500000 AND 539999;

	-- 56 to 59 - Karnataka
UPDATE Amazon_Sale
SET ship_state = 'Karnataka'
WHERE ship_postal_code BETWEEN 560000 AND 599999;

	-- 60 to 64 - Tamil Nadu
UPDATE Amazon_Sale
SET ship_state = 'Tamil Nadu'
WHERE ship_postal_code BETWEEN 600000 AND 649999;

	-- 67 to 69 - Kerala
UPDATE Amazon_Sale
SET ship_state = 'Kerala'
WHERE ship_postal_code BETWEEN 670000 AND 699999;

	-- 70 to 74 - West Bengal
UPDATE Amazon_Sale
SET ship_state = 'West Bengal'
WHERE ship_postal_code BETWEEN 700000 AND 749999;

	-- 75 to 77 - Orissa
UPDATE Amazon_Sale
SET ship_state = 'Orissa'
WHERE ship_postal_code BETWEEN 750000 AND 779999;

	-- 78 - Assam
UPDATE Amazon_Sale
SET ship_state = 'Assam'
WHERE ship_postal_code BETWEEN 780000 AND 789999;

	-- 79 - North Eastern
UPDATE Amazon_Sale
SET ship_state = 'North Eastern'
WHERE ship_postal_code BETWEEN 790000 AND 799999;

	-- 80 to 85 - Bihar and Jharkhand
UPDATE Amazon_Sale
SET ship_state = 'Bihar & Jharkhand'
WHERE ship_postal_code BETWEEN 800000 AND 859999;

	-- 90 to 99 - Army Postal Service (APS)
UPDATE Amazon_Sale
SET ship_state = 'Army Postal Service (APS)'
WHERE ship_postal_code BETWEEN 900000 AND 999999;
    
    -- Set 'Unknown' for null values
UPDATE Amazon_Sale
SET ship_state = 'Unknown'
WHERE ship_state IS NULL;

--Drop [ship_postal_code] column 
ALTER TABLE Amazon_Sale
DROP COLUMN ship_postal_code

--Check duplicates
;WITH cte AS (
	SELECT	*, ROW_NUMBER() OVER (PARTITION BY Order_ID ORDER BY Order_ID) AS row_num 
	FROM Amazon_Sale
)
SELECT *
FROM cte
WHERE row_num > 1
ORDER BY row_num desc

/*
I will skip the duplicate removing step, 
as the dataset does not include key fields like Product Name or Item ID, 
which are essential to accurately identify duplicates within multi-item orders.
*/

--Check null values across columns
SELECT	COUNT(CASE WHEN Order_ID is null THEN 1 END) as Order_ID_nulls,
		COUNT(CASE WHEN Date is null THEN 1 END) as Date_nulls,
		COUNT(CASE WHEN Status is null THEN 1 END) as Status_nulls,
		COUNT(CASE WHEN Fulfilment is null THEN 1 END) as Fulfilment_nulls,
		COUNT(CASE WHEN Sales_Channel is null THEN 1 END) as Sales_Channel_nulls,
		COUNT(CASE WHEN ship_service_level is null THEN 1 END) as ship_service_level_nulls,
		COUNT(CASE WHEN Category is null THEN 1 END) as Category_nulls,
		COUNT(CASE WHEN Size is null THEN 1 END) as Size_nulls,
		COUNT(CASE WHEN Courier_Status is null THEN 1 END) as Courier_Status_nulls,
		COUNT(CASE WHEN Qty is null THEN 1 END) as Qty_nulls,
		COUNT(CASE WHEN Amount is null THEN 1 END) as Amount_nulls,
		COUNT(CASE WHEN ship_state is null THEN 1 END) as ship_state_nulls,
		COUNT(CASE WHEN B2B is null THEN 1 END) as B2B_nulls
FROM Amazon_Sale

--Populate missing values in the [Amount] column  
;WITH AvgAmountCTE AS (
    SELECT 
        Fulfilment,
        Sales_Channel,
        ship_service_level,
        Category,
        Size,
        ship_state,
        B2B,
        Qty,
        ROUND(AVG(Amount),2) AS avg_amount
    FROM Amazon_Sale
    WHERE Amount IS NOT NULL
    GROUP BY Fulfilment, Sales_Channel, ship_service_level, 
				Category, Size, ship_state, B2B, Qty
)

UPDATE A
SET A.Amount = CTE.avg_amount
FROM Amazon_Sale A
JOIN AvgAmountCTE CTE ON 
    A.Fulfilment = CTE.Fulfilment AND
    A.Sales_Channel = CTE.Sales_Channel AND
    A.ship_service_level = CTE.ship_service_level AND
    A.Category = CTE.Category AND
    A.Size = CTE.Size AND
    A.ship_state = CTE.ship_state AND
    A.B2B = CTE.B2B AND
    A.Qty = CTE.Qty
WHERE A.Amount IS NULL;
/*
There are still 6103 NULL values in the [Amount] column out of 128976 rows (~4.7%), 
but I will ignore them as the percentage is relatively low.
*/

--------------------------------------------------------------------------------------------------------------------------------------------

-- Find orders with the same Order_ID and Status but different Courier Status after March
SELECT a1.Order_ID, a1.Status, a1.Courier_Status, a2.Courier_Status
FROM Amazon_Sale a1
JOIN Amazon_Sale a2
  ON a1.Order_ID = a2.Order_ID
 AND a1.Status = a2.Status
 AND a1.Courier_Status <> a2.Courier_Status
WHERE MONTH(a1.date) > 3;

--  Find orders with the same Order_ID and Status but different shipping service levels after March
SELECT a1.Order_ID, a1.Status, a1.ship_service_level, a2.ship_service_level
FROM Amazon_Sale a1
JOIN Amazon_Sale a2
  ON a1.Order_ID = a2.Order_ID
 AND a1.Status = a2.Status
 AND a1.ship_service_level <> a2.ship_service_level
WHERE MONTH(a1.date) > 3;

-- Group order statuses into categories (Success, Fail, Return, Ongoing) 
-- and count distinct orders in each group for months after March
SELECT 
    CASE
        WHEN Status = 'Shipped - Delivered to Buyer' THEN 'Success'
        WHEN Status IN (
            'Cancelled',
            'Shipped - Damaged',
            'Shipped - Lost in Transit',
            'Shipped - Rejected by Buyer'
        ) THEN 'Fail'
        WHEN Status IN (
            'Shipped - Returned to Seller',
            'Shipped - Returning to Seller'
        ) THEN 'Return'
        ELSE 'Ongoing'
    END AS Grouped_Status,
    COUNT(DISTINCT Order_ID) AS Distinct_Order_Count
FROM Amazon_Sale
where MONTH(date) > 3
GROUP BY 
    CASE
        WHEN Status = 'Shipped - Delivered to Buyer' THEN 'Success'
        WHEN Status IN (
            'Cancelled',
            'Shipped - Damaged',
            'Shipped - Lost in Transit',
            'Shipped - Rejected by Buyer'
        ) THEN 'Fail'
        WHEN Status IN (
            'Shipped - Returned to Seller',
            'Shipped - Returning to Seller'
        ) THEN 'Return'
        ELSE 'Ongoing'
    END;

-- Summarize total quantity and amount per order after March, 
-- then count how many distinct orders share the same total quantity

WITH cte AS (
    SELECT 
        [Order_ID],
        SUM(Qty) AS Total_Quantity,
        SUM(Amount) AS Total_Amount
    FROM Amazon_Sale
    WHERE MONTH(DATE) > 3
    GROUP BY [Order_ID]
    HAVING SUM(Qty) > 0
)
SELECT  
    Total_Quantity, 
    COUNT(DISTINCT Order_ID)
FROM cte
GROUP BY Total_Quantity
ORDER BY Total_Quantity ASC;


-- Calculate the average quantity per order for orders placed after March 

WITH cte AS (
    SELECT
        [Order_ID],
        SUM(Qty) AS Total_Quantity
    FROM Amazon_Sale
    WHERE MONTH(DATE) > 3
    GROUP BY [Order_ID]
)
SELECT 
    SUM(Total_Quantity) * 1.0 / COUNT(Order_ID) AS Average_Quantity_Per_Order
FROM cte;
