CREATE DATABASE MySQL_P2;
USE MySQL_P2;

-- Creating Structure for Book Table
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
	Book_ID INTEGER PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(50),
    Genre VARCHAR(20),
    Published_Year INTEGER,
    Price DECIMAL(10,2),
    Stock INTEGER
);

-- Creating Structure for Customers Table
DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers(
	Customer_ID INTEGER PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(50),
    Phone VARCHAR(10),
    City VARCHAR(100),
    Country VARCHAR(100)
);

-- Creating Structure for Orders Table
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
	Order_ID INTEGER PRIMARY KEY,
    Customer_ID INTEGER,
    Book_ID INTEGER,
    Order_Date DATE,
    Quantity INTEGER,
    Total_Amount DECIMAL(10,2),
    Constraint fk_customers FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID) ON DELETE CASCADE,
    Constraint fk_books FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID) ON DELETE CASCADE
);

-- Importing Data for Books tables
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Books.csv'
INTO TABLE Books
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Importing Data for Customers tables
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Importing data for Orders tables
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Orders.csv'
INTO TABLE Orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Fetching three tables records
SELECT * FROM Books ;
SELECT * FROM Customers ;
SELECT * FROM Orders ;

-- Data Cleaning
SET SQL_SAFE_UPDATES=0;
SELECT Country,length(Country) FROM Customers LIMIT 10;   -- returned mismatched length of the country.
UPDATE Customers
SET Country= REPLACE(Country,'\r','');
      -- checking for null values;
SELECT * FROM Books WHERE Book_ID is NULL;
SELECT * FROM Customers WHERE Customer_ID is NULL;
SELECT * FROM Orders WHERE Order_ID is NULL;

				--  QUERIES
                
-- Que:1) Retrieve all books in the "Fiction" genre
SELECT * FROM Books
WHERE Genre='Fiction';

-- Que:2)  Find books published after the year 1950
SELECT * FROM Books
WHERE Published_Year>1950;

-- Que:3)  List all customers from the Canada
SELECT * FROM Customers 
Where Country='Canada';

 -- Que: 4) Show orders placed in November 2023
SELECT * FROM Orders
WHERE Order_Date BETWEEN '2023-11-01' AND LAST_DAY('2023-11-01');

-- Que: 5) Retrieve the total stock of books available
SELECT sum(stock) as Total_Stock
FROM Books;

-- Que:6) Find the details of the most expensive book
SELECT * FROM Books
ORDER BY Price DESC LIMIT 1;

-- Que: 7) Show all customers who ordered more than 1 quantity of a books
SELECT 
	c.Customer_ID, 
    c.Name,
    sum(o.Quantity) as "Total Quantity Ordered" 
FROM Customers c JOIN Orders o
ON c.Customer_ID=o.Customer_ID 
GROUP BY 1,2
HAVING SUM(o.Quantity) > 1
ORDER BY 1,2;

-- Que: 8) Retrieve all orders where the total amount exceeds $20
SELECT * FROM Orders
WHERE Total_Amount > 20;

-- Que: 9) List all genres available in the Books table
SELECT DISTINCT Genre FROM Books;

-- Que: 10) Find the book with the lowest stock
SELECT * FROM Books
ORDER BY Stock LIMIT 1;

-- Que:11) Calculate the total revenue generated from all orders
SELECT Concat("$",sum(Total_Amount)) as Total_Revenue
FROM Orders;

                
-- Que:12) Retrieve the total number of books sold for each genre 
SELECT b.Genre,sum(o.Quantity) as Total_Books_Sold
FROM Books b JOIN Orders o
ON b.Book_ID=o.Book_ID
GROUP BY b.Genre;

-- Que: 13) Find the average price of books in the "Fantasy" genre
SELECT 
	'Fantasy' As Genre,
	CONCAT("$",ROUND(Avg(price),2)) as Average_Price 
FROM Books;

-- Que:14) List customers who have placed at least 2 orders
SELECT 
	c.Customer_ID,
    c.Name,
    count(o.Order_ID) As Total_Orders
FROM Customers c JOIN Orders o
ON c.Customer_ID=o.Customer_ID
GROUP BY c.Customer_ID,c.Name
HAVING count(o.Order_ID)>=2;

-- Que: 15) Find the most frequently ordered book
SELECT 
    b.Title,
    b.Genre,
    count(o.Book_ID) As 'Frequency'
FROM Books b JOIN Orders o
ON b.Book_ID=o.Book_ID
GROUP BY b.Title,b.Genre
ORDER BY Frequency DESC
LIMIT 1;

-- Que: 16) Show the top 3 most expensive books of 'Fantasy' Genre 
SELECT
	Book_ID,
    Title,
    'Fiction' As Genre,
    Price
FROM Books
WHERE Genre='Fiction'
ORDER BY Price DESC
LIMIT 3;

 -- Que:17) Retrieve the total quantity of books sold by each author
 SELECT 
	b.Author,
	Sum(O.Quantity) as "Total Books Sold"
FROM Books b JOIN Orders O 
ON b.Book_ID=O.Book_ID
GROUP BY b.Author
ORDER BY b.Author;
 
 -- Que: 18) List the cities where customers who spent over $30 are located
 SELECT
	   c.City
FROM Customers c JOIN Orders o
ON c.Customer_ID=o.Customer_ID
GROUP BY c.City
HAVING sum(o.Total_Amount)> 30;
    
-- Que: 19) Find the customer who spent the most on orders
SELECT
	C.Customer_ID,
    C.Name,
    sum(O.Total_Amount) As Total_Spending
FROM Customers C JOIN Orders O
ON C.Customer_ID=O.Customer_ID
GROUP BY C.Customer_ID,C.Name
ORDER BY sum(O.Total_Amount) DESC
LIMIT 1;

-- Que:20) Calculate the stock remaining after fulfilling all orders
SELECT 
	b.Book_ID,
    b.Title,
    b.Stock As Initial_Stock,
    sum(o.Quantity) As Total_Quantity_Sold,
    b.Stock-sum(o.Quantity) As "Total Stocks remaining"
FROM Books b JOIN Orders o
ON b.Book_ID=o.Book_ID
GROUP BY b.Book_ID
ORDER BY b.Book_ID;
