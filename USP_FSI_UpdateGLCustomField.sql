USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_UpdateGLCustomField]    Script Date: 1/26/2023 5:16:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_UpdateGLCustomField 'GLSO', '9FSI20230126_1006'
*/
ALTER PROCEDURE [dbo].[USP_FSI_UpdateGLCustomField]
		@Company	Varchar(6),
		@BatchId	Varchar(25)
AS
SET NOCOUNT ON

DECLARE @Query		Varchar(MAX)

SELECT	CustNmbr 
INTO	##tmpTblCustomers
FROM	CustomerMaster 
WHERE	CompanyId = @Company 
		AND WithDemurrage = 1

SELECT	BatchId, InvoiceNumber, Amount, RefDocument, VndCustId, VndCustName
INTO	#tmpFSIDetails
FROM	IntegrationsDB.Integrations.dbo.FSI_TransactionDetails
WHERE	BatchId = @BatchId
		AND IntegrationType IN ('FSIG','TIP')
		AND RefDocument IS NOT Null

SET @Query = N'UPDATE ' + @Company + '.dbo.GL10000
SET		User_Defined_Text01 = LEFT(RTRIM(DATA.FSIVendor), 30)
FROM	(
		SELECT	GL20.JRNENTRY AS JOURNAL,
				''VND:'' + FSI.VndCustId + '' - '' + FSI.VndCustName AS FSIVendor,
				FSI.BatchId
		FROM	' + @Company + '.dbo.GL10000 GL20
				INNER JOIN ' + @Company + '.dbo.GL10001 GL01 ON GL20.JRNENTRY = GL01.JRNENTRY
				LEFT JOIN #tmpFSIDetails FSI ON GL20.BACHNUMB = LEFT(FSI.BatchId, 15) AND GL01.DEBITAMT + GL01.CRDTAMNT = FSI.Amount AND GL20.REFRENCE = FSI.RefDocument
		WHERE	GL20.BACHNUMB = ''' + LEFT(@BatchId, 15) + '''
				AND GL20.LASTUSER = ''FSIG_Integratio''
		) DATA
WHERE	JRNENTRY = JOURNAL
		AND User_Defined_Text01 = ''''
		AND FSIVendor IS NOT Null'

EXECUTE(@Query)

SET @Query = N'UPDATE  ' + @Company + '.dbo.GL10001
SET		DSCRIPTN = InvoiceNumber
FROM	(
		SELECT	FSI.InvoiceNumber,
				GL01.DEX_ROW_ID AS RowId
		FROM	' + @Company + '.dbo.GL10000 GL20
				LEFT JOIN ' + @Company + '.dbo.GL10001 GL01 ON GL20.JRNENTRY = GL01.JRNENTRY
				LEFT JOIN #tmpFSIDetails FSI ON GL20.BACHNUMB = LEFT(FSI.BatchId, 15) AND GL01.DEBITAMT + GL01.CRDTAMNT = FSI.Amount AND GL20.REFRENCE = FSI.RefDocument AND FSI.VndCustId IN (SELECT CUSTNMBR FROM ##tmpTblCustomers)
		WHERE	GL20.BACHNUMB = ''' + LEFT(@BatchId, 15) + '''
				AND GL20.LASTUSER = ''FSIG_Integratio''
		) DATA
WHERE	DEX_ROW_ID = DATA.RowId
		AND DATA.InvoiceNumber IS NOT Null'

EXECUTE(@Query)

DROP TABLE ##tmpTblCustomers
DROP TABLE #tmpFSIDetails