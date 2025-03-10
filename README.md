#             Required Tables DATA
```sql
SELECT * FROM Books;
SELECT * FROM Branch;
SELECT * FROM Employees;
SELECT * FROM Issued_status;
SELECT * FROM Members;
SELECT * FROM Return_status;
```

# Project Tasks 
  
### CRUD Operations  

#### Create: Inserted sample records into the books table.
#### Read: Retrieved and displayed data from various tables.
#### Update: Updated records in the employees table.
#### Delete: Removed records from the members table as needed. 

##### Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
```sql
SELECT * FROM Books;

INSERT INTO Books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

##### Task 2: Update an Existing Members Address
```sql
SELECT * FROM Members;

UPDATE Members
SET member_address = '125 Main St'
WHERE member_id = 'C101'; 
```

##### Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
```sql
SELECT * FROM Issued_status;

DELETE 
FROM Issued_status
WHERE issued_id = 'IS121';
```

##### Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM Issued_status;

SELECT * 
FROM Issued_status
WHERE issued_emp_id = 'E101';
```
##### Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
```sql
SELECT * FROM Issued_status;

SELECT  issued_emp_id, Count(*) AS No_of_books_issued
FROM Issued_status
GROUP BY  issued_emp_id
HAVING COUNT(*) > 1;
```

### CTAS (Create Table As Select)  

##### Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
SELECT * FROM Books;
SELECT * FROM Issued_status;

CREATE TABLE Books_issued_count AS
SELECT B.isbn, B.book_title, COUNT(Iss.issued_id) as Count 
FROM Books AS B
JOIN Issued_status AS Iss
ON B.isbn = Iss.issued_book_isbn
GROUP BY B.isbn, B.book_title;

SELECT * FROM Books_issued_count;  /* New table Created  */
```

# DATA ANALYSIS & FINDINGS  


##### Task 7. Retrieve All Books in a Specific Category:

```sql
SELECT * FROM Books;

SELECT * 
FROM Books
WHERE category = 'Classic';
```
##### Task 8: Find Total Rental Income by Category:
```sql
SELECT * FROM Books;

SELECT category, sum(rental_price) AS Rental_income, COUNT(*)
FROM Books
GROUP BY category;
```

##### Task 9. List Members Who Registered in the Last 180 Days:

```sql
SELECT * FROM Members;

SELECT *
FROM Members
WHERE reg_date >= Current_date - interval '360 days';
```

##### Task 10.List Employees with Their Branch Managers Name and their branch details:

```sql
SELECT * FROM Branch;
SELECT * FROM Employees;

SELECT E1.emp_name, E1.position, E1.salary, E2.emp_name AS Manager_name, B.* 
FROM Branch AS B
JOIN Employees AS E1
ON B.branch_id = E1.branch_id
JOIN Employees AS E2
ON E2.emp_id = B.manager_id;
```

##### Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

```sql
SELECT * FROM Books;

CREATE TABLE Expensive_books AS
SELECT *
FROM Books
WHERE rental_price > 7;

SELECT * FROM Expensive_books;
```

##### Task 12: Retrieve the List of Books Not Yet Returned

```sql
SELECT * FROM Issued_status;
SELECT * FROM Return_status;

SELECT *
FROM Issued_status AS I
LEFT JOIN Return_status AS R
ON I.issued_id = R.issued_id
WHERE R.issued_id IS null;
```

## ADVANCED SQL OPERATIONS 


##### Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT * FROM Books;
SELECT * FROM Issued_status;
SELECT * FROM Members;
SELECT * FROM Return_status;


SELECT Iss.issued_member_id, M.member_name, B.book_title, Iss.issued_date, current_date - Iss.issued_date AS Over_due
FROM Issued_status AS Iss
JOIN Members AS M
ON Iss.issued_member_id = M.member_id
JOIN Books AS B
ON Iss.issued_book_isbn = B.isbn
LEFT JOIN Return_status AS R
ON Iss.issued_id = R.issued_id
WHERE R.return_date IS null AND (current_date - Iss.issued_date ) > 30
ORDER by 1;
```

##### Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
```sql
SELECT * FROM Books;
SELECT * FROM Issued_status;
SELECT * FROM Return_status;

SELECT * 
FROM Books
WHERE isbn = '978-0-06-112008-4';   /* Initially it available in book table(status is Yes) */

UPDATE BOOKS
SET status = 'No'
WHERE isbn = '978-0-06-112008-4'    /* Status is updated yes to No  */

SELECT * 
FROM Books
WHERE isbn = '978-0-06-112008-4';   /* Now status is No  */


SELECT * 
FROM Issued_status
WHERE issued_book_isbn = '978-0-06-112008-4';   /* Here in issued table this book is issued to one of the member  */


SELECT * 
FROM Return_status
WHERE issued_id = 'IS131';    /* The above book was not returned  */


INSERT INTO Return_status (return_id, issued_id, return_date, quality)
VALUES('RS125', 'IS131', CURRENT_DATE, 'GOOD');            /* One new record inserted  */

SELECT * FROM Return_status;          /* Here the book is returned.So upadte same in book table  */

UPDATE BOOKS
SET status = 'Yes'
WHERE isbn = '978-0-06-112008-4'

/* The above procedure done completely in Manual */

/* But using STORED PROCEDURES You sacan do it automatically  */


CREATE OR REPLACE PROCEDURE add_return_records(
    P_return_id VARCHAR(20), 
    P_issued_id VARCHAR(20), 
    P_quality VARCHAR(20)  -- These values enter by Member, so I used P_
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(20);
    v_book_name VARCHAR(75);
BEGIN
    -- Insert into the Return_status table based on user input
    INSERT INTO Return_status (return_id, issued_id, return_date, quality)
    VALUES(P_return_id, P_issued_id, CURRENT_DATE, P_quality);  

    -- Select ISBN and book name based on issued_id
    SELECT 
        issued_book_isbn,
        issued_book_name
    INTO  
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = P_issued_id;

    -- Update BOOKS table to set the status
    UPDATE BOOKS
    SET status = 'Yes'
    WHERE isbn = v_isbn;

    -- Raise a notice to confirm the return
    RAISE NOTICE 'Thank you for returning book: %', v_book_name;

END;
$$;

CALL add_return_records();

/* STORED PROCEDURE CREATED in the name of add_return_records  */

                                             
/* Testing functions   */
											  

SELECT * FROM Books;
SELECT * FROM Issued_status;
SELECT * FROM Return_status;

/* Now select any book which was issued but not returned */


SELECT * FROM Issued_status
WHERE issued_id = 'IS136';  /* IS136 issue id.This book issued but not returned. */

SELECT * FROM Return_status
WHERE issued_id = 'IS136';   /* Book not retuned  */

SELECT * 
FROM BOOKS
WHERE isbn = '978-0-7432-7357-1';  /* Using issued_id in Book table find the isbn of the book and check the status of the book.
                                     Status is NO. */


/* Now call the Stored Procedures   */


CALL add_return_records('RS136', 'IS136', 'Too Baad');   /* Here status updated from NO to YES   */

/* Check with another record  */


SELECT * FROM Issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';     /* With this find the issued_id  */

SELECT * FROM Issued_status
WHERE issued_id = 'IS135';  /* IS135 issue id.This book issued but not returned. */

SELECT * FROM Return_status
WHERE issued_id = 'IS135';   /* Book not retuned  */

SELECT * 
FROM BOOKS
WHERE isbn = '978-0-307-58837-1';  /* Using issued_id in Book table find the isbn of the book and check the status of the book.
                                     Status is NO. */

/* Now call the Stored Procedures   */


CALL add_return_records('RS135', 'IS135', 'Damaged');


SELECT * 
FROM BOOKS
WHERE isbn = '978-0-307-58837-1';   /* Here status updated from NO to YES  */
```

##### Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.


