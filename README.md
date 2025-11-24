# 📚 Online Bookstore SQL Analysis

## 📌 Project Overview
This project demonstrates a relational database analysis for an Online Bookstore. It involves creating a normalized database schema, importing data, performing data cleaning, and executing complex SQL queries to derive business insights regarding sales trends, inventory management, and customer behavior.

## 🗄️ Database Schema

The project utilizes a relational database named `MySQL_P2` with three main tables: **Books**, **Customers**, and **Orders**.

### 1. Books Table
Stores inventory details including title, author, genre, price, and stock levels.
```sql
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
```

### 2. Customers Table
Stores customer demographics and contact information.
```sql
DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers(
    Customer_ID INTEGER PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(50),
    Phone VARCHAR(10),
    City VARCHAR(100),
    Country VARCHAR(100)
);
```

### 3. Orders Table
Links customers to books and tracks transaction details.
```sql
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
```

---

## 📐 Entity Relationship Diagram (ERD)

![ERD Diagram](assets/erd.png)  
*> **Note:** Please replace the path above with the actual location of your ERD image once generated.*

The system is built on a relational schema connecting customers, books, and sales transactions:
* **Customers ↔ Orders:** One-to-Many relationship (One customer, multiple orders).
* **Books ↔ Orders:** One-to-Many relationship (One book, referenced in multiple orders).

---

## 📥 Data Import

Data Can be Imported either using the command line or the MySQL Workbench Import Wizard.

### Option A: Using `LOAD DATA INFILE` (Command Line)
> ⚠️ **Important Note:** File path must be changed i.e, (`'C:/ProgramData/MySQL/...'`) to the actual location of  CSV files on user's local machine.

```sql
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
```

### Option B: Using Import Wizard
If an error is encountered with `LOAD DATA` , use the **Table Data Import Wizard** in MySQL Workbench or the Import function in specific SQL IDE.

---

## 🧹 Data Cleaning

Before analysis, the data underwent a cleaning process to ensure accuracy:
1.  **Carriage Return Removal:** Detected inconsistent string lengths in the `Country` column and removed hidden carriage return characters (`\r`).
2.  **Null Value Checks:** Verified that no primary keys or critical fields contained `NULL` values.

```sql
SET SQL_SAFE_UPDATES=0;

-- Identify mismatched country lengths
SELECT Country, length(Country) FROM Customers LIMIT 10; 

-- Remove carriage returns
UPDATE Customers
SET Country = REPLACE(Country, '\r', '');

-- Checking for null values
SELECT * FROM Books WHERE Book_ID is NULL;
SELECT * FROM Customers WHERE Customer_ID is NULL;
SELECT * FROM Orders WHERE Order_ID is NULL;
```

---

## 📊 Key Analysis & Insights (Intermediate Queries)

Here are some of the Intermediate queries used to derive deeper insights from the data.

### 1. Calculate Remaining Stock After Sales
*Identifies the current inventory status by subtracting sold quantities from the initial stock.*
```sql
SELECT 
    b.Book_ID,
    b.Title,
    b.Stock As Initial_Stock,
    sum(o.Quantity) As Total_Quantity_Sold,
    b.Stock - sum(o.Quantity) As "Total Stocks remaining"
FROM Books b JOIN Orders o
ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID
ORDER BY b.Book_ID;
```

### 2. Identify the Top Spending Customer
*Finds the customer who has generated the highest total revenue.*
```sql
SELECT
    C.Customer_ID,
    C.Name,
    sum(O.Total_Amount) As Total_Spending
FROM Customers C JOIN Orders O
ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_ID, C.Name
ORDER BY sum(O.Total_Amount) DESC
LIMIT 1;
```

### 3. Most Frequently Ordered Book
*Determines which book title appears in the most orders (by frequency).*
```sql
SELECT 
    b.Title,
    b.Genre,
    count(o.Book_ID) As 'Frequency'
FROM Books b JOIN Orders o
ON b.Book_ID = o.Book_ID
GROUP BY b.Title, b.Genre
ORDER BY Frequency DESC
LIMIT 1;
```

