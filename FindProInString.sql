CREATE FUNCTION dbo.FindProInString
(
       @InputString varchar(8000) 
)
RETURNS varchar(8000)
AS
BEGIN
       DECLARE @FoundPro varchar(8000)

       SELECT @FoundPro = CASE 
             WHEN @InputString LIKE '%/[0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%' THEN '0' + RIGHT(SUBSTRING(@InputString,(PATINDEX('%/[0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),9),8)
             WHEN @InputString LIKE '%[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%' THEN SUBSTRING(@InputString,(PATINDEX('%[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),9)
             WHEN @InputString LIKE '%PN:[0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%' THEN '0' + RIGHT(SUBSTRING(@InputString,(PATINDEX('%PN:[0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),11),8)
             WHEN @InputString LIKE '%[0-9]-[0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%' THEN '0' + RIGHT(SUBSTRING(@InputString,(PATINDEX('%[0-9]-[0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),10),8)
             WHEN @InputString LIKE '%[0-9]-[A-Z][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%' THEN '0' + RIGHT(SUBSTRING(@InputString,(PATINDEX('%[0-9]-[A-Z][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),11),8)
             WHEN @InputString LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' THEN LEFT(SUBSTRING(@InputString,(PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),8),2) + '-' + RIGHT(SUBSTRING(@InputString,(PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),8),6)
             ELSE NULL 
       END

       RETURN @FoundPro
END
GO
CREATE FUNCTION dbo.FindContainerInString
(
       @InputString varchar(8000) 
)
RETURNS varchar(8000)
AS
BEGIN
       DECLARE @FoundContainer varchar(8000)

       SELECT @FoundContainer = CASE 
             WHEN @InputString LIKE '%[A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]%' THEN SUBSTRING(@InputString,(PATINDEX('%[A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),10)
             WHEN @InputString LIKE '%[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9][0-9]%' THEN LEFT(SUBSTRING(@InputString,(PATINDEX('%[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),11),4) + RIGHT(SUBSTRING(@InputString,(PATINDEX('%[A-Z][A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),11),6)
             WHEN @InputString LIKE '%TLU[0-9][0-9][0-9][0-9][0-9][0-9]%' THEN 'TLRU' + RIGHT(SUBSTRING(@InputString,(PATINDEX('%TLU[0-9][0-9][0-9][0-9][0-9][0-9]%',@InputString)),9),6)
             ELSE NULL 
       END

       RETURN @FoundContainer
END
GO
