USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AP_FSI_InvoiceImage]    Script Date: 8/24/2022 1:29:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_WARNINGS ON
GO
/*
EXECUTE USP_AP_FSI_InvoiceImage_Verify 'PDS', '1016', 'MEDU704470/57111586'
EXECUTE USP_AP_FSI_InvoiceImage_Verify 'OIS', 'PDONEY', 'UST531620_1', 1
*/
ALTER PROCEDURE [dbo].[USP_AP_FSI_InvoiceImage_Verify]
		@Company	Varchar(5),
		@Vendor		Varchar(15),
		@InvoiceNo	Varchar(20),
		@InHold		Bit OUTPUT
AS
SET NOCOUNT ON

DECLARE	@ProjectId	Int,
		@Query		Varchar(MAX),
		@JustReport	Bit = 1,
		@RunProc	Bit = 0,
		@ExclVnd	Bit = 0,
		@Counter	Int = 0,
		@ReturnVal	Int = 0

SELECT	@ExclVnd = ISNULL(ExcludeAutoHold, 0)
FROM	GPVendorMaster
WHERE	Company = @Company
		AND VendorId = @Vendor

IF @ExclVnd = 0
BEGIN
	SET	@ProjectId	= (SELECT ProjectId FROM DexCompanyProjects WHERE ProjectType = 'AP' AND Company = @Company)
	SET @RunProc	= ISNULL((SELECT ParBit FROM Companies_Parameters WHERE CompanyId = @Company AND ParameterCode = 'FSI_AP_Hold'), 0)
	SET @Counter	= IIF(EXISTS(SELECT TOP 1 ProjectId FROM PRIFBSQL01P.FB.dbo.Files WHERE ProjectId = @ProjectId AND Field8 = @Vendor AND Field4 = @InvoiceNo), 1, 0)

	IF @Counter = 0
		SET @ReturnVal = 1
	ELSE
		SET @ReturnVal = 0
END
ELSE
	SET @ReturnVal = 0

SET @InHold = @ReturnVal