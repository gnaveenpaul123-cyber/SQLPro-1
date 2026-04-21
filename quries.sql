--List all movies with their title, release year, and rental rate.
select title, release_year, rental_rate from film;

--Find all customers from a specific city.
select  cu.first_name, c.city from city as c
join address as a
on a.city_id = c.city_id
join customer as cu
on a.address_id = cu.address_id
where c.city = 'London';

--Films with rating 'PG-13'
select film_id, title from film
where rating = 'PG-13';

--Actors whose last name starts with 'S'
select last_name from
actor
where last_name like 'S%';

--. Stores with addresses
select s.store_id, a.address                                          
from store as  s
join address
as a on s.address_id = a.address_id;

--Number of films per category
select c.name, count(f.category_id) from film_category as f
join category as c
on c.category_id = f.category_id
group by c.name

--Number of films per category

select c.name, count(f.title) from film as f
join film_category as fc
on f.film_id = fc.film_id
join category as c
on c.category_id = fc.category_id
group by c.name

--films with category
select c.name, f.title from film as f
join film_category as fc
on fc.film_id= f.film_id
join category as c
on c.category_id = fc.category_id

--Rentals per customer
select c.customer_id, c.first_name, count(*)
from customer as c
join rental as r
on c.customer_id = r.customer_id
group by c.customer_id, c.first_name
order by c.customer_id asc

--Revenue per customer
select c.customer_id, c.first_name,sum(p.amount) as total_spent
from customer as c
join payment as p
on c.customer_id = p.customer_id
group by c.customer_id, c.first_name
order by total_spent desc

--Top 10 most rented movies
select f.title, count(*) as rental_count
from film f
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
group by f.title
order by rental_count desc
limit 10;



--Films per actor
select a.actor_id, a.first_name, count(fc.actor_id) as fil_count from film as f
join film_actor as fc
on fc.film_id = f.film_id
join actor as a
on a.actor_id = fc.actor_id
group by a.actor_id, a.first_name
order by fil_count;

--customer who never rented

select c.customer_id,c.first_name from customer as c
left join rental as r
on c.customer_id = r.customer_id
where r.rental_id is null;

--Customers with more than 10 rentals
select c.first_name, count(r.rental_id) from customer as c
join rental as r
on c.customer_id = r.customer_id
group by c.first_name
having count(r.rental_id) > 10;

--Monthly revenue

select sum(amount) as revenue, extract (month from payment_date) as month
from payment
group by month
order by month;

--top 5 customers by spending
select sum(p.amount) as total_spent, c.customer_id from customer as c
join payment as p
on c.customer_id = p.customer_id
group by  c.customer_id
order by total_spent desc
limit 5;

--Most popular category

select c.name, count(*) as rentals
from category as c
join film_category as fc on c.category_id = fc.category_id
join inventory as i ON fc.film_id = i.film_id
join rental as r on i.inventory_id = r.inventory_id
group by c.name
order by rentals desc
limit 1;

--films never rented


select f.title
from film f
left join inventory i on f.film_id = i.film_id
left join rental r on i.inventory_id = r.inventory_id
where r.rental_id is null
order by f.title;

--avg spending per customer per month

select customer_id, extract(month from payment_date) as month, avg(amount) from payment
group by  customer_id, month

--revenue e store
select s.store_id, sum(p.amount) as revenue
from store as s
join inventory as i on s.store_id = i.store_id
join rental as r on i.inventory_id = r.inventory_id
join payment as p on r.rental_id = p.rental_id
group by s.store_id;

--peak rental hours
select extract (hour from rental_date) as hour, count(*) from rental
group by hour
order by hour;

--Top 3 revenue generating actors
select fc.actor_id, a.first_name, sum(p.amount) as revenue from actor as a
join film_actor as fc on fc.actor_id = a.actor_id
join inventory as i on fc.film_id = i.film_id
join rental as r on i.inventory_id = r.inventory_id
join payment as p on r.customer_id = p.customer_id
group by fc.actor_id,a.first_name
order by revenue desc limit 3;

--customer segmentation
select customer_id,
case
when sum(amount) > 150 then 'High Value'
when sum(amount) < 50 then 'low value'
end as segment
from payment
group by customer_id;

--Top 5 cities by revenue?

select ci.city, sum(p.amount) as total_revenue
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
join store s on i.store_id = s.store_id
join address a on s.address_id = a.address_id
join city ci on a.city_id = ci.city_id
group by ci.city
order by total_revenue desc
limit 5;

-- Repeat vs one-time customers

select
    case
        when count(r.rental_id) = 1 then 'one-time'
        else 'repeat'
    end as customer_type,
    count(*) as customer_count
from customer c
left join rental r on c.customer_id = r.customer_id
group by customer_type;

--: Most rented film per category

select c.name as category, f.title, count(r.rental_id) as rentals
from category c
join film_category fc on c.category_id = fc.category_id
join film f on fc.film_id = f.film_id
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
group by c.name, f.title
having count(r.rental_id) = (
    select max(rental_count)
    from (
        select count(r2.rental_id) as rental_count
        from film_category fc2
        join inventory i2 on fc2.film_id = i2.film_id
        join rental r2 on i2.inventory_id = r2.inventory_id
        where fc2.category_id = c.category_id
        group by fc2.film_id
    ) sub
)
order by c.name;

--Store-wise customer count

select s.store_id, count(c.customer_id) as total_customers
from store s
join customer c on s.store_id = c.store_id
group by s.store_id;
