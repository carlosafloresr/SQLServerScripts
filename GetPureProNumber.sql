/*
PRINT dbo.GetPureProNumber('D96-166673')
*/
CREATE FUNCTION GetPureProNumber (@ProNumber Varchar(15))
RETURNS Varchar(15)
AS
BEGIN
	DECLARE @strTemp	Varchar(15)

	SET @strTemp = LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) + 6)
	SET @strTemp = LTRIM(RTRIM(REPLACE(REPLACE(@strTemp, 'C', ''), 'D', '')))

	RETURN @strTemp
END