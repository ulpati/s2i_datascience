CREATE TABLE deaths_ranking (
	id serial,
	country VARCHAR(255),
	freq INTEGER
);


COPY deaths_ranking(id, country, freq)
FROM '<file_path>\DeathsRanking.csv' -- insert file path
DELIMITER ','
CSV HEADER;

/*
	Comparison between "deaths_ranking" and "warnings_ranking"
	Using inner join on country (indices do not match for the same country)

	Select the top 15 countries by number of deaths
	---------------------------------------------------------------------------
	SLIDE: Which countries have the most deaths and which have the most warnings?
*/
SELECT a.country AS "country", a.freq AS "deaths", 
       b.sdwarnings_df_nwarnings AS "warnings"
FROM deaths_ranking a
INNER JOIN warnings_ranking b
ON a.country = b.sdwarnings_df_country
ORDER BY a.freq DESC LIMIT 15;

/*
	Select the top 15 countries by number of warnings
	---------------------------------------------------------------------------
	SLIDE: Which countries have the most deaths and which have the most warnings?
*/
SELECT a.country AS "country", b.sdwarnings_df_nwarnings AS "warnings",
	   a.freq AS "deaths"
FROM deaths_ranking a
INNER JOIN warnings_ranking b
ON a.country = b.sdwarnings_df_country
ORDER BY b.sdwarnings_df_nwarnings DESC LIMIT 15;

/*
	Select country, travelers, deaths, deaths per capita, and warnings
	---------------------------------------------------------------------
	SLIDE: Which countries have the most deaths per capita?
*/
SELECT a.validctrys AS "country", a.percap AS "per_capita",
				a.ndeaths AS "deaths", a.ntravelers AS "travelers",
				b.sdwarnings_df_nwarnings AS "warnings"
FROM deaths_per_capital a
INNER JOIN warnings_ranking b
ON a.validctrys = b.sdwarnings_df_country
ORDER BY a.percap DESC;

/*
	Verify the statement from the article: "Mexico, Mali, and Israel have been flagged by most warning agencies in recent years, but American tourists are more likely to be killed in Thailand, Pakistan, and the Philippines"
	Order results by deaths per capita

	Mali has no passenger data so it is NULL in the table
	Mali has no deaths per capita (no passenger data) so it is set to zero only for sorting countries
	-----------------------------------------------------------------------------------
	SLIDE: Let's verify a statement from the article
*/
SELECT a.sdwarnings_df_country AS "country", 
   COALESCE(b.percap,0) AS "per_capita", -- COALESCE() returns the first non-null value
   b.ntravelers AS "travelers", c.freq AS "deaths", 
   a.sdwarnings_df_nwarnings AS "warnings"
FROM warnings_ranking a
LEFT JOIN  deaths_per_capital b
ON a.sdwarnings_df_country = b.validctrys
INNER JOIN deaths_ranking c
ON c.country = a.sdwarnings_df_country
-- use WHERE IN to select the countries of interest
WHERE a.sdwarnings_df_country IN ('Mexico', 'Mali', 'Israel', 'Thailand', 'Pakistan', 'Philippines')
ORDER BY "per_capita" DESC;

/*
	SLIDE: What are the causes of death in the most dangerous country?
*/
SELECT cause_of_death AS "cause_of_death", COUNT(cause_of_death) AS "number_of_deaths"
FROM sdamerican_deaths_abroad_10_09_to_06_16
WHERE country LIKE 'Pakistan' -- select the most dangerous country
GROUP BY cause_of_death
ORDER BY "number_of_deaths" DESC;

/*
	Include the WHERE condition to have at least one death
	----------------------------------------------------------------------------
	SLIDE: Which are the safest countries?
*/
SELECT a.validctrys AS "country", a.percap AS "per_capita",
	a.ndeaths AS "deaths", a.ntravelers AS "travelers",
	b.sdwarnings_df_nwarnings AS "warnings"
FROM deaths_per_capital a
INNER JOIN warnings_ranking b
ON a.validctrys = b.sdwarnings_df_country
WHERE a.ndeaths > 0
ORDER BY a.percap ASC;

/*
	SLIDE: Which countries are most likely to die in a terrorist attack?
*/
SELECT
	country AS "country",
	SUM(CASE WHEN cause_of_death LIKE 'Terrorist%' THEN 1 ELSE 0 END) AS "terrorism_deaths",
	COUNT(*) AS "total_deaths",
	CASE
		WHEN COUNT(*) > 0 THEN
			-- numeric to convert from int to float | ROUND for two decimal places
			ROUND((SUM(CASE WHEN cause_of_death LIKE 'Terrorist%' THEN 1 ELSE 0 END))::numeric / (COUNT(*)::numeric) * 100, 2)
		ELSE
			0.0 -- avoids division by zero if there are no reports
	END AS "percentage"
FROM
	sdamerican_deaths_abroad_10_09_to_06_16
GROUP BY
	country
ORDER BY
	"percentage" DESC;