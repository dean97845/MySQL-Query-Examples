USE sakila;

/*Actors by name*/
SELECT first_name, last_name FROM sakila.actor;

/*Concatenate and uppercase actor first & last name*/
SELECT first_name, last_name, UCASE(CONCAT(first_name, ' ', last_name)) AS "Actor Name" FROM sakila.actor;

/*List info for actor with first name 'Joe'*/
SELECT actor_id, first_name, last_name FROM sakila.actor WHERE first_name = 'Joe';

/*List all actores with 'GEN' in their last name*/
SELECT actor_id, first_name, last_name FROM sakila.actor WHERE last_name LIKE  '%GEN%';

/*List all actores with 'LI' in their last name and sort by last name*/
SELECT actor_id, first_name, last_name FROM sakila.actor WHERE last_name LIKE  '%LI%' ORDER BY last_name, first_name;

/*List multiple contries in list*/
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

/*Add a 'description' column to the actor table*/
ALTER TABLE actor
	ADD COLUMN description BLOB;

/*Delete the desciption column*/    
ALTER TABLE actor
	DROP COLUMN description;

/*List the frequency of last names*/    
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name;

/*List on the the names with repeats*/
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name HAVING COUNT(*) > 1;

/*Update the first name of an actor*/
UPDATE actor SET first_name = 'HARPO' WHERE first_name = 'GROUCHO ' AND last_name = 'WILLIAMS';

/*Update the first name of an actor*/
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO';

/*Create table statement for the 'Address' table*/
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

/*List staff addresses*/
SELECT first_name, last_name, address, address2, postal_code FROM staff S
	LEFT JOIN address A
		ON S.address_id = A.address_id;

/*List staff sales for August 2005*/
SELECT first_name, last_name, SUM(amount) AS "Sales" FROM staff S
	JOIN payment P 
		ON S.staff_id = P.staff_id
	WHERE payment_date BETWEEN '2005/08/01' AND '2005/08/31'
	GROUP BY first_name, last_name;

/*List number of actors in each film*/    
SELECT F.film_id, title, COUNT(*) AS "Actors" FROM film F
	INNER JOIN film_actor FA
		ON F.film_id = FA.film_id
    GROUP BY film_id, title;

/*List inventory count for each film*/
SELECT title, COUNT(*) AS "Inventory#" FROM film F
    INNER JOIN inventory I 
		ON F.film_id = I.film_id
	WHERE F.title = 'Hunchback Impossible'
	GROUP BY F.film_id, F.title;

/*List customers and their total purchases*/
 SELECT first_name, last_name, SUM(amount) FROM customer C 
	JOIN payment P 
		ON C.customer_id = P.customer_id
	GROUP BY C.customer_id, first_name, last_name
    ORDER BY last_name, first_name;

/*List films starting with K or Q in the English language*/    
SELECT title FROM film WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
	AND language_id IN (
		SELECT language_id FROM language WHERE name = 'English');
        
/*List actors for a film using sub-query*/
SELECT first_name, last_name FROM actor WHERE actor_id IN (
	SELECT actor_id FROM film_actor WHERE film_id IN (
		SELECT film_id FROM film WHERE title = 'Alone Trip'));
        
/*All the customers in Canada*/
SELECT first_name, last_name, email FROM customer CU
	INNER JOIN address AD
		ON CU.address_id = AD.address_id
	INNER JOIN city CI
		ON AD.city_id = CI.city_id
	INNER JOIN country CO
		on CI.country_id = CO.country_id
	WHERE CO.country = 'Canada';

/*All films in the 'Family' genre/category*/
SELECT F.film_id, title FROM film F
	JOIN film_category FC
		ON F.film_id = FC.film_id
	JOIN category C
		ON FC.category_id = C.category_id
	WHERE C.name = 'Family'
    ORDER BY title;
    
/*List films and number of titles (ID) added to elminate possible title duplications*/
SELECT F.film_id, title, COUNT(*) AS "Rentals" FROM film F
	JOIN inventory I
		ON F.film_id = I.film_id
	JOIN rental R 
		ON I.inventory_id = R.inventory_id
	GROUP BY F.film_id, title
	ORDER BY rentals DESC;

/*Sales by Store*/    
SELECT S.store_id, SUM(amount) AS "Sales" FROM store S
	JOIN staff STF
		ON S.store_id = STF.store_id
	JOIN payment P 
		ON STF.staff_id = P.staff_id
	GROUP BY S.store_id
    ORDER BY Sales DESC;
    
/*Store and location info*/
SELECT store_id, C.city, CO.country FROM store S
	JOIN address A 
		ON S.address_id = A.address_id
	JOIN city C 
		ON A.city_id = C.city_id
	JOIN country CO
		ON C.country_id = CO.country_id;
    
 /*Top five sales categories*/
 SELECT C.name, SUM(amount) AS "Sales" FROM category C
	JOIN film_category FC
		ON C.category_id = FC.category_id
	JOIN film F 
		ON FC.film_id = F.film_id
	JOIN inventory I 
		ON F.film_id = I.film_id
	JOIN rental R 
		ON I.inventory_id = R.inventory_id
	JOIN payment P 
		ON R.rental_id = P.payment_id
	GROUP BY C.name
    ORDER BY Sales DESC
    LIMIT 5;

/*View to store the above query*/    
CREATE VIEW vw_top_five_genres
AS
 SELECT C.name, SUM(amount) AS "Sales" FROM category C
	JOIN film_category FC
		ON C.category_id = FC.category_id
	JOIN film F 
		ON FC.film_id = F.film_id
	JOIN inventory I 
		ON F.film_id = I.film_id
	JOIN rental R 
		ON I.inventory_id = R.inventory_id
	JOIN payment P 
		ON R.rental_id = P.payment_id
	GROUP BY C.name
    ORDER BY Sales DESC
    LIMIT 5;
    
/*Usage of above view*/
SELECT * FROM vw_top_five_genres;

/*Delete the view*/
DROP VIEW vw_top_five_genres;



