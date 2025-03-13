--Q1: Who is the senior most employee based on the Job title?

select Top 1 
(last_name+' '+first_name) as FullName,
employee_id,
title
from employee
order by levels desc


--Q2: Which countries have the most invoices?

select  billing_country , count (*) as Invoice_Count
from invoice
group by billing_country
order by Invoice_Count desc

--Q3: What are top three values of invoices and customer name?

select Top 3 
cus.first_name+' '+last_name as Name,  inv.invoice_id, total from invoice inv
join customer cus 
on inv.customer_id=cus.customer_id
order by total desc


--Q4: Top 5 cities having the best customers? We would like to throw a promotional MusicFestival in the city we made the most money.
--Write a query that returns 5 cities that has the highest sum of invoice totals.
--Return both the city name and sum of all invoice totals.

select Top 5 
billing_city, sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc

--Q5: Who is the best customer?
--The customer  who has spent the most money will be declared the best customer.
--Write a query that returns the person who has spent the most money.

select Top 1 
	   cus.customer_id, 
	   (cus.first_name + ' ' + cus.last_name) AS Name,	   
	   sum(inv.total) as TotalMoney
from customer cus
join invoice inv
on cus.customer_id = inv.customer_id
group by cus.customer_id,cus.first_name,cus.last_name
order by TotalMoney desc

---Moderate Level Queries------------

--Q6: Write a query to return the email, first name, last name and Genre of all Rock music listeners.
--Return your list ordered alphabetically by email starting with A.

Select  distinct (email), first_name, last_name
from customer cus
join invoice inv
on cus.customer_id= inv.customer_id
join invoice_line on inv.invoice_id= invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id= genre.genre_id
	where genre.name like 'Rock'
)
order by email;

--Q7: Lets invite the artists who have written the most rock music in our dataset.
--Write a query that returns the Artist name and total track count of the top 10 rock bands.

select TOP 10 
artist.name ARTIST_NAME, 
artist.artist_id as ARTIST_ID,
count(artist.artist_id) as No_Of_Songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id,artist.name
order by no_of_songs desc;


--Q8: Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track.
--Order by the song length with the longest songs listed first.

-- (select * from track)
Select name as Track_Name, milliseconds as MilliSeconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track)
order by milliseconds desc;

--Q9: Find how much amount each customer spent by each customer on artists?
--Write a query to return customer name, artist name and total Money spent.

WITH Best_Selling_Artist AS (
  SELECT TOP 1
    artist.artist_id AS Artist_id,
    artist.name AS Artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS Total_Sales
  FROM 
    invoice_line
  JOIN 
    track ON track.track_id = invoice_line.track_id
  JOIN 
    album ON album.album_id = track.album_id
  JOIN 
    artist ON artist.artist_id = album.artist_id
  GROUP BY 
    artist.artist_id, 
    artist.name
  ORDER BY 
    Total_Sales DESC
)
SELECT 
  c.customer_id,
  (c.first_name + ' ' + last_name) as CustomerName,
  BSA.Artist_name,
  SUM(invl.unit_price * invl.quantity) AS amount_spent
FROM 
  invoice i
JOIN 
  customer c ON c.customer_id = i.customer_id
JOIN 
  invoice_line invl ON invl.invoice_id = i.invoice_id
JOIN 
  track t ON t.track_id = invl.track_id
JOIN 
  album alb ON alb.album_id = t.album_id
JOIN 
  Best_Selling_Artist BSA ON BSA.Artist_id = alb.artist_id
GROUP BY 
  c.customer_id,
  c.first_name,
  c.last_name,
  BSA.Artist_name
ORDER BY 
  amount_spent DESC;


--Q10: We want to find out the most popular music genre for each country.
--We determine the most popular genre as the genre with highest amount of purchases.
--Write a query that returns each country along with the top genre.
--For countries where the maximum number of purchases is shared return all genres.

 with Popular_Genre as 
 (
 	select count(invoice_line.quantity) as purchases, 
	customer.country, 
	genre.name, 
	genre.genre_id,	
 	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
 	from invoice_line
 	join invoice on invoice.invoice_id= invoice_line.invoice_id
 	join customer on customer.customer_id= invoice.customer_id
 	join track on track.track_id= invoice_line.track_id
 	join genre on genre.genre_id= track.genre_id
 	group by customer.country, genre.name, genre.genre_id
 )
 select * from popular_genre where RowNo <= 1
 
 --Q11: Write a query that determines the customer that has spent the most on music for each country.
 --Write a query that returns the country along with the top customer and how much they spent.
 --For countries where the top amount spent is shared, provide all customers who spent this amount
 
 WITH customer_with_country AS (
  SELECT 
    (customer.first_name + ' ' + customer.last_name) as CustomerName, 
	customer.customer_id, 
    customer.country, 
    SUM(invoice.total) AS total_spending,
    ROW_NUMBER() OVER (
      PARTITION BY customer.country 
      ORDER BY SUM(invoice.total) DESC
    ) AS RowNo
  FROM 
    invoice 
  JOIN 
    customer  ON customer.customer_id = invoice.customer_id
  GROUP BY 
    customer.customer_id, 
    customer.first_name, 
    customer.last_name, 
    customer.country
)
SELECT * 
FROM customer_with_country 
WHERE RowNo <= 1;