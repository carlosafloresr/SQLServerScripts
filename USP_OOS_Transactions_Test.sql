USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OOS_Transactions]    Script Date: 5/25/2017 12:10:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_OOS_Transactions_Test 'AIS', 'OOSAIS_052517', '0', Null, 'A1693'
EXECUTE USP_OOS_Transactions 'AIS', 'OOSAIS_052517'
*/
ALTER  PROCEDURE [dbo].[USP_OOS_Transactions_Test]
	@Company	Varchar(5),
	@BatchId	Varchar(25),
	@Processed	Char(1) = '0',
	@Filter		Varchar(2000) = Null,
	@VendorId	Varchar(12) = Null
AS
DECLARE	@Query	Varchar(2000)

--EXECUTE dbo.USP_Delete_OOS_DuplicatedTransactions @BatchId

IF @Filter = ''
	SET @Filter = Null
	
IF @VendorId = ''
	SET @VendorId = Null

SELECT	TR.*, 
		GPCustom.dbo.PROPER(VM.DriverName) AS VendorName, 
		RTRIM(TR.VendorId) AS DriverId, 
		CompanyName, 
		ISNULL(TE.FPT,0) AS FPT, 
		ISNULL(TE.FEE,0) AS FEE, 
		ISNULL(TE.DPY,0) AS DPY, 
		ISNULL(TE.GPS,0) AS GPS 
FROM	View_OOS_Transactions_Test TR 
		LEFT JOIN VendorMaster VM ON TR.VendorId = VM.VendorId 
		LEFT JOIN Companies CO ON TR.Company = CO.CompanyId
		LEFT JOIN OOS_Transactions_Extras TE ON TR.BatchId = TE.BatchId AND TE.VendorId = TR.VendorId 
WHERE	TR.Trans_DeletedBy IS Null 
		AND TR.BatchId = @BatchId
		AND TR.Hold = 0 
		AND TR.Processed = @Processed 
		AND DeductionAmount <> 0
		AND (@Filter IS Null OR (@Filter IS NOT Null AND dbo.AT(DeductionCode, @Filter, 1) > 0))
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND TR.VendorId = @VendorId))
ORDER BY TR.VendorId, DeductionCode

/*
USP_OOS_Transactions 'AIS','NONE',0,NULL,NULL
USP_OOS_Transactions 'GIS','OOSGIS_030812',0,NULL,NULL
USP_OOS_Transactions 'AIS','OOSAIS_070209',1
SELECT * FROM View_OOS_Transactions
*/