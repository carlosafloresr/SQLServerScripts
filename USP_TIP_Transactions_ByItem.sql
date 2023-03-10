USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_TIP_Transactions_ByItem]    Script Date: 4/23/2018 3:52:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_TIP_Transactions_ByItem 'GSA_243_97-103082'
*/
ALTER PROCEDURE [dbo].[USP_TIP_Transactions_ByItem]
		@KeyWord		Varchar(50) = Null
AS
DECLARE	@MainCompany	Varchar(5),
		@VendorId		Varchar(20),
		@AR_Document	Varchar(30),
		@Query			Varchar(Max),
		@ValidParams	Bit = 1

SET @MainCompany	= SUBSTRING(@KeyWord, 1, dbo.AT('_', @KeyWord, 1) - 1)
SET @VendorId		= SUBSTRING(@KeyWord, dbo.AT('_', @KeyWord, 1) + 1, dbo.AT('_', @KeyWord, 2) - dbo.AT('_', @KeyWord, 1) - 1)
SET @AR_Document	= SUBSTRING(@KeyWord, dbo.AT('_', @KeyWord, 2) + 1, LEN(@KeyWord) - dbo.AT('_', @KeyWord, 1) - 1)

IF NOT EXISTS(SELECT CompanyId FROM Companies WHERE CompanyId = ISNULL(@MainCompany,'NONE'))
	SET @ValidParams = 0

DECLARE	@tblData Table (
		AR_Document		Varchar(25),
		Ap_VendorId		Varchar(25),
		Ap_Document		Varchar(30),
		Ap_DocDate		Date,
		Ap_DocAmount	Numeric(10,2),
		Ap_BatchNumber	Varchar(30),	
		Ap_Description	Varchar(30))

IF @ValidParams = 1
BEGIN
	SET @AR_Document = LEFT(RTRIM(@AR_Document), 9) 

	IF EXISTS(SELECT AP_Document FROM TIP_Transactions_Assigned WHERE AP_Company = @MainCompany AND VendorId = @VendorId AND AR_Document = @AR_Document)
		INSERT INTO @tblData
		SELECT	AR_Document,
				VendorId,
				AP_Document,
				AP_DocDate,
				AP_DocAmount,
				AP_BatchNumber,
				AP_Description
		FROM	TIP_Transactions_Assigned
		WHERE	AP_Company = @MainCompany 
				AND VendorId = @VendorId 
				AND AR_Document = @AR_Document
	ELSE
	BEGIN
		SET	@Query = N'SELECT	''' + RTRIM(@AR_Document) + ''', AP.VendorId,
				AP.DOCNUMBR,
				AP.DocDate,
				CASE WHEN AP.DOCTYPE < 5 THEN 1 ELSE -1 END * AP.DocAmnt AS DocAmnt,
				AP.BachNumb,
				AP.TrxDscrn
		FROM	' + RTRIM(@MainCompany) + '.dbo.PM20000 AP
		WHERE	AP.VendorId = ''' + RTRIM(@VendorId) + ''' 
				AND LEFT(AP.DOCNUMBR, 9) = ''' + @AR_Document + '''
		ORDER BY 2'

		INSERT INTO @tblData
		EXECUTE(@Query)
	END
END

SELECT	AR_Document,
		Ap_VendorId,
		Ap_Document,
		Ap_DocDate,
		Ap_DocAmount,
		Ap_BatchNumber,
		Ap_Description
FROM	@tblData
ORDER BY 2,6