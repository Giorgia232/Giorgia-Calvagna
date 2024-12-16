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

select company.company_name, avg(transaction.amount) as avg_sales
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