```sql
SELECT * FROM Branch;    /* 5 records  */
SELECT * FROM Issued_status;   /* 34 records  */
SELECT * FROM Employees;       /*  11 records  */
SELECT * FROM Books;   /* 36 Records  */
SELECT * FROM Return_status;    /* 18 records  */


CREATE TABLE Branch_reports AS 
SELECT B.branch_id, B.manager_id, COUNT(Iss.issued_id) AS No_of_books_issued, COUNT(Rss.return_id) AS No_of_books_returned, SUM(Bk.rental_price) AS Total_revenue
FROM Issued_status AS Iss
JOIN Employees AS E
ON Iss.issued_emp_id = E.emp_id
JOIN Branch AS B
ON B.branch_id = E.branch_id
LEFT JOIN Return_status AS Rss
ON Rss.issued_id = Iss.issued_id
JOIN Books AS Bk
ON Bk.isbn = Iss.issued_book_isbn
GROUP BY 1,2;

SELECT * FROM Branch_reports;
```

##### Task 16: CTAS: Create a Table of Active Members:
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 11 months.

```sql
SELECT * FROM Issued_status;
SELECT * FROM Members;

CREATE TABLE Active_members AS 
SELECT *
FROM Members
WHERE member_id IN (
                    SELECT DISTINCT issued_member_id 
                    FROM Issued_status
                    WHERE Issued_date >= Current_date - INTERVAL '11 Month' );   /* Consider 11 Months  */


SELECT * FROM Active_members;
```


##### Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.

```sql
SELECT * FROM Issued_status;

SELECT E.emp_name, B.*, COUNT(Iss.issued_id) AS No_of_books_issued
FROM Issued_status AS Iss
JOIN Employees AS E
ON Iss.issued_emp_id = E.emp_id
JOIN Branch AS B
ON E.branch_id = B.Branch_id
GROUP BY 1,2;
```


##### Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they have issued damaged books.

```sql
SELECT * FROM Issued_status;
SELECT * FROM Books; 
SELECT * FROM Return_status;
SELECT * FROM Members;


SELECT * FROM Return_status
WHERE quality = 'Damaged';


SELECT M.member_name, Iss.issued_book_name, count(Distinct Iss.issued_member_id) AS damaged_books  
FROM Issued_status AS Iss
JOIN Return_status AS Rs
ON Iss.issued_id = Rs.issued_id
JOIN Members AS M
ON Iss.issued_member_id = M.member_id
WHERE quality = 'Damaged'
GROUP BY 1,2
HAVING count(Distinct Iss.issued_member_id) >=1;
```


##### Task 19: Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. 
Description:     
Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.


```sql
SELECT * FROM Books;
SELECT * FROM Issued_status;

CREATE OR REPLACE PROCEDURE Issue_book(
    p_issued_id VARCHAR(10),
    p_issued_member_id VARCHAR(10),
    p_issued_book_isbn VARCHAR(25),
    p_issued_emp_id VARCHAR(20)
)
LANGUAGE PLPGSQL AS $$  
DECLARE     
    V_status VARCHAR(15);
BEGIN
    -- Check if the requested book is available (status = 'yes')
    SELECT Status INTO V_status 
    FROM Books 
    WHERE isbn = p_issued_book_isbn;
    
    -- If book is available
    IF V_status = 'no' THEN
        -- Insert record into Issued_status table
        INSERT INTO Issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        -- Update book status to 'No' indicating it's issued
        UPDATE Books
        SET status = 'Yes'
        WHERE isbn = p_issued_book_isbn;

        -- Provide confirmation message
        RAISE NOTICE 'Book record added successfully for book isbn: %', p_issued_book_isbn;

    ELSE
        -- Book is not available, raise notice
        RAISE NOTICE 'Requested book unavailable: %', p_issued_book_isbn;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Handle any other errors by raising an exception with the message
        RAISE EXCEPTION 'An error occurred while issuing the book: %', SQLERRM;
END;
$$;


-- CALLING --


SELECT * FROM Books;

-- "978-0-553-29698-2" Showing 'yes'
-- "978-0-375-41398-8" Showing 'No'

SELECT * FROM Issued_status;

CALL issue_book('IS141','C110', '978-0-553-29698-2', 'E104' );

/* Check the status Yes changes to No  */ 

SELECT * FROM Books
WHERE isbn = '978-0-553-29698-2';

CALL issue_book('IS142','C110', '978-0-375-41398-8', 'E104' );

/* Check the status No changes to Yes.For this we need to change the Procedure table.
Instead of Yes in V_status change to NO. */ 

SELECT * FROM Books
WHERE isbn = '978-0-375-41398-8';
```

