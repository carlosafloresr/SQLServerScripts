USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_Transactions]    Script Date: 12/22/2016 10:17:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_OOS_Transactions]
	@Company	Varchar(5),
	@BatchId	Varchar(25),
	@Processed	Char(1) = '0',
	@Filter		Varchar(2000) = Null,
	@VendorId	Varchar(12) = Null
AS
DECLARE	@Query	Varchar(2000)

EXECUTE dbo.USP_Delete_OOS_DuplicatedTransactions @BatchId

IF @Filter = ''
	SET @Filter = Null
	
IF @VendorId = ''
	SET @VendorId = Null

SET	@Query = 'SELECT TR.*, GPCustom.dbo.PROPER(VM.VendName) AS VendorName, RTRIM(TR.VendorId) AS DriverId, CmpnyNam AS CompanyName, ISNULL(TE.FPT,0) AS FPT, ISNULL(TE.FEE,0) AS FEE, ISNULL(TE.DPY,0) AS DPY, ISNULL(TE.GPS,0) AS GPS FROM View_OOS_Transactions TR LEFT JOIN ' + RTRIM(@Company) + '.dbo.PM00200 VM ON TR.VendorId = VM.VendorId '
SET	@Query = @Query + 'LEFT JOIN Dynamics.dbo.View_AllCompanies CO ON TR.Company = CO.InterID LEFT JOIN OOS_Transactions_Extras TE ON TR.BatchId = TE.BatchId AND TE.VendorId = TR.VendorId '
SET	@Query = @Query + 'WHERE TR.Trans_DeletedBy IS Null AND TR.BatchId = ''' + RTRIM(@BatchId) + ''' AND TR.Hold = 0 AND TR.Processed = ' + @Processed + ' AND DeductionAmount <> 0'

IF @Filter IS NOT Null
BEGIN
	SET	@Query = @Query + ' AND DeductionCode IN (''' + REPLACE(@Filter, ',', ''',''') + ''')'
END

IF @VendorId IS NOT Null
BEGIN
	SET	@Query = @Query + ' AND TR.VendorId = ''' + @VendorId + ''''
END

SET	@Query = @Query + ' ORDER BY TR.VendorId, DeductionCode'

PRINT @Query
EXECUTE(@Query)

/*
USP_OOS_Transactions 'AIS','NONE',0,NULL,NULL
USP_OOS_Transactions 'GIS','OOSGIS_030812',0,NULL,NULL
USP_OOS_Transactions 'AIS','OOSAIS_070209',1
SELECT * FROM View_OOS_Transactions
*/