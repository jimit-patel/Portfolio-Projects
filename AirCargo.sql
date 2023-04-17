-- 1. Create a database named AirCargo
CREATE DATABASE IF NOT EXISTS AirCargo;
USE AirCargo;

SELECT *
FROM customer;

SELECT *
FROM passengers_on_flights;

SELECT *
FROM routes
ORDER BY route_id;

SELECT *
FROM ticket_details
ORDER BY aircraft_id;


-- 2. Query to modify table and asign Primary key to relavent column
ALTER TABLE customer
MODIFY customer_id VARCHAR(10) PRIMARY KEY;

ALTER TABLE routes
MODIFY route_id VARCHAR(10) PRIMARY KEY;


-- 3. Query to display the full name of the customer by extracting the first name and last name from the customer table.
SELECT CONCAT(first_name, " ", last_name) "Full Name"
FROM customer;


-- 4. Query to identify the number of passengers and total revenue in business class flight.
SELECT COUNT(customer_id) "Total Passengers", SUM(price_per_ticket * no_of_tickets) "Total Revenue"
FROM ticket_details
WHERE class_id = "bussiness";


-- 5. Query to display all the passengers (customers) who have travelled in routes 01 to 25.
SELECT DISTINCT(CONCAT(first_name, " ", last_name)) "Full Name", date_of_birth "Birth Date", gender "Gender"
FROM customer
WHERE customer_id 
	IN (
		SELECT customer_id
		FROM passengers_on_flights
		WHERE route_id BETWEEN 1 AND 25
	);
    
    
-- 6. Query to extract the customers who have registered and booked a ticket.
SELECT DISTINCT(CONCAT(first_name, " ", last_name)) "Full Name", date_of_birth "Birth Date", gender "Gender"
FROM customer
WHERE customer_id 
	IN (
		SELECT DISTINCT(customer_id)
		FROM ticket_details
	);
    
    
-- 7. Query to identify the customer’s first name and last name based on their customer ID and brand (Emirates).
SELECT first_name "First Name", last_name "Last Name"
FROM customer
WHERE customer_id 
	IN (
		SELECT DISTINCT(customer_id)
		FROM ticket_details
        	WHERE brand = "Emirates"
	);
    
    
-- 8. Query to identify the customers who have travelled by Economy Plus class.
SELECT DISTINCT(CONCAT(first_name, " ", last_name)) "Full Name", date_of_birth "Birth Date", gender "Gender"
FROM customer
WHERE customer_id 
	IN (
		SELECT DISTINCT(customer_id)
		FROM passengers_on_flights
        	WHERE class_id LIKE "%Plus"
	);


-- 9. Query to identify whether the revenue has crossed 10000.
SELECT IF(SUM(price_per_ticket * no_of_tickets) > 10000, "Yes", "No") AS "Revenue >10k"
FROM ticket_details;


-- 11 Query to find the maximum ticket price for each class using window functions on the ticket_details table.
SELECT class_id as "class", MAX(price_per_ticket)
FROM ticket_details
GROUP BY class_id;


-- 12. Query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table.
CREATE INDEX idx_route_id ON passengers_on_flights (route_id);
SELECT DISTINCT(CONCAT(first_name, " ", last_name)) "Full Name", date_of_birth "Birth Date", gender "Gender"
FROM customer
WHERE customer_id 
	IN (
		SELECT DISTINCT(customer_id)
		FROM passengers_on_flights
        	WHERE route_id = 4
	);


-- 13. For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.

-- 14. Query to calculate the total price of all tickets booked by a customer across different aircraft IDs.
SELECT aircraft_id " Aircraft ID", SUM(price_per_ticket) "Total Price"
FROM ticket_details
GROUP BY aircraft_id;


-- 15. Query to create a view with only business class customers along with the brand of airlines.
CREATE OR REPLACE VIEW business_class_customer AS
	SELECT customer_id, brand
	FROM ticket_details
	WHERE class_id = "Busscustomer_idiness";

    
-- 16. Query to create a stored procedure to get the details of all passengers flying between a range of routes defined in run time.


-- ................................................................. START PROCEDURE .................................................................
DROP PROCEDURE IF EXISTS passengers;

DELIMITER $$

USE aircargo$$
CREATE PROCEDURE passengers(start_range INT, end_range INT)
BEGIN
	SELECT DISTINCT(CONCAT(first_name, " ", last_name)) "Full Name", date_of_birth "Birth Date", gender "Gender"
	FROM customer
	WHERE customer_id 
		IN (
			SELECT DISTINCT(customer_id)
			FROM passengers_on_flights
			WHERE route_id BETWEEN start_range AND end_range
		);
END$$

DELIMITER ;
;
-- ................................................................. END PROCEDURE .................................................................

CALL passengers(20,30);



-- 17. Query to create a stored procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles.
-- ................................................................. START PROCEDURE .................................................................
DROP PROCEDURE IF EXISTS routes_2000;

DELIMITER $$

USE aircargo$$
CREATE PROCEDURE routes_2000()
BEGIN
	SELECT *
	FROM routes
	WHERE distance_miles > 2000;
END$$

DELIMITER ;
;
-- ................................................................. END PROCEDURE .................................................................

CALL routes_2000();



-- 18. Query to create a stored procedure that groups the distance travelled by each flight into three categories. 
-- The categories are, 
--	short distance travel (SDT) for >=0 AND <= 2000 miles, 
-- 	intermediate distance travel (IDT) for >2000 AND <=6500, and 
-- 	long-distance travel (LDT) for >6500.

-- ................................................................. START FUNCTION .................................................................
DROP FUNCTION IF EXISTS distance_category;

DELIMITER $$

CREATE FUNCTION distance_category(dist INT) RETURNS VARCHAR(40)
DETERMINISTIC
BEGIN
    
	CASE 
		WHEN dist >= 0 AND dist <= 2000 THEN  RETURN("Short Distance Travel");
		WHEN dist > 2000 AND dist <= 6500 THEN  RETURN("Intermediate Distance Travel"); 
		WHEN dist >= 6500 THEN  RETURN("Long Distance Travel"); 
	ELSE 
		RETURN("");
	END CASE;

END$$

DELIMITER ;
-- ................................................................. END FUNCTION .................................................................

-- ................................................................. START PROCEDURE .................................................................
DROP PROCEDURE IF EXISTS distance;

DELIMITER $$

USE aircargo$$
CREATE PROCEDURE distance()
BEGIN
	SELECT route_id "Route ID", flight_num "Flight Number", aircraft_id "Aircraft ID", distance_miles "Distance(Miles)", 
		distance_category(distance_miles) as "Distance Category"
	FROM routes;
END$$

DELIMITER ;
;
-- ................................................................. END PROCEDURE .................................................................

CALL distance();
