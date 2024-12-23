#Nivel 1, Ejercicio 2

#Listado de los países que están haciendo compras:

select distinct country
from transactions.company
join transactions.transaction
on company.id = transaction.company_id
where amount > 0;

#Desde cuántos países se realizan las compras:

select count(distinct company.country) as country
from transactions.company
join transactions.transaction
on company.id = transaction.company_id
where amount > 0;

#Identificar la compañía con la media más grande de ventas:

select company.company_name, round(avg(transaction.amount), 2) as avg_sales
from transactions.company
join transactions.transaction
on company.id = transaction.company_id
group by company.company_name
order by avg_sales DESC
limit 1;

#Nivel 1, Ejercicio 3
#Muestra todas las transacciones realizadas por empresas de Alemania:

select *
from transactions.transaction
where company_id in (select company.id
             from transactions.company
             where country = 'Germany');
             
#Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones:

select company_name
from transactions.company
where id in (select company_id 
			from transactions.transaction
            where amount > (select avg(amount) from transactions.transaction)
            );
            
#Eliminarán del sistema las empresas que no tienen transacciones registradas, entrega el listado de estas empresas:

select id, company_name
from transactions.company
where id not in (select distinct company_id 
				from transactions.transaction);
		
        
#Nivel 2, Ejercicio 1
#Identifica los cinco días que se generó la cantidad más grande de ingresos a la empresa por ventas. Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT date(timestamp) AS transaction_date, SUM(amount) AS total_sales
FROM transactions.transaction
GROUP BY transaction_date
ORDER BY total_sales DESC
LIMIT 5;

#Nivel 2, Ejercicio 2
#Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio:

select round(AVG(amount), 2) as avg_amount, country
from transactions.company c
join transactions.transaction t
on c.id = t.company_id
group by c.country
order by avg_amount desc;

#Nivel 2, Ejercicio 3
#En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía "Non Institute". Para lo cual, te piden la lista de todas las transacciones realizadas por empresas que están situadas en el mismo país que esta compañía.

#Muestra el listado aplicando JOIN y subconsultes.

select t.id as id_transaction, t.company_id, c.company_name, c.country 
from transactions.transaction t
join transactions.company c
  on t.company_id = c.id
where c.country = (
  select country
  from transactions.company
  where company_name = 'Non Institute'
);

#Muestra el listado aplicando solo subconsultes.

select id as id_transaction, company_id
from transactions.transaction
where company_id in (
  select id
  from transactions.company
  where country = (
    select country
    from transactions.company
    where company_name = 'Non Institute'
  )
);

#Nivel 3, Ejercicio 1: 
#Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 100 y 200 euros y en alguna de estas fechas: 29 de abril del 2021, 20 de julio del 2021 y 13 de marzo del 2022. Ordena los resultados de mayor a menor cantidad.

SELECT c.company_name, c.phone, c.country, date(t.timestamp) as transaction_date, t.amount
from transactions.company c
join transactions. transaction t
on c.id = t.company_id
where date(timestamp) in ('2021-02-29', '2021-02-20', '2022-03-13') and amount between 100 and 200
order by t.amount desc;

#Nivel 3, Ejercicio 2:  
#Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo cual te piden la información sobre la cantidad de transacciones que realicen las empresas, pero el departamento de recursos humanos es exigente y quiere un listado de las empresas donde especifiques si tienen más de 4 transacciones o menos:

SELECT 
    c.company_name, 
    t.company_id, 
    COUNT(t.id) AS num_transactions, 
    'More than 4 transactions' AS transaction_status
FROM transactions.transaction t
JOIN transactions.company c
ON t.company_id = c.id
GROUP BY c.company_name, t.company_id
HAVING COUNT(t.id) > 4

UNION ALL

SELECT 
    c.company_name, 
    t.company_id, 
    COUNT(t.id) AS num_transactions, 
    'Less than 4 transactions' AS transaction_status
FROM transactions.transaction t
JOIN transactions.company c
ON t.company_id = c.id
GROUP BY c.company_name, t.company_id
HAVING COUNT(t.id) <= 4

ORDER BY num_transactions DESC;

