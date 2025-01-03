#Nivel 1, Ejercicio 1
#Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. La nueva tabla tiene que ser capaz de identificar de manera única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). Después de crear la tabla será necesario que ingreses la información del documento denominado "datos_introducir_credit". Recuerda mostrar el diagrama y realizar una breve descripción de este.

USE transactions;

CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,                 
    iban VARCHAR(40) NOT NULL,                 
    pan VARCHAR(45) NOT NULL,                  
    pin INT NOT NULL,                          
    cvv INT NOT NULL,                          
    expiring_date VARCHAR(20) NOT NULL
    
);

SELECT credit_card_id
FROM transaction
WHERE credit_card_id NOT IN (SELECT id FROM credit_card)
OR credit_card_id IS NULL;

select *
from credit_card;

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

CREATE INDEX idx_credit_card
ON transaction(credit_card_id);


#Nivel 1, Ejercicio 2
#El departamento de Recursos Humanos ha identificado un error en el número de cuenta del usuario con ID CcU-2938. La información que tiene que mostrarse para este registro es: R323456312213576817699999. Recuerda mostrar que el cambio se realizó:

SELECT id, pan
FROM credit_card
WHERE id = 'CcU-2938';

UPDATE credit_card
SET pan = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT id, pan
FROM credit_card
WHERE id = 'CcU-2938';

#Nivel 1, Ejercicio 3
#En la tabla "transaction" ingresa un nuevo usuario con la siguiente información

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');

INSERT INTO company (id) VALUES ('b-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');

INSERT INTO credit_card (id) VALUES ('CcU-9999');

ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR(40) DEFAULT NULL;

INSERT INTO credit_card (id) VALUES ('CcU-9999');

ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR(40) DEFAULT NULL,
MODIFY COLUMN pan VARCHAR(45) DEFAULT NULL,
MODIFY COLUMN pin VARCHAR(10) DEFAULT NULL,
MODIFY COLUMN cvv VARCHAR(5) DEFAULT NULL,
MODIFY COLUMN expiring_date VARCHAR(20) DEFAULT NULL;

INSERT INTO credit_card (id) VALUES ('CcU-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');

#Nivel 1, Ejercicio 4
#Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado:

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card;

#Nivel 2, Ejercicio 1
#Elimina de la tabla transaction el registro con ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de datos:

SELECT id
FROM transaction 
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

DELETE FROM transaction
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

SELECT id
FROM transaction 
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

#Nivel 2, Ejercicio 2
#La selección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. Será necesaria que crees una vista llamada VistaMarketing que contenga la siguiente información: nombre de la compañía, teléfono de contacto, país de residencia, media de compra realizado por cada compañía. Presenta la vista creada, ordenando los datos de mayor a menor media de compra:

CREATE VIEW VistaMarketing AS
SELECT c.id, c.company_name, c.phone, c.country, ROUND(avg(t.amount), 2) as avg_amount
FROM company c
JOIN transaction t
ON c.id = t.company_id
GROUP BY c.id, c.company_name, c.phone, c.country
ORDER BY avg_amount DESC;



SELECT * FROM VistaMarketing;

#Nivel 2, Ejercicio 3
#Filtra la vista VistaMarketing para mostrar solo las compañías que tienen su país de residencia en "Germany":

SELECT *
FROM VistaMarketing
WHERE country = 'Germany';

#Nivel 3, Ejercicio 1
#La próxima semana tendrás una nueva reunión con los gerentes de marketing. Un compañero de tu equipo realizó modificaciones en la base de datos, pero no recuerda como las realizó. Te pide que lo ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama:

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE DEFAULT NULL;

ALTER TABLE credit_card
MODIFY COLUMN pin VARCHAR(4);

DESCRIBE credit_card;


ALTER TABLE company
DROP COLUMN website,
DROP COLUMN company_id;


CREATE TABLE IF NOT EXISTS data_user (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date VARCHAR(100),
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255)
);

ALTER TABLE transaction
ADD CONSTRAINT fk_user_transaction
FOREIGN KEY (user_id) REFERENCES data_user(id);

ALTER TABLE data_user
CHANGE COLUMN email personal_email VARCHAR(150);


#Nivel 3, Ejercicio 2
#La empresa también te solicita crear una vista llamada "InformeTecnico" que contenga la siguiente información:
#ID de la transacción
#Nombre del usuario/aria
#Apellido del usuario/aria
#IBAN de la tarjeta de crédito usada.
#Nombre de la compañía de la transacción realizada.
#Asegúrate de incluir información relevante de ambas tablas y utiliza alias para cambiar de nombre columnas según sea necesario.
#Muestra los resultados de la vista, ordena los resultados de manera descendente en función de la variable ID de transaction:


CREATE VIEW InformeTecnico AS
SELECT t.id AS id_transaction, u.name AS user_name, u.surname AS user_surname, cr.iban, c.company_name
FROM transaction t
JOIN company c
ON t.company_id = c.id
JOIN credit_card cr
ON t.credit_card_id = cr.id
JOIN data_user u
ON t.user_id = u.id
ORDER BY id_transaction DESC;