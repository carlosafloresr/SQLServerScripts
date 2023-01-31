/*
EXECUTE USP_Find_EIRIRepairs
*/
CREATE PROCEDURE USP_Find_EIRIRepairs
AS
SET NOCOUNT ON

DECLARE	@Query		Varchar(Max),
		@Equipment	Varchar(15),
		@Repdate1	Varchar(10),
		@Repdate2	Varchar(10),
		@Inv_No		Varchar(15), 
		@Acct_No	Varchar(15), 
		@rep_date	Date, 
		@Tir_No		Varchar(15), 
		@Chassis	Varchar(15), 
		@Container	Varchar(15),
		@EIRINumber	Varchar(12),
		@EIRIDate	Date

DECLARE	@tblData	Table (
		Inv_No		Varchar(15), 
		Acct_No		Varchar(15), 
		rep_date	Date, 
		Tir_No		Varchar(15), 
		Chassis		Varchar(15), 
		Container	Varchar(15),
		EIRINumber	Varchar(12),
		EIRIDate	Date)

DECLARE @tblSWS		Table (
		Code		Varchar(12),
		UDate		Date)

INSERT INTO @tblData
SELECT	TOP 10 Inv_No, Acct_No, CAST(rep_date AS Date) AS rep_date, Tir_No, Chassis, Container, '', ''
FROM	dbo.Invoices 
WHERE 	rep_date BETWEEN DATEADD(dd, -10, GETDATE()) AND GETDATE()
		AND ESTATUS <> 'CANC'
		AND Inv_No IS NOT Null
		AND Chassis NOT LIKE '% %'
		AND Acct_No IN (SELECT CustomerNumber FROM dbo.EIR_Customers WHERE Inactive = 0)
ORDER BY rep_date

DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Inv_No, Acct_No, rep_date, Tir_No, Chassis, Container
FROM	@tblData

OPEN curTransactions 
FETCH FROM curTransactions INTO @Inv_No, @Acct_No, @rep_date, @Tir_No, @Chassis, @Container

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Equipment	= IIF(@Chassis = '', @Container, @Chassis)
	SET	@Repdate1	= CONVERT(Char(10), DATEADD(dd, -40, @rep_date), 110)
	SET	@Repdate2	= CONVERT(Char(10), @rep_date, 110)
	SET @Query		= N'SELECT refcode, UDate FROM Public.DMEqStatus WHERE Cmpy_No = 1 AND dmeqmast_code = ''' + @Equipment + ''' AND UDate BETWEEN ''' + @Repdate1 + ''' AND ''' + @Repdate2 + ''' AND dmstatus_code = ''02'' ORDER BY UDate DESC LIMIT 1'
	PRINT @Equipment + ' - ' + @Query

	INSERT INTO @tblSWS
	EXECUTE dbo.USP_QuerySWS @Query	

	IF @@ROWCOUNT > 0
	BEGIN
		SELECT	@EIRINumber = Code,
				@EIRIDate	= UDate
		FROM	@tblSWS

		UPDATE	@tblData
		SET		EIRINumber	= @EIRINumber,
				EIRIDate	= @EIRIDate
		WHERE	Inv_No		= @Inv_No
				AND Acct_No = @Acct_No
	END

	DELETE @tblSWS

	FETCH FROM curTransactions INTO @Inv_No, @Acct_No, @rep_date, @Tir_No, @Chassis, @Container
END

CLOSE curTransactions
DEALLOCATE curTransactions

SELECT	*
FROM	@tblData
WHERE	EIRINumber <> ''

/*
SELECT	TOP 100 *
FROM	Invoices
WHERE	rep_date > '10/01/2019'
*/