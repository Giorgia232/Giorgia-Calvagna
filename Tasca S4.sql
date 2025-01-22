#Nivel 1

CREATE DATABASE eshop;
use eshop;

CREATE TABLE IF NOT EXISTS companies (
    company_id VARCHAR(15) PRIMARY KEY, 
    company_name VARCHAR(255) NOT NULL,  
    phone VARCHAR(15) NULL,  
    email VARCHAR(100) NOT NULL,  
    country VARCHAR(100) NULL,  
    website VARCHAR(255) NULL 
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SELECT *
FROM companies;

CREATE TABLE IF NOT EXISTS credit_cards (
    id VARCHAR(15) PRIMARY KEY,  
    user_id VARCHAR(100) NOT NULL,  
    iban VARCHAR(40) UNIQUE NOT NULL,  
    pan VARCHAR(45) NOT NULL,  
    pin VARCHAR(5) NULL, 
    cvv VARCHAR(4) NULL, 
    track1 VARCHAR(100) NULL,
    track2 VARCHAR(100) NULL, 
    expiring_date VARCHAR(10) NULL 
 ); 
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
IGNORE 1 LINES; 

SELECT *
FROM credit_cards;

CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(255) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL, 
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.0, 
    colour VARCHAR(100) NULL, 
    weight DECIMAL(10, 2) DEFAULT 0.0, 
    warehouse_id VARCHAR(40) NOT NULL 
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, @price, colour, @weight, warehouse_id)
SET price = REPLACE(@price, '$', ''),
    weight = CAST(@weight AS DECIMAL(10,2));
    
SELECT *
FROM products;
    
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    INDEX idx_email (email),  
    INDEX idx_phone (phone)  
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(TRIM(BOTH '"' FROM @birth_date), '%b %d, %Y');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(TRIM(BOTH '"' FROM @birth_date), '%b %d, %Y');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(TRIM(BOTH '"' FROM @birth_date), '%b %d, %Y');

SELECT *
FROM users;

CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(255) PRIMARY KEY, 
    card_id VARCHAR(40) NOT NULL, 
    business_id VARCHAR(40) NOT NULL, 
    timestamp TIMESTAMP NOT NULL, 
    amount DECIMAL(10, 2) NOT NULL, 
    declined BOOLEAN NOT NULL, 
	product_ids VARCHAR(40) NULL,
    user_id INT NOT NULL,
    lat FLOAT, 
    longitude FLOAT, 
    CONSTRAINT fk_transactions_credit_cards FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    CONSTRAINT fk_transactions_companies FOREIGN KEY (business_id) REFERENCES companies(company_id),
    CONSTRAINT fk_transactions_users FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_card_id (card_id),
    INDEX idx_business_id (business_id),
    INDEX idx_user_id (user_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude);

SELECT *
FROM transactions;

#Nivel 1, Ejercicio 1
#Realiza una subconsulta que muestre todos los usuarios con más de 30 transacciones utilizando al menos 2 tablas:

SELECT  u.id as users_id, u.name, u.surname
FROM users u
WHERE u.id IN (
    SELECT t.user_id
    FROM transactions t
    GROUP BY t.user_id
    HAVING COUNT(t.id) > 30
); 

#Nivel 1, Ejercicio 2
#Muestra la media de amount por IBAN de las tarjetas de crédito a la compañía Donec Ltd, utiliza al menos 2 tablas:

SELECT cc.id as credit_card_id, c.company_name, cc.iban,  ROUND(AVG(t.amount), 2) AS avg_amount
FROM credit_cards cc
JOIN transactions t
ON cc.id = t.card_id
JOIN companies c
ON c.company_id = t.business_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban, cc.id;

#Nivel 2, Ejercicio 1
#Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas tres transacciones fueron declinadas y genera la siguiente consulta: Cuántas tarjetas están activas?

CREATE TABLE card_activity (
    card_id VARCHAR(15) PRIMARY KEY,
    declined ENUM('YES', 'NO') NOT NULL,
    FOREIGN KEY (card_id) REFERENCES credit_cards(id)
);

INSERT INTO card_activity (card_id, declined)
SELECT t.card_id, IF(COUNT(*) = 3 AND SUM(t.declined) = 3, 'YES', 'NO') AS declined
FROM (SELECT card_id, declined
      FROM transactions
      ORDER BY timestamp DESC) t
GROUP BY t.card_id;

#Nivel 3, Ejercicio 1
#Crea una tabla con la cual podamos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde transactions tenemos product_ids. Genera la siguiente consulta: necesitamos conocer el número de veces que se ha vendido cada producto.

CREATE TABLE sold_products (
    transaction_id VARCHAR(255),
    product_id VARCHAR(255),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO sold_products (transaction_id, product_id)
SELECT t.id AS transaction_id, p.id AS product_id
FROM transactions t
CROSS JOIN products p
WHERE FIND_IN_SET(p.id, REPLACE(t.product_ids, ', ', ','))>0;

SELECT *
FROM sold_products;


SELECT p.id AS product_id, p.product_name, COUNT(sp.transaction_id) AS product_sales
FROM products p
LEFT JOIN sold_products sp 
ON p.id = sp.product_id
LEFT JOIN transactions t 
ON sp.transaction_id = t.id 
WHERE t.declined = 0
GROUP BY p.id, p.product_name
ORDER BY product_sales DESC;



