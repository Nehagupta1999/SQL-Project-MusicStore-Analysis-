/*	Question Set 1 – Easy   */

*/ Q1: Who is the senior most employee based on job title? */

select employee_id,
last_name,
first_name
from employee
order by levels Desc
Limit 1

/* Q2: Which countries have the most Invoices?  */
	
Select count(*) as total,
billing_country
from invoice
group by billing_country
order by total desc

/* Q3: What are the top 3 values of the total invoice?  */

select total
from invoice
order by total desc
limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals.  */

select billing_city,
sum(total) as invoice_tatal
from invoice
group by billing_city
order by 2 desc
limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money.
*/

select c.customer_id,
c.first_name,
c.last_name,
sum(total)
from invoice as i
join customer as c on i.customer_id = c.customer_id
group by 1, 2, 3
order by 4 desc
limit 1


/*  Question Set 2 - Moderate  */

/* Q1: Write a query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A. */


select distinct email,
first_name,
last_name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
where track_id in (select track_id 
				   from track t
				   join genre g on t.genre_id = g.genre_id
				   where g.name like 'Rock')

order by email


/* Q2: Let's invite the artists who have written the most rock music in our dataset. Write a 
the query that returns the Artist name and total track count of the top 10 rock bands 
 */


select a.name,
count(a.artist_id) as total_number_of_songs
from artist a
join album b on a.artist_id = b.artist_id
join track t on b.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
group by 1
order by 2 desc
limit 10


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */


select name,
Milliseconds
from track
where Milliseconds > (select avg(Milliseconds) from track)
order by 2 DESC 


/*    Question Set 3 – Advance    */
/* Q1: Find how much amount spent by each customer on artists. Write a query to return 
customer name, artist name and total spent.
*/

with cte as 
(select a.artist_id,
a.name as artist_name,
sum(il.unit_price * il.quantity) as total
from artist a 
join album al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join invoice_line il on t.track_id = il.track_id
group by 1
order by 3 DESC
limit 1)

select c.first_name,
c.last_name,
cte.artist_name, 
sum(il.unit_price * il.quantity) as total_spent
from invoice i 
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on  t.track_id = il.track_id
join album al on al.album_id = t.album_id
join cte on cte.artist_id = al.artist_id
group by 1,2,3
order by 4 desc

Explanation:
1.	CTE with LIMIT 1:
o	The CTE now calculates the total amount spent by all customers on each artist (SUM(il.unit_price * il.quantity)), orders the results by the total amount spent (ORDER BY total_spent DESC), and limits the result to only the artist with the highest total spending (LIMIT 1).
2.	Final Query:
o	After the CTE returns the top artist (based on total spending), the final SELECT query joins the cte to get the customer details for that specific artist.
o	It aggregates the total amount spent by each customer (SUM(il.unit_price * il.quantity)) for the selected artist and orders the results by total_spent in descending order.
This query will return the customer names and the total amount they spent on only the artist with the highest total spending, as requested.

/* Q2: We want to find out the most popular music genres in each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */

with popular_music as (
select count(il.quantity) as purchase,
c.country,
g.name,
row_number() over (partition by c.country order by count(il.quantity)desc) as row_no
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by 2,3
order by 2 asc, 1 desc
)

select * 
from Popular_music
where row_no <= 1

/* Q3: Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount. */

with customer_with_country as ( 
select c.first_name,
c.last_name,
c.country,
sum(i.total) as total_spent,
row_number() over(partition by c.country order by sum(i.total) desc) as rowno
from invoice i
join customer c on i.customer_id = c.customer_id
group by 1,2,3
order by 3 asc, 4 desc) 

select *  from customer_with_country where rowno <= 1
