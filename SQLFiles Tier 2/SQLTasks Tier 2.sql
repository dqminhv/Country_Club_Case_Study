/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

Information:
Use this server: https://frankfletcher.co/springboard_phpmyadmin/index.php
The phpmyadmin username / password : admin_springboard / springboardbackup

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM `Facilities` 
WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
	facid, 
    name,
    membercost,
    monthlymaintenance
FROM Facilities
WHERE 
	membercost > 0 
    AND membercost < monthlymaintenance*0.2;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1,5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT
	name,
    	monthlymaintenance,
    	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
    	ELSE 'cheap' END 
        AS expense_label_2
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT 
	joindate,
	firstname,
    	surname
FROM Members
WHERE joindate IN 
	(SELECT MAX(joindate)
    	FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT CONCAT(M.firstname, " ", M.surname) AS mem_name, F.name AS facility_name
FROM
    (SELECT
         B.memid,
         B.facid
        FROM Bookings AS B
        WHERE B.facid IN (0,1)
        GROUP BY B.memid, B.facid) AS M_F
INNER JOIN Members AS M ON M_F.memid = M.memid
INNER JOIN Facilities AS F ON M_F.facid = F.facid
ORDER BY mem_name, facility_name;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT  
    f.name AS facilities_namme,
    CONCAT(m.firstname, " ", m.surname) AS mem_name,
    CASE WHEN b.memid = 0 THEN f.guestcost*b.slots
    	ELSE f.membercost*b.slots END
    	AS booking_cost
FROM Bookings AS b
INNER JOIN Members AS m ON b.memid = m.memid
INNER JOIN Facilities AS f ON b.facid = f.facid
WHERE (b.starttime LIKE '2012-09-14%' 
       AND (CASE WHEN b.memid = 0 THEN f.guestcost*b.slots
    	ELSE f.membercost*b.slots END) > 30)
ORDER BY booking_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT * FROM
(SELECT subquery.facility_name, SUM(subquery.booking_cost) AS total_rev
FROM (SELECT  
    f.name AS facility_name,
    CASE WHEN b.memid = 0 THEN f.guestcost*b.slots
    	ELSE f.membercost*b.slots END
    	AS booking_cost
FROM Bookings AS b
INNER JOIN Members AS m ON b.memid = m.memid
INNER JOIN Facilities AS f ON b.facid = f.facid) AS subquery
GROUP BY subquery.facility_name) AS subquery2
WHERE subquery2.total_rev > 1000
ORDER BY subquery2.total_rev 


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m1.memid, CONCAT(m1.surname, ", " ,m1.firstname) AS member_name, 
	CASE WHEN m2.surname = "GUEST" THEN ""
    		ELSE CONCAT(m2.surname, ", " ,m2.firstname) END AS recommendedby_name
FROM Members AS m1
INNER JOIN Members AS m2
ON CAST(m1.recommendedby AS INT) = m2.memid
ORDER BY member_name


/*
Q12 means that creating a query that determine the "facility usage" by members not by guest means how many times facility has been used by members(tip : use "slot "column)
Q13 means that creating a query that determine the "facility usage" by members not by guest but by "Month"(tip: you have to extract month from "starttime "column) (edited) 
*/

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT facid, f.name AS facility_name
FROM Facilities AS f
WHERE facid NOT IN 
    (SELECT facid FROM `Bookings`
    WHERE memid = 0
    GROUP BY facid)

/* Q13: Find the facilities usage by month, but not guests */

