USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AP_FSI_InvoiceImage]    Script Date: 8/24/2022 1:29:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AP_FSI_InvoiceImage 'PDS', '1016', 'MEDU704470/57111586', 1
EXECUTE USP_AP_FSI_InvoiceImage 'OIS', 'PDONEY', 'UST531620_1', 1
*/
ALTER PROCEDURE [dbo].[USP_AP_FSI_InvoiceImage]
		@Company	Varchar(5),
		@Vendor		Varchar(15),
		@InvoiceNo	Varchar(20),
		@JustReport	Bit = 0
AS
SET NOCOUNT ON

DECLARE	@ProjectId	Int,
		@Query		Varchar(MAX),
		@InHold		Bit = 0,
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

	IF @RunProc = 0
		SET @JustReport	= 1
	ELSE
		SET @JustReport	= ISNULL((SELECT ParBit FROM Companies_Parameters WHERE CompanyId = @Company AND ParameterCode = 'JUST_RUN_REPORT'), 0)

	SELECT	@Counter = COUNT(*)
	FROM	PRIFBSQL01P.FB.dbo.Files
	WHERE	ProjectId = @ProjectId
			AND	Field8 = @Vendor
			AND	(Field4 = @InvoiceNo
			OR LEFT(Field4, 20) = @InvoiceNo)

	IF @JustReport = 0
	BEGIN
		IF @Counter = 0
		BEGIN
			SET @Query = N'UPDATE ' + @Company + '.dbo.PM20000 SET HOLD = 1 WHERE VENDORID = ''' + @Vendor + ''' AND DOCNUMBR = ''' + @InvoiceNo + ''''
			EXECUTE(@Query)

			IF @@ROWCOUNT > 0
				SET @InHold = 1
		END
	END
	ELSE
	BEGIN
		IF @Counter = 0
			SET @InHold = 1
		ELSE
			SET @InHold = 0
	END
END
ELSE
	SET @InHold = 0

SELECT @InHold AS InHold

SET @ReturnVal = CAST(@InHold AS Int)

RETURN @ReturnVal