--CREATE PROCEDURE USP_RSR_Create_ExpenseRecovery_Documents (@RecordId Int)
--AS
DECLARE	@OTRNumber	Varchar(20)

SELECT	@OTRNumber = MAX(OTRNumber)
FROM	View_RSA_Invoices 
WHERE	RepairNumber = 2686

SELECT	FullFileName
		,Field1
		,Field2
		,CASE WHEN Field2 = 'INV' THEN 1 WHEN Field2 = 'OTR' THEN 2 ELSE 3 END SortBy
		,SortOrder
FROM	[LENSADEX001\INDEXDATAFILES].FB.dbo.View_DEXDocuments
WHERE	ProjectID = 109
		AND Field1 IN (SELECT OTRNumber FROM View_RSA_Invoices)
		--= @OTRNumber --'OTR0002528'
ORDER BY 4, 3, 5