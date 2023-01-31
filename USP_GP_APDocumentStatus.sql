/*
EXECUTE USP_GP_APDocumentStatus 'GLSO', '1000', '09-100033'
EXECUTE USP_GP_APDocumentStatus 'GLSO', '382', 'T1015235'
EXECUTE GPCustom.dbo.USP_GP_APDocumentStatus 'AIS', '50023A', 'TRHU191684/45145505'
*/
ALTER PROCEDURE USP_GP_APDocumentStatus
		@Company	Varchar(5),
		@VendorId	Varchar(10),
		@Document	Varchar(30)
AS
SET NOCOUNT ON

DECLARE	@Query		Varchar(MAX),
		@DCSTATUS	Smallint,
		@Table1		Varchar(12),
		@Table		Varchar(10)

DECLARE @tblAPMast	Table (DCSTATUS Smallint)
DECLARE	@tblData	Table (VENDORID Varchar(12), DOCNUMBR Varchar(30), DOCDATE Date, DOCAMNT Numeric(10,2), CURTRXAM Numeric(10,2), LOCATION Varchar(10))

SET @Query = N'SELECT DCSTATUS FROM ' + @Company + '.dbo.PM00400 PM1 WHERE VENDORID = ''' + @VendorId + ''' AND DOCNUMBR = ''' + @Document + ''''

INSERT INTO @tblAPMast
EXECUTE(@Query)

SET @DCSTATUS = (SELECT DCSTATUS FROM @tblAPMast)

IF @DCSTATUS = 1
BEGIN
	SET @Table	= 'Work'
	SET @Table1 = 'PM10000'
END

IF @DCSTATUS = 2
BEGIN
	SET @Table	= 'Open'
	SET @Table1 = 'PM20000'
END

IF @DCSTATUS = 3
BEGIN
	SET @Table	= 'Historical'
	SET @Table1 = 'PM30200'
END

SET @Query = N'SELECT VENDORID, DOCNUMBR, DOCDATE, DOCAMNT, CURTRXAM, ''' + @Table + ''' AS Location
FROM	' + @Company + '.dbo.' + @Table1 + ' 
WHERE	VENDORID = ''' + @VendorId + '''
		AND DOCNUMBR = ''' + @Document + ''''

		PRINT @Query
INSERT INTO @tblData
EXECUTE(@Query)

IF @@ROWCOUNT = 0
	SELECT	@VendorId AS VENDORID,
			@Document AS DOCNUMBR,
			Null AS DOCDATE,
			Null AS DOCAMNT,
			Null AS CURTRXAM,
			'Not Found' AS [Status]
ELSE
	SELECT	VENDORID, 
			DOCNUMBR, 
			DOCDATE, 
			DOCAMNT, 
			CURTRXAM,
			LOCATION + '-' + CASE WHEN DOCAMNT = CURTRXAM THEN 'Unpaid' WHEN CURTRXAM = 0 THEN 'Paid' ELSE 'Partially Paid' END AS [Status]
	FROM	@tblData