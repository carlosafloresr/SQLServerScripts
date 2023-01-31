ALTER FUNCTION FindProNumber (@Text Varchar(100))
RETURNS Varchar(100)
AS
BEGIN
	DECLARE	@locText Varchar(100)

	SET @Text = RTRIM(UPPER(@Text))

	SET @locText = CASE 
				WHEN @Text LIKE 'PN:%' AND @Text LIKE '%/%'
					THEN SUBSTRING(@Text, 4, GPCustom.dbo.AT('/', @Text, 1) - 4)

				WHEN @Text LIKE 'PN:%' AND @Text LIKE '%|%'
					THEN SUBSTRING(@Text, 4, GPCustom.dbo.AT('|', @Text, 1) - 4)

				WHEN @Text LIKE 'PN|%' AND @Text LIKE '%|%'
					THEN SUBSTRING(@Text, 4, GPCustom.dbo.AT('|', @Text, 2) - 4) 

				WHEN @Text LIKE 'INV#%' AND @Text LIKE '%/%'
					THEN SUBSTRING(@Text, 5, GPCustom.dbo.AT('/', @Text, 1) - 5) 

				WHEN @Text LIKE 'ICB:%' AND @Text LIKE '%|%'
					THEN SUBSTRING(@Text, 5, GPCustom.dbo.AT('|', @Text, 1) - 5) 

				WHEN @Text NOT LIKE 'PN:%' AND @Text NOT LIKE '%|%' AND @Text LIKE '%/%'
					THEN SUBSTRING(@Text, 1, GPCustom.dbo.AT('/', @Text, 1) - 1) 

				WHEN @Text LIKE '%|%'
					THEN LEFT(@Text, GPCustom.dbo.AT('|', @Text, 1) - 1) 

				WHEN @Text LIKE '%-%' AND LEN(RTRIM(@Text)) < 11
					THEN RTRIM(@Text)
			ELSE '' END

	IF LEN(@locText) BETWEEN 8 AND 10 AND @Text NOT LIKE '%-%'
		SET @locText = LEFT(@locText, 2) + '-' + SUBSTRING(@locText, 3, 10)

	RETURN @locText
END