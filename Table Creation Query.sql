--- Library Management System ---

/* Create Branch Table */

DROP TABLE IF EXISTS Branch;

CREATE TABLE Branch (
               branch_id   VARCHAR(10) PRIMARY KEY,
			   manager_id   VARCHAR(10),
			   branch_address VARCHAR(55),
			   contact_no  VARCHAR(10)
                    );

ALTER TABLE Branch
ALTER COLUMN contact_no TYPE VARCHAR(20);

/* Create Employee Table  */

DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
                 emp_id	    VARCHAR(10) PRIMARY KEY,
				 emp_name   VARCHAR(20),
				 position   VARCHAR(20), 
				 salary	    FLOAT,
				 branch_id VARCHAR(20)
                       );

/* Create Books Table  */

DROP TABLE IF EXISTS Books;

CREATE TABLE Books (
                  isbn VARCHAR(20) PRIMARY KEY,	
				  book_title  VARCHAR(75),	
				  category   VARCHAR(10),
				  rental_price  FLOAT,
				  status  VARCHAR(15),
				  author  VARCHAR(25),
				  publisher VARCHAR(55)
                   );

ALTER TABLE Books
ALTER COLUMN category TYPE VARCHAR(25);

/* Create Memebers table  */

DROP TABLE IF EXISTS Members;

CREATE TABLE Members (
                member_id VARCHAR(10) PRIMARY KEY,
				member_name VARCHAR(25),
				member_address VARCHAR(75),
				reg_date DATE
                  );

/* Create Issued_status table  */

DROP TABLE IF EXISTS Issued_status;

CREATE TABLE Issued_status (
                          issued_id VARCHAR(10) PRIMARY KEY,
						  issued_member_id VARCHAR(10),
						  issued_book_name VARCHAR(70),
						  issued_date DATE,
						  issued_book_isbn VARCHAR(25),						  
						  issued_emp_id VARCHAR(20)
                           );

/* Create Return_status Table  */

DROP TABLE IF EXISTS Return_status;

 CREATE TABLE Return_status (
                  return_id VARCHAR(20) PRIMARY KEY,
				  issued_id	VARCHAR(20),
				  return_book_name VARCHAR(70),
				  return_date DATE,
				  return_book_isbn VARCHAR(20)
                       );

--- FOREIGN KEY ---

ALTER TABLE Issued_status 
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES Members(member_id );


ALTER TABLE Issued_status 
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES Books(isbn);

ALTER TABLE Issued_status 
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES Employees(emp_id	);


ALTER TABLE Employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES Branch(branch_id);


ALTER TABLE Return_status 
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES Issued_status(issued_id);

ALTER TABLE Return_status 
ADD CONSTRAINT fk_books
FOREIGN KEY (isbn)
REFERENCES Books(isbn);




					   