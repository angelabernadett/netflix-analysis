USE SQLProject

Select *
From NetflixTitles

--DATA CLEANING

--Finding entries that are off
Select *
From NetflixTitles
Where show_id NOT LIKE 's%'

Delete from NetflixTitles
Where show_id IN ( 
Select show_id
From NetflixTitles
Where show_id NOT LIKE 's%')

--Convert date format
Select date_added, PARSE(date_added AS DATE)
From NetflixTitles

Update NetflixTitles
SET date_added = PARSE(date_added AS DATE)

Select director
From NetflixTitles
Where director is null

--Check and delete duplicate entries 
WITH RowNumberCTE AS(
Select *, 
ROW_NUMBER() OVER (
PARTITION BY title, director, cast, country, date_added, release_year, genre ORDER BY title) as row_number
From NetflixTitles
)
Delete from NetflixTitles
Where show_id IN ( 
Select show_id
From RowNumberCTE
Where row_number > 1
)

--Populate the NULL values with 'Not Given'
Update NetflixTitles
SET director = 'Not Given'
Where director IS NULL

Update NetflixTitles
SET cast = 'Not Given'
Where cast IS NULL

Update NetflixTitles
SET country = 'Not Given'
Where country IS NULL

--Split the country column so that we only have one country per movie
Select SUBSTRING(country, 1, CHARINDEX(',', country) -1) , CHARINDEX(',', country)
From NetflixTitles
Where CHARINDEX(',', country) <> 0

Update NetflixTitles
SET country = SUBSTRING(country, 1, CHARINDEX(',', country) -1)
Where CHARINDEX(',', country) <> 0

--Split the listed_in column so that we only have one per movie, rename it as genre
Select SUBSTRING(listed_in, 1, CHARINDEX(',', listed_in) -1) , CHARINDEX(',', listed_in)
From NetflixTitles
Where CHARINDEX(',', listed_in) <> 0

Update NetflixTitles
SET listed_in = SUBSTRING(listed_in, 1, CHARINDEX(',', listed_in) -1)
Where CHARINDEX(',', listed_in) <> 0

EXEC sp_rename 'NetflixTitles.listed_in', 'genre', 'COLUMN';

--Drop unused columns
ALTER TABLE NetflixTitles
DROP COLUMN description

--DATA EXPLORATION

--Top 10 most common genres
Select TOP 10 genre, count(genre)
From NetflixTitles
Group by genre
Order by count(genre) desc

--Percentage of movies compared to tv shows
Select type, count(*) * 100.0 / sum(count(*)) over() as Percentage
From NetflixTitles
Group by type

--Number of added movies/tv shows throughout the years
Select YEAR(date_added) as Year, count(YEAR(date_added)) as NumberOfMoviesAndShows
From NetflixTitles
Group by YEAR(date_added)
Order by YEAR(date_added) desc

--The oldest and latest realeased titles that were added
Select TOP 5 title, release_year, date_added
From NetflixTitles
Order by release_year desc, date_added desc

Select TOP 5 title, release_year, date_added
From NetflixTitles
Order by release_year asc, date_added asc