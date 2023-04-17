-- 1. Create a database named ScienceQtech_employee
CREATE DATABASE IF NOT EXISTS ScienceQtech_employee;
USE ScienceQtech_employee;

SELECT *
FROM data_science_team;

SELECT *
FROM emp_record_table;

SELECT *
FROM proj_table;


-- 2. Asigned Primary Key to emp_id and project_id column of data_science_team & proj_table respectively.
ALTER TABLE data_science_team
MODIFY emp_id VARCHAR(20) PRIMARY KEY;

ALTER TABLE proj_table
MODIFY project_id VARCHAR(20) PRIMARY KEY;


-- 3. Query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table.
SELECT emp_id, first_name, last_name, gender, dept 
FROM emp_record_table;


-- 4. Query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is less than 2, more than 4 and between 2-4.
SELECT first_name, last_name, gender, dept, emp_rating FROM emp_record_table
WHERE emp_rating < 2;

SELECT first_name, last_name, gender, dept, emp_rating FROM emp_record_table
WHERE emp_rating > 4;

SELECT first_name, last_name, gender, dept, emp_rating FROM emp_record_table
WHERE emp_rating BETWEEN 2 AND 4;


-- 5. Query to concatenate the FIRST_NAME and the LAST_NAME of employees of the Finance department.
SELECT CONCAT(first_name, " ", last_name) as "NAME" FROM emp_record_table
WHERE dept = "finance";


-- 6. Query to fetch list only of those employees who have someone reporting to them. Also, show the number of reporters (including the President).
SELECT e.emp_id, e.first_name, e.last_name, e2.reporting_no 
FROM emp_record_table e
INNER JOIN (
	SELECT manager_id, COUNT(manager_id) as reporting_no 
	FROM emp_record_table 
	GROUP BY manager_id
    ) e2
ON e.emp_id = e2.manager_id;


-- 7. Query to fetch list all the employees from the healthcare and finance departments using union.
SELECT * FROM emp_record_table 
WHERE dept = 'mealthcare'
UNION
SELECT * FROM emp_record_table 
WHERE dept = 'finance';


-- 8. Query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, EMP_RATING grouped by dept, 
-- and the respective employee rating along with the max emp rating for the department.
SELECT emp_id, first_name, last_name, role, dept, emp_rating, MAX(emp_rating) OVER (PARTITION BY dept) as 'MAX_Rating' 
FROM emp_record_table;


-- 9. Query to calculate the minimum and the maximum salary of the employees for each role.
SELECT emp_id, first_name, last_name, role, salary, MAX(salary) OVER (PARTITION BY role) as 'MAX_Salary', MIN(salary) OVER (PARTITION BY role) as 'MIN_Salary' 
FROM emp_record_table;


-- 10. Query to assign ranks to each employee based on their experience.
SELECT emp_id, first_name, last_name, exp,  RANK() OVER (ORDER BY exp) as emp_rank
FROM emp_record_table
ORDER BY emp_rank DESC;

SELECT emp_id, first_name, last_name, exp,  DENSE_RANK() OVER (ORDER BY exp) as emp_rank 
FROM emp_record_table
ORDER BY emp_rank DESC;

-- 11. Query to create a view that displays employees in various countries whose salary is more than six thousand.
CREATE OR REPLACE VIEW emp_country AS
	SELECT emp_id, first_name, last_name, country 
	FROM emp_record_table
	WHERE salary > 6000;


-- 12. Query to find employees with experience of more than ten years.
SELECT emp_id, first_name, last_name, exp 
FROM emp_record_table
WHERE emp_id IN (
	SELECT emp_id 
	FROM emp_record_table 
	WHERE exp > 10);


-- 13. Query to create a stored procedure to retrieve the details of the employees whose experience is more than three years.
-- ................................................................. START PROCEDURE .................................................................
DROP PROCEDURE IF EXISTS exp_3;

DELIMITER $$

USE ScienceQtech_employee$$
CREATE PROCEDURE exp_3()
BEGIN
	SELECT emp_id, first_name, last_name, exp 
	FROM emp_record_table 
	WHERE exp > 3;
END$$

DELIMITER ;
;

CALL exp_3();
-- ................................................................. END PROCEDURE .................................................................


-- 14. Query to create stored functions in the project table to check whether the job profile assigned to each employee in the data science team matches the organization’s set standard.
-- ................................................................. START FUNCTION .................................................................
DROP FUNCTION IF EXISTS Project_assignment;

DELIMITER $$

CREATE FUNCTION Project_assignment(id VARCHAR(20)) RETURNS VARCHAR(40)
DETERMINISTIC
BEGIN
	DECLARE standard VARCHAR(40);
	DECLARE experiance INT;
    
    SELECT exp INTO experiance 
    FROM emp_record_table e
    WHERE e.emp_id = id;
    
	CASE 
		WHEN experiance <= 2 THEN  SET standard = "JUNIOR DATA SCIENTIST";
		WHEN experiance BETWEEN 2 AND 5 THEN  SET standard = "ASSOCIATE DATA SCIENTIST" ; 
		WHEN experiance BETWEEN 5 AND 10 THEN  SET standard = "SENIOR DATA SCIENTIST"; 
		WHEN experiance BETWEEN 10 AND 12 THEN  SET standard = "LEAD DATA SCIENTIST";
		WHEN experiance > 12 THEN  SET standard = "MANAGER"; 
	ELSE 
		SET standard = "";
	END CASE;
    RETURN(standard);
END$$

DELIMITER ;

SELECT emp_id, project_assignment(emp_id) AS standard, EXP 
FROM emp_record_table;
-- ................................................................. END FUNCTION .................................................................


-- 15.Query to calculate the bonus for all the employees, based on their ratings and salaries (Bonus formula: 5% of salary * employee rating).
SELECT emp_id, first_name,emp_rating, salary, ROUND(0.05*emp_rating*salary) AS bonus
FROM emp_record_table;   


-- 16. Query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.
SELECT continent, country, ROUND(AVG(salary) OVER (PARTITION BY continent,country)) AS avg_salary 
FROM emp_record_table;
