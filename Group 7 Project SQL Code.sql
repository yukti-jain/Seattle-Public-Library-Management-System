#1.	Analysis of Books Published by Authors and Publishers

SELECT A.LastName AS AuthorName, P.PublisherName AS PublisherName, COUNT(*) AS BooksPublished
FROM Writes W
INNER JOIN Author A ON W.AuthorID = A.AuthorID
INNER JOIN Book B ON W.BookID = B.BookID
INNER JOIN Publisher P ON B.PublisherID = P.PublisherID
GROUP BY A.LastName, P.PublisherName
ORDER BY BooksPublished DESC;

#2. Book Popularity Ranking Based on Loan Frequency

SELECT B.Title, COUNT(*) AS LoanFrequency, 
    RANK() OVER (ORDER BY COUNT(*) DESC) AS PopularityRank
FROM Loans L
INNER JOIN Book B ON L.BookID = B.BookID
GROUP BY B.Title;

#3. User Fine Ranking Based on Accumulated Library Fines

SELECT LU.UserID, SUM(F.Amount) AS TotalFines, 
RANK() OVER (ORDER BY SUM(F.Amount) DESC) AS FineRank
FROM LibraryUser LU 
 LEFT OUTER JOIN Fine F ON LU.UserID = F.UserID 
 GROUP BY LU.UserID;

#4. Genre-Based Book Ranking by Page Count:

SELECT 
	b.Title,
	 g.GenreType,
	 CONCAT(a.FirstName, ' ', a.LastName) AS AuthorName,
	 b.PageCount,
	 DENSE_RANK() OVER(PARTITION BY g.GenreType ORDER BY b.PageCount DESC) AS PageRank,
	 COUNT(b.BookID) OVER(PARTITION BY g.GenreType) AS TotalBooksInGenre,
	 FIRST_VALUE(b.Title) OVER(PARTITION BY g.GenreType ORDER BY b.PageCount DESC) AS LongestBook,
	 CASE WHEN b.PageCount >= 300 THEN 'Long' ELSE 'Short' END AS LengthCategory
 FROM 
	Book b
	 JOIN Genre g ON b.GenreID = g.GenreID
	 JOIN Writes w ON b.BookID = w.BookID
	 JOIN Author a ON w.AuthorID = a.AuthorID
 ORDER BY 
	g.GenreType, PageRank;

#5. User Engagement and Activity Analysis Based on Loan and Reservation Status

SELECT 
	lu.UserID,
	 CONCAT(lu.FirstName, ' ', lu.LastName) AS UserName,
	 b.Title,
	 COALESCE(l.LoanedStatus, r.ReservedStatus) AS Status,
	 ROW_NUMBER() OVER(PARTITION BY lu.UserID ORDER BY COALESCE(l.LoanedDate, r.ReservedDate) DESC) AS RecentActivityRank,
	 COUNT(l.BookID) OVER(PARTITION BY lu.UserID) AS TotalLoans,
	 COUNT(r.BookID) OVER(PARTITION BY lu.UserID) AS TotalReservations
 FROM 
	LibraryUser lu
	 LEFT JOIN Loans l ON lu.UserID = l.UserID
	 LEFT JOIN Reserves r ON lu.UserID = r.UserID
	 JOIN Book b ON b.BookID = COALESCE(l.BookID, r.BookID)
 ORDER BY 
	lu.UserID, RecentActivityRank;

#6. Loan Duration Analysis with Fine Assessment

SELECT 
	L.UserID, 
	L.BookID, 
	DATEDIFF(IFNULL(L.ReturnedDate, CURRENT_DATE), L.LoanedDate) AS LoanDuration,
	IFNULL(F.Amount, 0) AS FineAmount,
	CASE 
		WHEN DATEDIFF(IFNULL(L.ReturnedDate, CURRENT_DATE), L.LoanedDate) > 30 THEN 'Long Loan'
		ELSE 'Regular Loan'
	END AS LoanType
FROM Loans L
LEFT JOIN Fine F ON L.UserID = F.UserID
WHERE L.LoanedStatus = 'RETURNED'
ORDER BY LoanDuration DESC;

