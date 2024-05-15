# Seattle Public Library Management System

## Project Overview
This SQL project aims to enhance the operational efficiency and user engagement of the Seattle Public Library through advanced database management techniques.

## Project Objectives
- **Enhance Collection Development:** Improve acquisition strategies by analyzing author-publisher collaborations to ensure a relevant and diverse collection.
- **Optimize Inventory Management:** Adjust inventory based on book popularity metrics to align with patron preferences and improve access to popular titles.
- **Foster Accountability:** Use fine accrual data to promote policy compliance and enhance revenue management.
- **Improve User Experience:** Simplify user search efforts and improve navigation within the library through better cataloging practices.
- **Enhance User Engagement:** Personalize services by tracking individual user activities to recognize and respond to engagement patterns.

## Files Included
- **SQL Code:** Contains scripts for database schema creation and queries.
- **Data Files:** Include crucial attributes for Library Users, Books, Genres, Authors, Publishers, Loans, Reserves, and more, essential for database modeling and querying.

## Database Model Description
The database includes the following entities and their relations:
- **Library User:** Represents individuals with personal library accounts. Attributes include UserID, FirstName, LastName, BirthDate, UserStatus, and LoanerNumber.
- **Book:** Identified by BookID, includes Title, ReleaseYear, PageCount, TextLanguage, and TotalQuantity.
- **Genre:** Defined by GenreID, includes Type (e.g., Fiction, Non-fiction) and Subtype (e.g., Horror, Thriller).
- **Author:** Tagged with AuthorID, includes FirstName, LastName, and Nationality.
- **Publisher:** Identified by PublisherID, includes Name and HQCountry.
- **Loans:** A relationship that records the borrowing details of books by users.
- **Reserves:** Manages reservations for books when not immediately available.
- **Writes:** Connects authors to the books they have written.

## Entity Relationship Diagram (ERD)
![image](https://github.com/yukti-jain/Seattle-Public-Library-Management-System/assets/63353638/378c0731-654d-4991-8ee4-3284c5e38832)


## Team Members
- Hummarah Shahzad
- Karan Karnik
- Monika Madugula
- Pratik Mahesh Merchant
- Yukti Jain
