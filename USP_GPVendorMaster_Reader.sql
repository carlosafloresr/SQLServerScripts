USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GPVendorMaster_Reader]    Script Date: 9/28/2022 11:10:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GPVendorMaster_Reader 'IMC', '50327I'
*/
ALTER PROCEDURE [dbo].[USP_GPVendorMaster_Reader]
		@Company	Varchar(5),
		@VendorId	Varchar(20)
AS
DECLARE	@CompanyPar	Bit = ISNULL((SELECT ParBit FROM Companies_Parameters WHERE CompanyId = @Company AND ParameterCode = 'AlternativeInvoice'), 0)

EXECUTE USP_RapidPay_FileBound_DocCounter 186, @Company, @VendorId;

IF EXISTS(SELECT VendorId FROM GPVendorMaster WHERE Company = @Company AND VendorId = @VendorId AND RapidPay = 1 AND RP_EffectiveDate IS Null)
BEGIN
	DECLARE @EffDate Date = (SELECT TOP 1 EffectiveDate FROM RapidPay_VendorAch WHERE Company = @Company AND VendorId = @VendorId ORDER BY SavedOn)
	PRINT @EffDate
	UPDATE GPVendorMaster SET RP_EffectiveDate = @EffDate WHERE Company = @Company AND VendorId = @VendorId
END

SELECT	SWSVendor, 
		SWSVendorId, 
		SWSBillTo,
		CASE WHEN @CompanyPar = 1 THEN AlternativeInvoice ELSE Null END AS AlternativeInvoice,
		Override,
		ExcludeAutoHold,
		RapidPay,
		RP_EffectiveDate,
		RP_Active,
		RP_Documents AS FileBoundValid,
		SWSInactive
FROM	GPVendorMaster 
WHERE	Company = @Company
		AND VendorId = @VendorId