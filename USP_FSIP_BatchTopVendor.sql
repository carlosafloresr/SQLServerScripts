USE Integrations
GO

/*
EXECUTE USP_FSIP_BatchTopVendor 'OIS', '5FSI20221011_1719'
*/
ALTER PROCEDURE USP_FSIP_BatchTopVendor
		@Company	Varchar(5),
		@BatchId	Varchar(25)
AS
SET NOCOUNT ON

/*
====================================================================================================================
VERSION		MODIFIED	USER				MODIFICATION
====================================================================================================================
1.0			03/17/2020	Carlos A. Flores	Provide the batch top vendor record to validate against GP open table
1.1			10/13/2022	Carlos A. Flores	Records with SWS Vendor Id is now translated into a GP Vendor Id
====================================================================================================================
*/

SELECT	TOP 1 VND.VendorId AS RecordCode, 
		FSI.VendorDocument 
FROM	View_Integration_FSI_Vendors FSI
		LEFT JOIN PRISQL01P.GPCustom.dbo.GPVendorMaster VND ON VND.Company = @Company AND (VND.VendorId = FSI.RecordCode OR VND.SWSVendorId = FSI.RecordCode)
WHERE	FSI.Company = @Company
		AND FSI.BatchId = @BatchId 
		AND FSI.Processed = 1 
ORDER BY FSI.DetailId