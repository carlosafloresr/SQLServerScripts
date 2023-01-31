/*
EXECUTE USP_PrePay_Relieve 'GLSO', '1000', '09-100033', 119
*/
ALTER PROCEDURE USP_PrePay_Relieve
		@Company	Varchar(5),
		@VendorId	Varchar(10),
		@Document	Varchar(30),
		@Amount		Numeric(10,2)
AS
SET NOCOUNT ON

DECLARE	@Query		Varchar(MAX),
		@DCSTATUS	Smallint,
		@Table1		Varchar(12),
		@Table2		Varchar(12)

DECLARE @tblAPMast	Table (DCSTATUS Smallint)

SET @Query = N'SELECT DCSTATUS FROM ' + @Company + '.dbo.PM00400 PM1 WHERE VENDORID = ''' + @VendorId + ''' AND DOCNUMBR = ''' + @Document + ''''

INSERT INTO @tblAPMast
EXECUTE(@Query)

SET @DCSTATUS = (SELECT DCSTATUS FROM @tblAPMast)

IF @DCSTATUS = 1
BEGIN
	SET @Table1 = 'PM10000'
	SET @Table2 = 'PM10100'
END

IF @DCSTATUS = 2
BEGIN
	SET @Table1 = 'PM20000'
	SET @Table2 = 'PM10100'
END

IF @DCSTATUS = 2
BEGIN
	SET @Table1 = 'PM30200'
	SET @Table2 = 'PM30600'
END

SET @Query = N'SELECT	RTRIM(GL5.ACTNUMST) AS ACTNUMST
FROM	' + @Company + '.dbo.' + @Table1 + ' PM1
		INNER JOIN ' + @Company + '.dbo.' + @Table2 + ' PM2 ON PM1.VCHNUMWK = PM2.VCHRNMBR AND PM1.VENDORID = PM2.VENDORID
		INNER JOIN ' + @Company + '.dbo.GL00105 GL5 ON PM2.DSTINDX = GL5.ACTINDX
WHERE	PM2.DEBITAMT <> 0
		AND PM1.VENDORID = ''' + @VendorId + '''
		AND PM1.DOCNUMBR = ''' + @Document + '''
		AND PM2.DEBITAMT = ' + CAST(@Amount AS Varchar)

EXECUTE(@Query)