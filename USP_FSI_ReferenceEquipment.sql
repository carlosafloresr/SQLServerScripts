/*
EXECUTE USP_FSI_ReferenceEquipment 'AIS', '45-114232'
*/
CREATE PROCEDURE USP_FSI_ReferenceEquipment
		@Company	Varchar(5),
		@InvoiceNo	Varchar(20)
AS
SELECT	TOP 1 BillToRef,
		Equipment
FROM	View_Integration_FSI_Full
WHERE	Company = @Company
		AND InvoiceNumber = @InvoiceNo
