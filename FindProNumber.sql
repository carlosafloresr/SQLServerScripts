USE [GPCustom]
GO
/****** Object:  UserDefinedFunction [dbo].[FindProNumber]    Script Date: 1/6/2023 4:16:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	
PRINT dbo.FindProNumber('BNSF|95200771|MSKU4596130')
*/
ALTER FUNCTION [dbo].[FindProNumber] (@Text Varchar(100))
RETURNS Varchar(100)
AS
BEGIN
	DECLARE	@locText Varchar(100) = ''

	SET @Text = REPLACE(REPLACE(LTRIM(RTRIM(UPPER(@Text))), ' ', ''), ' ', '')

	IF @Text LIKE '%[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%'
		SET @locText = SUBSTRING(@Text, PATINDEX('%[0-9][0-9]-%', @Text), 9)
	ELSE
	BEGIN
		IF @Text LIKE '%/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'
		BEGIN
			SET @locText = SUBSTRING(@Text, PATINDEX('%/[0-9][0-9]%', @Text) + 1, 8)
			SET @locText = SUBSTRING(@locText, 1, 2) + '-' + SUBSTRING(@locText, 3, 6)
		END
		ELSE
			SET @locText = ''
	END
	
	--IF LEN(@Text) > 8
	--BEGIN
	--	SET @locText = CASE 
	--				WHEN LEN(@Text) = 19 AND SUBSTRING(@Text, 11, 1) = '/' AND ISNUMERIC(SUBSTRING(@Text, 12, 2)) = 1 AND @Text NOT LIKE '%-%'
	--					THEN SUBSTRING(@Text, 12, 2) + + RIGHT(@Text, 6)

	--				WHEN LEFT(@Text, 5) = 'BNSF|' AND dbo.OCCURS('|', @Text) > 1
	--					THEN SUBSTRING(@Text, 6, 9) 

	--				WHEN LEFT(@Text, 3) = 'RPC' AND @Text LIKE '%|%'
	--					THEN ''

	--				WHEN @Text LIKE '%-%' AND @Text NOT LIKE '%|%' AND dbo.OCCURS('-', @Text) = 2 AND @Text NOT LIKE '%PN%'
	--					THEN LEFT(@Text, dbo.AT('-', @Text, 2) - 1)

	--				WHEN SUBSTRING(@Text, 2, 1) = '-' AND dbo.OCCURS('-', @Text) > 1 AND dbo.OCCURS('|', @Text) = 1
	--					THEN SUBSTRING(@Text, dbo.AT('-', @Text, 1) + 1, dbo.AT('|', @Text, 1) - 3)

	--				WHEN ISNUMERIC(LEFT(@Text, 1)) = 0 AND dbo.OCCURS('|', @Text) = 1
	--					THEN SUBSTRING(@Text, dbo.AT('|', @Text, 1) + 1, 12)

	--				WHEN ISNUMERIC(LEFT(@Text, 1)) = 0 AND dbo.OCCURS('|', @Text) = 2
	--					THEN SUBSTRING(@Text, dbo.AT('|', @Text, 2) + 1, 12)

	--				WHEN @Text LIKE '%-%' AND @Text LIKE '%|%' AND @Text NOT LIKE 'ICB%' AND @Text NOT LIKE 'PN:%' AND ISNUMERIC(LEFT(@Text, 1)) = 1
	--					THEN LEFT(@Text, dbo.AT('|', @Text, 1) - 1)

	--				WHEN @Text LIKE 'PN:%' AND GPCustom.dbo.AT('/', @Text, 1) > 1
	--					THEN SUBSTRING(@Text, 4, GPCustom.dbo.AT('/', @Text, 1) - 4)

	--				WHEN @Text LIKE 'PN:%' AND GPCustom.dbo.AT('|', @Text, 1) > 1
	--					THEN SUBSTRING(@Text, 4, GPCustom.dbo.AT('|', @Text, 1) - 4)

	--				WHEN @Text LIKE 'PN|%' AND GPCustom.dbo.AT('|', @Text, 1) > 1
	--					THEN SUBSTRING(@Text, 4, GPCustom.dbo.AT('|', @Text, 2) - 4) 

	--				WHEN @Text LIKE 'INV#%' AND GPCustom.dbo.AT('/', @Text, 1) > 1
	--					THEN SUBSTRING(@Text, 5, GPCustom.dbo.AT('/', @Text, 1) - 5) 

	--				WHEN @Text LIKE 'ICB%' AND @Text LIKE '%\%'
	--					THEN SUBSTRING(@Text, 5, GPCustom.dbo.AT('\', @Text, 1) - 5) 

	--				WHEN @Text LIKE 'ICB%' AND @Text LIKE '%/%' AND GPCustom.dbo.AT('/', @Text, 1) > 5
	--					THEN SUBSTRING(@Text, 5, GPCustom.dbo.AT('/', @Text, 1) - 5) 

	--				WHEN @Text LIKE 'ICB%' AND GPCustom.dbo.AT('|', @Text, 2) > 0
	--					THEN SUBSTRING(@Text, 5, GPCustom.dbo.AT('|', @Text, 2) - 5) 

	--				WHEN @Text LIKE 'ICB:%' AND GPCustom.dbo.AT('|', @Text, 1) > 0
	--					THEN SUBSTRING(@Text, 5, GPCustom.dbo.AT('|', @Text, 1) - 5)

	--				WHEN LEFT(@Text, 3) = 'RPC' AND @Text LIKE '%/%'
	--					THEN SUBSTRING(@Text, dbo.AT('/', @Text, 1) + 1, 12)

	--				WHEN @Text LIKE '%/%' AND @Text LIKE '%-%' AND GPCustom.dbo.AT('/', @Text, 1) > 0 AND GPCustom.dbo.AT('/', @Text, 1) < GPCustom.dbo.AT('-', @Text, 1)
	--					THEN SUBSTRING(@Text, dbo.AT('/', @Text, 1) + 1, 12)

	--				WHEN @Text LIKE '%\%' AND @Text LIKE '%-%' AND GPCustom.dbo.AT('\', @Text, 1) > 0 AND GPCustom.dbo.AT('/', @Text, 1) < GPCustom.dbo.AT('-', @Text, 1)
	--					THEN LEFT(@Text, dbo.AT('\', @Text, 1) - 1)

	--				WHEN @Text NOT LIKE '%/%' AND GPCustom.dbo.AT('-', @Text, 2) > 0 AND LEN(RTRIM(@Text)) < 11
	--					THEN LEFT(@Text, dbo.AT('-', @Text, 2) - 1)

	--				WHEN @Text NOT LIKE '%/%' AND GPCustom.dbo.AT('-', @Text, 2) > 0 AND LEN(RTRIM(@Text)) < 15
	--					THEN RTRIM(@Text)

	--				WHEN @Text LIKE '%-%' AND LEN(RTRIM(@Text)) < 13 AND @Text NOT LIKE 'ICB%'
	--					THEN RTRIM(@Text)

	--				WHEN @Text NOT LIKE 'PN:%' AND @Text NOT LIKE '%|%' AND @Text LIKE '%/%'
	--					THEN SUBSTRING(@Text, 1, GPCustom.dbo.AT('/', @Text, 1) - 1) 

	--				WHEN @Text LIKE '%-%' AND @Text LIKE '%|%' AND @Text NOT LIKE 'ICB%' AND @Text NOT LIKE 'PN:%' AND ISNUMERIC(LEFT(@Text, 1)) = 0
	--					THEN SUBSTRING(@Text, dbo.AT('|', @Text, 2) + 1, 12)

	--				WHEN @Text LIKE '%PN:%' AND GPCustom.dbo.AT('/', @Text, 1) = 0
	--					THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@Text, dbo.AT('PN:', @Text, 1), 15), 'PN:', '')))

	--			ELSE '' END

	--	SET @locText = REPLACE(REPLACE(@locText, '|', ''), '/', '')

	--	IF LEN(@locText) BETWEEN 8 AND 10 AND @Text NOT LIKE '%-%'
	--		SET @locText = LTRIM(LEFT(@locText, 2) + '-' + SUBSTRING(@locText, 3, 10))
	--END
	--ELSE
	--	SET @locText = IIF(@Text LIKE '%-%', @Text, '')

	--IF @locText <> ''
	--BEGIN
	--	IF NOT dbo.AT('-', @locText, 1) BETWEEN 2 AND 4
	--		SET @locText = ''
	--END

	RETURN @locText
END