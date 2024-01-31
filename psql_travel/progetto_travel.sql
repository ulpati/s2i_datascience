-- creare una table (esempio con DeathsRanking)
CREATE TABLE deaths_ranking (
	id serial,
	country VARCHAR(255),
	freq INTEGER
);


-- importare i dati dal file csv (esempio con DeathsRanking)
COPY deaths_ranking(id, country, freq)
FROM '<percorso_file>\DeathsRanking.csv' -- inserire percorso file
DELIMITER ','
CSV HEADER;

/*
	confronto tra "deaths_ranking" e "warnings_ranking"
	usando come inner join la nazione (gli indici non corrispondono per la stessa nazione)

	seleziono le prime 15 nazioni per numero di deceduti
	---------------------------------------------------------------------------
	SLIDE: Quali sono le nazioni con più deceduti e quali con più segnalazioni?
*/
SELECT a.country AS "nazione", a.freq AS "deceduti", 
       b.sdwarnings_df_nwarnings AS "segnalazioni"
FROM deaths_ranking a
INNER JOIN warnings_ranking b
ON a.country = b.sdwarnings_df_country
ORDER BY a.freq DESC LIMIT 15;

/*
	seleziono le prime 15 nazioni per numero di segnalazioni
	---------------------------------------------------------------------------
	SLIDE: Quali sono le nazioni con più deceduti e quali con più segnalazioni?
*/
SELECT a.country AS "nazione", b.sdwarnings_df_nwarnings AS "segnalazioni",
	   a.freq AS "deceduti"
FROM deaths_ranking a
INNER JOIN warnings_ranking b
ON a.country = b.sdwarnings_df_country
ORDER BY b.sdwarnings_df_nwarnings DESC LIMIT 15;

/*
	seleziono nazione, viaggiatori, deceduti, deceduti pro capite e segnalazioni
	---------------------------------------------------------------------
	SLIDE: Quali sono le nazioni con più deceduti pro capite?
*/
SELECT a.validctrys AS "nazione", a.percap AS "pro capite",
				a.ndeaths AS "deceduti", a.ntravelers AS "viaggiatori",
				b.sdwarnings_df_nwarnings AS "segnalazioni"
FROM deaths_per_capital a
INNER JOIN warnings_ranking b
ON a.validctrys = b.sdwarnings_df_country
ORDER BY a.percap DESC;

/*
	verifico la frase dell'articolo "Messico, Mali e Israele i quali sono stati indicati dalla maggior parte degli
	enti di segnalazione negli ultimi anni, ma è più probabile che dei turisti Americani vengono uccisi in Thailandia,
	Pakistan e Filippine"
	ordino i risultati per deceduti pro capite

	Mali non ha dati sui passeggeri quindi risula NULL nella tabella
	Mali non ha dati sui morti pro capite (non avendo passeggeri) quindi viene posto a zero solo per ordinare le nazioni
	-----------------------------------------------------------------------------------
	SLIDE: Verifichiamo un'affermazione dell'articolo
*/
SELECT a.sdwarnings_df_country AS "nazione", 
	   COALESCE(b.percap,0) AS "pro capite", -- COALESCE() restituisce il primo valore non nullo
	   b.ntravelers AS "viaggiatori", c.freq AS "deceduti", 
	   a.sdwarnings_df_nwarnings AS "segnalazioni"
FROM warnings_ranking a
LEFT JOIN  deaths_per_capital b
ON a.sdwarnings_df_country = b.validctrys
INNER JOIN deaths_ranking c
ON c.country = a.sdwarnings_df_country
-- con WHERE IN seleziono le città che mi interessano
WHERE a.sdwarnings_df_country IN ('Mexico', 'Mali', 'Israel', 'Thailand', 'Pakistan', 'Philippines')
ORDER BY "pro capite" DESC;

/*
	SLIDE: Quali sono le cause di decesso nella nazione più pericolosa?
*/
SELECT cause_of_death AS "causa decesso", COUNT(cause_of_death) AS "numero deceduti"
FROM sdamerican_deaths_abroad_10_09_to_06_16
WHERE country LIKE 'Pakistan' -- seleziono la nazione più pericolosa
GROUP BY cause_of_death
ORDER BY "numero deceduti" DESC;

/*
	includere la condizione WHERE per avere almeno un deceduto
	----------------------------------------------------------------------------
	SLIDE: Quali sono le nazioni più sicure?
*/
SELECT a.validctrys AS "nazione", a.percap AS "pro capite",
	   a.ndeaths AS "deceduti", a.ntravelers AS "viaggiatori",
	   b.sdwarnings_df_nwarnings AS "segnalazioni"
FROM deaths_per_capital a
INNER JOIN warnings_ranking b
ON a.validctrys = b.sdwarnings_df_country
WHERE a.ndeaths > 0
ORDER BY a.percap ASC;

/*
	SLIDE: Quali sono le nazioni dov'è più probabile morire in un attentato terroristico?
*/
SELECT
    country AS "nazione",
    SUM(CASE WHEN cause_of_death LIKE 'Terrorist%' THEN 1 ELSE 0 END) AS "deceduti_terrorismo",
    COUNT(*) AS "deceduti_totali",
    CASE
        WHEN COUNT(*) > 0 THEN
            -- numeric per passare da int a float | ROUND per due cifre decimali
            ROUND((SUM(CASE WHEN cause_of_death LIKE 'Terrorist%' THEN 1 ELSE 0 END))::numeric / (COUNT(*)::numeric) * 100, 2)
        ELSE
            0.0 -- evita divisione per zero se non ci sono segnalazioni
    END AS "percentuale"
FROM
    sdamerican_deaths_abroad_10_09_to_06_16
GROUP BY
    country
ORDER BY
    "percentuale" DESC;