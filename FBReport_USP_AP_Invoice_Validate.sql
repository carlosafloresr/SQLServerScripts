/*
EXECUTE FBReport_USP_AP_Invoice_Validate 122, '555', 'INV20-1011R'
EXECUTE FBReport_USP_AP_Invoice_Validate 162, '1042', '15371994'
*/
CREATE PROCEDURE [dbo].[FBReport_USP_AP_Invoice_Validate]
		@ProjectID		Int,
		@VendorID		Varchar(15),
		@DocumentNum	Varchar(20)
AS
DECLARE @IsValid		Bit

SET @IsValid = IIF((SELECT COUNT(*) FROM [FB].[dbo].[View_DEXDocuments] WHERE ProjectID = @ProjectID AND Field8 = @VendorID AND Field4 = @DocumentNum AND KeyGroup1 IS Null) > 0, 0, 1)

SELECT	@IsValid AS IsValid