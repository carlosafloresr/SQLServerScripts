DECLARE	@Integration	varchar(6),
        @Company		varchar(5),
        @BatchId		varchar(15),
		@PstgDate		date,
		@Refrence		varchar(30),
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@VendorId		varchar(12),
		@ProNumber		varchar(12),
		@InvoiceNumber	varchar(30)

DECLARE Deductions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	'FRM' AS Integration,
		'FI'AS Company,
		'FRM_' + CAST(YEAR(GETDATE()) AS varchar) + dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') AS BatchId,
		Post_Date AS TrxDate,
		Inv_Est + CAST(Inv_No AS Varchar) + '/' + RTRIM(GenSet_No) AS Reference,
		2 AS Series,
		'FRS_Automation' AS UserId,
		'5-29-5007' AS ActNumSt,
		0 AS CrdtAmnt,
		Cost AS DebitAmt,
		Inv_Est + CAST(Inv_No AS Varchar) + '/' + RTRIM(GenSet_No) AS Dscriptn,
		Vendor_Id,
		GenSet_No AS ProNumber,
		Inv_No AS InvoiceNumber
FROM	tmpFICost
WHERE	Cost <> 0
UNION
SELECT	'FRM' AS Integration,
		'FI'AS Company,
		'FRM_' + CAST(YEAR(GETDATE()) AS varchar) + dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') AS BatchId,
		Post_Date AS TrxDate,
		Inv_Est + CAST(Inv_No AS Varchar) + '/' + RTRIM(GenSet_No) AS Reference,
		2 AS Series,
		'FRS_Automation' AS UserId,
		'5-29-2104' AS ActNumSt,
		Cost AS CrdtAmnt,
		0 AS DebitAmt,
		Inv_Est + CAST(Inv_No AS Varchar) + '/' + RTRIM(GenSet_No) AS Dscriptn,
		Vendor_Id,
		GenSet_No AS ProNumber,
		Inv_No AS InvoiceNumber
FROM	tmpFICost
WHERE	Cost <> 0

OPEN Deductions 
FETCH FROM Deductions INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @Series, @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @VendorId, @ProNumber, @InvoiceNumber

WHILE @@FETCH_STATUS = 0
BEGIN
	EXECUTE USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @PstgDate, @Series, @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @VendorId, @ProNumber, @InvoiceNumber
	FETCH FROM Deductions INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @Series, @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @VendorId, @ProNumber, @InvoiceNumber
END

CLOSE Deductions
DEALLOCATE Deductions

--SELECT	*
--FROM	INTEGRATIONS_GL
--WHERE	BATCHID = 'FRM_1410011001'