#7. Author Popularity Ranking by Loan Frequency

SELECT 
	A.AuthorID,
	A.FirstName,
	A.LastName,
	COUNT(L.BookID) AS TotalLoans,
	RANK() OVER (ORDER BY COUNT(L.BookID) DESC) AS PopularityRank
FROM Author A
JOIN Writes W ON A.AuthorID = W.AuthorID
JOIN Loans L ON W.BookID = L.BookID
WHERE A.LastName REGEXP '^[A-M]' -- Authors with last names starting from A to M
GROUP BY A.AuthorID, A.FirstName, A.LastName
ORDER BY TotalLoans DESC;

#8. User Engagement Ranking by Combined Loan and Reserve Activities

SELECT 
	U.UserID, 
	U.FirstName, 
	U.LastName, 
	COUNT(DISTINCT L.BookID) AS TotalLoans,
	COUNT(DISTINCT R.BookID) AS TotalReserves,
	(COUNT(DISTINCT L.BookID) + COUNT(DISTINCT R.BookID)) AS TotalActivities
FROM LibraryUser U
LEFT JOIN Loans L ON U.UserID = L.UserID
LEFT JOIN Reserves R ON U.UserID = R.UserID
WHERE EXISTS (SELECT 1 FROM Fine F WHERE F.UserID = U.UserID)
GROUP BY U.UserID, U.FirstName, U.LastName
HAVING TotalActivities > 0
ORDER BY TotalActivities DESC;

#9.  New Releases Information Across 

DELIMITER $$
CREATE PROCEDURE GetBooksByGenre(IN genreType VARCHAR(255))
BEGIN
    SELECT 
        b.Title AS BookTitle,
        CONCAT(a.FirstName, ' ', a.LastName) AS AuthorName,
        p.PublisherName,
        b.ReleaseYear,
        b.TotalQuantity,
        COALESCE(g.GenreSubtype, 'Not Specified') AS GenreSubtype,
        CASE 
            WHEN b.PageCount < 200 THEN 'Short Story'
            WHEN b.PageCount BETWEEN 200 AND 500 THEN 'Novel'
            ELSE 'Epic'
        END AS BookLength,
        RANK() OVER(PARTITION BY g.GenreType ORDER BY b.ReleaseYear DESC) AS NewnessRank
    FROM 
        Book b
        JOIN Writes w ON b.BookID = w.BookID
        JOIN Author a ON w.AuthorID = a.AuthorID
        JOIN Publisher p ON b.PublisherID = p.PublisherID
        JOIN Genre g ON b.GenreID = g.GenreID
    WHERE 
        g.GenreType = genreType
    ORDER BY 
        b.ReleaseYear DESC, BookTitle;
END$$
DELIMITER ;

CALL GetBooksByGenre('Fiction');

#10. Top Loaned Books with Author and Publishing Details

WITH BookLoans AS (
    SELECT 
        BookID,
        COUNT(BookID) AS LoanCount
    FROM 
        Loans
    GROUP BY 
        BookID
),
AuthorInfo AS (
    SELECT 
        w.BookID,
        CONCAT(a.FirstName, ' ', a.LastName) AS AuthorName,
        a.Nationality
    FROM 
        Writes w
        JOIN Author a ON w.AuthorID = a.AuthorID
),
BookDetails AS (
    SELECT 
        b.BookID,
        b.Title,
        b.ReleaseYear,
        g.GenreType,
        p.PublisherName,
        bl.LoanCount,
        ai.AuthorName,
        ai.Nationality
    FROM 
        Book b
        JOIN Genre g ON b.GenreID = g.GenreID
        JOIN Publisher p ON b.PublisherID = p.PublisherID
        LEFT JOIN BookLoans bl ON b.BookID = bl.BookID
        LEFT JOIN AuthorInfo ai ON b.BookID = ai.BookID
)
SELECT 
    Title,
    AuthorName,
    Nationality,
    GenreType,
    PublisherName,
    ReleaseYear,
    LoanCount
FROM 
    BookDetails
WHERE 
    LoanCount IS NOT NULL
ORDER BY 
    LoanCount DESC, ReleaseYear DESC
LIMIT 10;

############################################################################################
