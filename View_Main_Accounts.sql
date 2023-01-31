CREATE VIEW View_Main_Accounts
AS
SELECT	DISTINCT
	RTRIM(ActNumbr_1) + '-' + RTRIM(ActNumbr_2) + '-' + LEFT(ActNumbr_3, 3) AS Account,
	MAX(ActDescr) AS Description
FROM	GL00100
GROUP BY RTRIM(ActNumbr_1) + '-' + RTRIM(ActNumbr_2) + '-' + LEFT(ActNumbr_3, 3)

SELECT * FROM GL00102
SELECT * FROM GL00100