-- Creating my dadtabase in Azure Data Studio called SQLPortfolio1
CREATE DATABASE SQLPortfolio1;

--The ladder score or Life_Ladder, the Cantril ladder: it asks respondents to think of a ladder, with the best possible life for them being a 10 and the worst possible life being a 0. They are then asked to rate their own current lives on that 0 to 10 scale.

--SELECTING Top 10 countries with the highest Life_Ladder score in 2020.
SELECT TOP 10 *
FROM SQLPortfolio1.dbo.[world-happiness-report]
ORDER BY 2 DESC, 3 DESC;

--Selecting Top 10 countries with the highest Life_Ladder score in 2020 using DENSE_RANK().
SELECT TOP 10 DENSE_RANK() OVER (ORDER BY Life_Ladder DESC) AS Rank, *
FROM SQLPortfolio1.dbo.[world-happiness-report]
Where [year] = 2020

--SELECTING Top 10 countries with the lowest Life_Ladder score in 2020.
SELECT TOP 10 *
FROM SQLPortfolio1.dbo.[world-happiness-report]
ORDER BY 2 DESC, 3;

--Finding missing year records for each country by using CTE, Left Join, and declare.
declare @startyear SMALLINT = 2005;
declare @endyear SMALLINT = 2020;

WITH Missing_Year AS
( SELECT @startyear AS year
  UNION ALL
  SELECT CAST(([year]+1) as SMALLINT)
  From Missing_Year
  WHERE CAST(([year]+1) as SMALLINT) <= @endyear
)
SELECT Missing_Year.[year], SQLPortfolio1.dbo.[world-happiness-report].[Country_name], SQLPortfolio1.dbo.[world-happiness-report].[year] from Missing_Year
LEFT JOIN SQLPortfolio1.dbo.[world-happiness-report]
ON Missing_Year.[year] = SQLPortfolio1.dbo.[world-happiness-report].[year]
-- SELECT Missing_Year.[year], SQLPortfolio1.dbo.[world-happiness-report].[Country_name] from Missing_Year
-- FULL OUTER JOIN SQLPortfolio1.dbo.[world-happiness-report]
-- ON Missing_Year.[year] = SQLPortfolio1.dbo.[world-happiness-report].[year]

-- Converting the column, Freedom_to_make_life_choices, to percentages and sort the column and the year column in descending order, and selecting top 10 countries in 2020 to see the correlation between the life ladder and the percentages.
-- SELECT TOP 10 *, (Freedom_to_make_life_choices * 100)  AS Percentage_for_Freedom
-- FROM SQLPortfolio1.dbo.[world-happiness-report]
-- WHERE Freedom_to_make_life_choices IS NOT NULL
-- ORDER BY 2 DESC , 12 DESC;

--Trying to identify the Number of Countries who have the least amount till mid range in Freedom_to_make_life_choices in 2020.
--So, play with the second column by making it ascending sort.
--Then you can replace Freedom_to_make_life_choices with Life_Ladder column to apply the above steps as well.
-- SELECT Country_name, Life_Ladder
-- FROM SQLPortfolio1.dbo.[world-happiness-report]
-- Where [year] = 2020
-- Order By 2 DESC;

--After you get the number of countries from minimum to mid range in both Freedom_to_make_life_choices and Life_Ladder columns.
--You can compute for what is the percentage wise for the countries to fall in both of those ranges compared to the countries that have fall in only the range for only one column.
-- SELECT COUNT(Freedom_to_make_life_choices) AS Percentageofcountriesthatfallinrangeforbothcolumns
-- FROM SQLPortfolio1.dbo.[world-happiness-report]
-- WHERE [year] = 2020 AND Freedom_to_make_life_choices IS NOT NULL AND Life_Ladder <= 5.885 AND Life_Ladder >= 3.16 AND Freedom_to_make_life_choices >= 0.824 AND Freedom_to_make_life_choices <= 0.965

-- Converting the column, Perceptions_of_corruption, to percentages and sort this column and the year column in descending order, and selecting top 10 countries in 2020 to see the correlation between the life ladder and the percentages.
-- SELECT TOP 10 *, (Perceptions_of_corruption * 100)  AS Percentage_for_Corruption
-- FROM SQLPortfolio1.dbo.[world-happiness-report]
-- WHERE Perceptions_of_corruption IS NOT NULL
-- ORDER BY 2 DESC, 12 DESC;

-- Converting the column, Positive_affect, to percentages and sort this column and the year column in descending order, and selecting top 10 countries in 2020 to see the correlation between the life ladder and the percentages.
-- SELECT TOP (10) Country_name, year, Life_Ladder, Positive_affect, (Positive_affect * 100)  AS Percentage_for_Positive, AVG(Life_Ladder) OVER (Partition BY Country_name) AS Average_lifeladder
-- FROM SQLPortfolio1.dbo.[world-happiness-report]
-- group by Country_name, year, Life_Ladder, Positive_affect
-- ORDER BY 2 DESC , 5 DESC;

-- Converting the column, Negative_affect, to percentages and sort this column in descending order to see the correlation between the life ladder and the percentages.
SELECT DISTINCT Country_name, (Negative_affect * 100)  AS Percentage_for_Negative, AVG(Life_Ladder) OVER (Partition BY Country_name) AS Average_lifeladder, Life_Ladder
FROM SQLPortfolio1.dbo.[world-happiness-report]
GROUP BY Country_name, Negative_affect, Life_Ladder
ORDER BY 2 DESC, 3 DESC;

--Average Life_Ladder score in each year.
SELECT [year], AVG(Life_Ladder) AS Average_lifeLadder
FROM SQLPortfolio1.dbo.[world-happiness-report]
GROUP BY [year]
ORDER BY 1;

--Average Life_Ladder score in 16 years.
SELECT AVG(Life_Ladder) AS Average_lifeLadder
FROM SQLPortfolio1.dbo.[world-happiness-report]
-- GROUP BY [year]
ORDER BY 1 DESC;

--Creating temp table called #TempTable1.
CREATE TABLE #TempTable1 (
  year smallint,
  Average_lifeLadder FLOAT
);

--Inserting the Average life ladder score in each year into the temp table, #TempTable1.
INSERT INTO #TempTable1 (year, Average_lifeLadder)
SELECT [year], AVG(Life_Ladder) AS Average_lifeLadder
FROM SQLPortfolio1.dbo.[world-happiness-report]
GROUP BY [year]
ORDER BY 1;

SELECT * FROM #TempTable1;

--Creating Stored Procedures with an input parameter, so that people can see the country's average life ladder score from 2005 to 2020 and the standard error of the ladder score measured in 2021.
CREATE PROCEDURE dbo.SPECIFICCOUNTRY
(
    @Country_name NVARCHAR(50)
)
AS
BEGIN
SELECT Country_name, AVG(Life_Ladder) AS Average_lifeLadderfrm2005to2020,(SELECT Standard_error_of_ladder_score FROM SQLPortfolio1.dbo.[world-happiness-report-2021] WHERE Country_name = @Country_name) AS StandarderrorLadderScorein2021
FROM SQLPortfolio1.dbo.[world-happiness-report]
WHERE Country_name = @Country_name
GROUP BY Country_name

END

--Inputting an input parameter, and executing the store procedures to fetch informations about the specific country.
EXEC dbo.SPECIFICCOUNTRY @Country_name = 'Japan';

--To drop a procedure if we don't want it.
DROP PROCEDURE dbo.SPECIFICCOUNTRY;
