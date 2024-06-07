##1 Data from menu_items.csv and order_details.csv is loaded into MySQL Workbench. Which is later cleaned & tranformed

##2  Basic SELECT Queries
SELECT * FROM restaurant.menu_items;

SELECT * FROM order_details 
limit 5


## 3 Filtering and Sorting
select item_name, category, price
from menu_items
order by price desc 


##4  Aggregate Functions
SELECT AVG(ROUND(price, 0)) AS average_rounded_price , count(*) as total_numbers_of_orders_placed
FROM menu_items;


##5 Joins
select o.*, m.*
from order_details o
join menu_items m
on o.item_id = m.menu_item_id



##6 Subqueries
SELECT item_name, price
	FROM menu_items
		WHERE price > (
		SELECT AVG(price)
		FROM menu_items
);
 
     
##7  Date and Time Functions
  SELECT MONTH(order_date) AS order_month, COUNT(*) AS order_count
FROM order_details
GROUP BY order_month;
 
    
    
##8 Group By and Having
-- First I have counted the item_count from category 
SELECT 
    category, 
    COUNT(item_name) AS item_count
FROM 
    menu_items
GROUP BY 
    category;
 
 -- Then i have shown the categories with the average price greater than $15.
 SELECT 
    category,
    AVG(price) AS average_price,
    COUNT(*) AS item_count
FROM 
    menu_items
GROUP BY 
    category
HAVING 
    AVG(price) > 15;


##9 Conditional Statements
SELECT 
    item_name,
    price,
    CASE 
        WHEN price > 20 THEN 'Expensive'
        ELSE 'Not Expensive'
    END AS Expensive
FROM 
    menu_items
    order by price desc;


##10 Data Modification 
UPDATE menu_items
SET price = 25
WHERE menu_item_id = 101;


#11 Data Modification 
INSERT INTO menu_items (menu_item_id ,item_name , category, price)
VALUES (133, 'New Dessert Item', 'Dessert', 16);



#12 Data Modification 
DELETE FROM order_details
WHERE order_id < 100;




## 13 Window Functions 
SELECT DISTINCT
    m.item_name, M.price,
    DENSE_RANK() OVER (ORDER BY m.price) AS item_rank
FROM 
    menu_items m
JOIN 
    order_details o ON m.menu_item_id = o.item_id;
    
    
    
    
 ## 14 Lead and lag
    SELECT 
    item_name,
    price AS current_price,
    ROUND(price - LAG(price) OVER (ORDER BY price), 2) AS price_difference_from_previous,
    ROUND(LEAD(price) OVER (ORDER BY price) - price, 2) AS price_difference_to_next
FROM 
    menu_items;



## 15 Common Table Expressions (CTE
WITH ExpensiveMenuItems AS (
    SELECT 
        item_name,
        price
    FROM 
        menu_items
    WHERE 
        price > 15
)
SELECT 
    COUNT(*) AS item_count
FROM 
    ExpensiveMenuItems;




## 16 Advanced Joins
   select o.order_id , m.*
    from order_details o
    right join menu_items m
     on o.item_id = m.menu_item_id
	order by order_id asc 
    
    
    
    
  ## 17 Unpivot Data
  SELECT 
    item_id,
    MAX(CASE WHEN property = 'item_name' THEN value END) AS item_name,
    MAX(CASE WHEN property = 'category' THEN value END) AS category,
    MAX(CASE WHEN property = 'price' THEN value END) AS price
FROM (
    SELECT 
        menu_item_id AS item_id,
        'item_name' AS property,
        item_name AS value
    FROM menu_items
    UNION ALL
    SELECT 
        menu_item_id AS item_id,
        'category' AS property,
        category AS value
    FROM menu_items
    UNION ALL
    SELECT 
        menu_item_id AS item_id,
        'price' AS property,
        price AS value
    FROM menu_items
) AS unpivoted
GROUP BY item_id;




## 18 Dynamic SQL
DROP PROCEDURE IF EXISTS FilterMenuItems;

DELIMITER $$

CREATE PROCEDURE FilterMenuItems(
    IN_Category VARCHAR(100),
    IN_MinPrice DECIMAL(10,2),
    IN_MaxPrice DECIMAL(10,2)
)
BEGIN
    SET @SQL = 'SELECT menu_item_id, item_name, category, price FROM menu_items WHERE 1=1';

    IF IN_Category IS NOT NULL THEN
        SET @SQL = CONCAT(@SQL, ' AND category = "', IN_Category, '"');
    END IF;

    IF IN_MinPrice IS NOT NULL THEN
        SET @SQL = CONCAT(@SQL, ' AND price >= ', IN_MinPrice);
    END IF;

    IF IN_MaxPrice IS NOT NULL THEN
        SET @SQL = CONCAT(@SQL, ' AND price <= ', IN_MaxPrice);
    END IF;

    PREPARE stmt FROM @SQL;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;




##19 Stored Procedure
DELIMITER //

CREATE PROCEDURE GetAveragePriceForCategory(
    IN_Category VARCHAR(100)
)
BEGIN
    SET @Category = IN_Category;
    
    SELECT AVG(price) AS AveragePrice
    FROM menu_items
    WHERE category = @Category;
END //

DELIMITER ;

CALL GetAveragePriceForCategory('Main');



## 20 Triggers
DELIMITER $$

CREATE TRIGGER OrderInsertTrigger AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    INSERT INTO order_log (order_id, action, timestamp)
    VALUES (NEW.order_id, 'Inserted', NOW());
END$$

DELIMITER ;
