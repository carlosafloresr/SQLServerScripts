USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GPBank_OutstandigRecords]    Script Date: 5/1/2020 10:21:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GPBank_OutstandigRecords
*/
ALTER PROCEDURE [dbo].[USP_GPBank_OutstandigRecords]
		@CompanyId	Varchar(5) = Null
AS
SET NOCOUNT ON

DECLARE	@Company	Varchar(5),
		@Query		Varchar(MAX)

DECLARE @tblData	Table (
		[Company]				Varchar(10),
		[checkbook id]			Varchar(30),
		[checkbook description]	Varchar(100), 
		[check date]			Char(10),
		[check number]			Varchar(30), 
		[currency id]			Varchar(15),
		[checkbook amount]		Numeric(10,2), 
		[check name]			Varchar(100))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyID)
FROM	DYNAMICS.dbo.View_Companies
WHERE	CompanyID NOT IN ('ABS','ATEST','FI','RCMR')
		AND CompanyID NOT LIKE 'HIS%'
		AND (CompanyID = @CompanyId
		OR @CompanyId IS Null)

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Escrow updating ' + @Company

	SET @Query = N'SELECT ''' + @Company + ''',
		[checkbook id],
		[checkbook description], 
		CONVERT(Char(10), [trx date], 101) AS [check date],
		[cm trx number] AS [check number], 
		[currency id],
		[checkbook amount], 
		[paid torcvd from] AS [check name]
FROM	AIS.dbo.banktransactions 
WHERE	[cleared date] = ''1/1/1900''
		AND [cm trx type int] = 3
		AND voided = ''NO''
		AND [Reconciled] = ''NO'''
		
	INSERT INTO @tblData
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	*
FROM	@tblData
ORDER BY Company, [check date]