### 4. Cities with High Spenders
*Lists cities where customers have spent over $30.*
```sql
SELECT
    c.City
FROM Customers c JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.City
HAVING sum(o.Total_Amount) > 30;
```

---

## 🔎 Basic Analysis Queries
<details>
<summary><strong>Click to expand Basic Queries</strong></summary>
<br>

Below are fundamental queries used to retrieve specific datasets:

**1. Retrieve all books in the "Fiction" genre**
```sql
SELECT * FROM Books WHERE Genre='Fiction';
```

**2. Find books published after the year 1950**
```sql
SELECT * FROM Books WHERE Published_Year>1950;
```

**3. List all customers from Canada**
```sql
SELECT * FROM Customers Where Country='Canada';
```

**4. Show orders placed in November 2023**
```sql
SELECT * FROM Orders
WHERE Order_Date BETWEEN '2023-11-01' AND LAST_DAY('2023-11-01');
```

**5. Retrieve the total stock of books available**
```sql
SELECT sum(stock) as Total_Stock FROM Books;
```

**6. Find the details of the most expensive book**
```sql
SELECT * FROM Books ORDER BY Price DESC LIMIT 1;
```

**7. Show all customers who ordered more than 1 quantity of a book**
```sql
SELECT c.Customer_ID, c.Name, sum(o.Quantity) as "Total Quantity Ordered" 
FROM Customers c JOIN Orders o ON c.Customer_ID=o.Customer_ID 
GROUP BY 1,2 HAVING SUM(o.Quantity) > 1 ORDER BY 1,2;
```

**8. Retrieve all orders where the total amount exceeds $20**
```sql
SELECT * FROM Orders WHERE Total_Amount > 20;
```

**9. List all genres available in the Books table**
```sql
SELECT DISTINCT Genre FROM Books;
```

**10. Find the book with the lowest stock**
```sql
SELECT * FROM Books ORDER BY Stock LIMIT 1;
```

**11. Calculate the total revenue generated from all orders**
```sql
SELECT Concat("$",sum(Total_Amount)) as Total_Revenue FROM Orders;
```

**12. Retrieve the total number of books sold for each genre**
```sql
SELECT b.Genre, sum(o.Quantity) as Total_Books_Sold
FROM Books b JOIN Orders o ON b.Book_ID=o.Book_ID
GROUP BY b.Genre;
```

**13. Find the average price of books in the "Fantasy" genre**
```sql
SELECT 'Fantasy' As Genre, CONCAT("$",ROUND(Avg(price),2)) as Average_Price 
FROM Books;
```

**14. List customers who have placed at least 2 orders**
```sql
SELECT c.Customer_ID, c.Name, count(o.Order_ID) As Total_Orders
FROM Customers c JOIN Orders o ON c.Customer_ID=o.Customer_ID
GROUP BY c.Customer_ID,c.Name
HAVING count(o.Order_ID)>=2;
```

**15. Show the top 3 most expensive books of 'Fantasy' Genre**
```sql
SELECT Book_ID, Title, 'Fiction' As Genre, Price
FROM Books WHERE Genre='Fiction' ORDER BY Price DESC LIMIT 3;
```

**16. Retrieve the total quantity of books sold by each author**
```sql
SELECT b.Author, Sum(O.Quantity) as "Total Books Sold"
FROM Books b JOIN Orders O ON b.Book_ID=O.Book_ID
GROUP BY b.Author ORDER BY b.Author;
```
</details>


## 🚀 How to Run the Project

1. **Clone the Repository**
   ```bash
   git clone [https://github.com/your-username/online-bookstore-analysis.git](https://github.com/your-username/online-bookstore-analysis.git)
   ```
2. Set Up the Database

  - Open your SQL client (MySQL Workbench, DBeaver, or VS Code).
  - Copy the schema creation scripts (Create Database & Tables) and execute them to build the structure.

3. Import the Data

  - Locate the .csv files in the data/ folder of this repository.
  - Update the file paths in the LOAD DATA INFILE commands (see the "Data Import" section) to point to the CSV files on your local machine.
  - Run the import commands

4. Run the Analysis
   
  - Execute the Data Cleaning steps first to handle formatting issues.
  - Run the Intermediate Queries to generate business insights.
