/*
EXECUTE USP_FSI_UpdateGLCustomField_Open 'GLSO', '9FSI20210818_1113'
*/
ALTER PROCEDURE USP_FSI_UpdateGLCustomField_Open
		@Company	Varchar(6),
		@BatchId	Varchar(25)
AS
DECLARE @Query		Varchar(MAX)

SET @Query = N'UPDATE ' + @Company + '.dbo.GL20000
SET		User_Defined_Text01 = LEFT(RTRIM(DATA.FSIVendor), 30),
		DSCRIPTN = DATA.InvoiceNumber
FROM	(
		SELECT	FSI.InvoiceNumber, 
				GL2.DEX_ROW_ID AS RowId,
				''VND:'' + FSI.VndCustId + '' - '' + FSI.VndCustName AS FSIVendor
		FROM	' + @Company + '.dbo.GL20000 GL2
				LEFT JOIN PRISQL004P.Integrations.dbo.FSI_TransactionDetails FSI ON GL2.ORGNTSRC = LEFT(FSI.BatchId, 15) AND GL2.DEBITAMT + GL2.CRDTAMNT = FSI.Amount AND GL2.REFRENCE = FSI.RefDocument
		WHERE	ORGNTSRC = ''' + LEFT(@BatchId, 15) + '''
				AND LASTUSER = ''FSIG_Integratio''
		) DATA
WHERE	DEX_ROW_ID = RowId
		AND DSCRIPTN <> InvoiceNumber'

PRINT @Query
EXECUTE(@Query)