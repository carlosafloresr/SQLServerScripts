USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CheckRemittanceAdviceDocuments2]    Script Date: 12/8/2016 12:06:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE GPCustom.dbo.USP_CheckRemittanceAdviceDocuments2 'PD150710151329P','DNJ', 61
EXECUTE GPCustom.dbo.USP_CheckRemittanceAdviceDocuments '150518KHCK1','IMC', 65
EXECUTE GPCustom.dbo.USP_CheckRemittanceAdviceDocuments null,'DNJ', 61,null,NULL,NULL,'','14229'
EXECUTE GPCustom.dbo.USP_CheckRemittanceAdviceDocuments '150429MCCK','DNJ', 61,null,NULL,NULL,'','14229'
EXECUTE GPCustom.dbo.USP_CheckRemittanceAdviceDocuments '150429MCCK','DNJ', 61,null,NULL,NULL,'',''

*/
ALTER PROCEDURE [dbo].[USP_CheckRemittanceAdviceDocuments2]
	@vBACHNUMB			VARCHAR(20),
	@vCompany			VARCHAR(5),
	@nProjectID			INT = NULL,
	@vVENDorID			VARCHAR(15) = NULL,
	@nSpecificAmount	NUMERIC(19,5) = NULL,
	@vGLCategory		VARCHAR(31) = NULL,
	@vInvoiceNumber		VARCHAR(25) = NULL,
	@vCheckNumber		VARCHAR(25) = NULL	
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON
	--	===============  VALIDATE RE-ASSIGN PARAMETERS  BEGIN ====================
	
	DECLARE @vInvoiceNumberTrim VARCHAR(21)
	SET @vInvoiceNumberTrim = NULL

	IF NOT @vVENDorID IS NULL
		SET @vVENDorID = LTRIM(RTRIM(@vVENDorID)) 

	IF @vVENDorID = ''
		SET @vVENDorID = NULL

	IF NOT @vBACHNUMB IS NULL
		SET @vBACHNUMB = LTRIM(RTRIM(@vBACHNUMB)) 

	IF @vBACHNUMB = ''
		SET @vBACHNUMB = NULL
		
	IF NOT @vGLCategory IS NULL
		SET @vGLCategory = LTRIM(RTRIM(@vGLCategory)) 

	IF @vGLCategory = ''
		SET @vGLCategory = NULL
			
	IF NOT @nSpecificAmount IS NULL
	BEGIN
		IF @nSpecificAmount = 0
			SET @nSpecificAmount = NULL
	END
		
	IF NOT @vInvoiceNumber IS NULL
		SET @vInvoiceNumber = RTRIM(LTRIM(@vInvoiceNumber))
		
	IF @vInvoiceNumber = ''
		SET @vInvoiceNumber = NULL
			
	IF NOT @vCheckNumber IS NULL
		SET @vCheckNumber = LTRIM(RTRIM(@vCheckNumber)) 

	IF @vCheckNumber = ''
		SET @vCheckNumber = NULL
			
	DECLARE @vReportName		VARCHAR(70) = 'Remittance Advice Detail'
	DECLARE @vILSCompanyName	VARCHAR(50) = 'ATLANTIC INTERMODAL SERVICES, LLC' 
	DECLARE @vReportDate		VARCHAR(25) = CONVERT(VARCHAR(12),getdate(),101) + ' ' + CONVERT(VARCHAR(10),getdate(),108)
    DECLARE @nErrNum			INT			--ERROR_NUMBER(), 
    DECLARE @sErrProcedure		VARCHAR(35) = 'USP_rpt_CheckRemittanceAdvice'--ERROR_PROCEDURE(),
    DECLARE @sErrMsg			VARCHAR(250)--ERROR_MESSAGE(),     
	DECLARE @vSQL				NVARCHAR(4000)
	DECLARE @nRowCount			INT
	
	/*	========== Table variable to hold the data for the report =================  */
	DECLARE @TableData TABLE
		(	ILSComp_Report_name VARCHAR(70),
			ReportDate			VARCHAR(25),
			BACHNUMB			VARCHAR(20) default NULL,
			Company			    VARCHAR(65) default NULL,
			Period				VARCHAR(10) default NULL,
			CheckNumber			VARCHAR(30) default NULL,
			CheckDate			DATETIME default NULL,
			EffectiveDate		DATETIME default NULL,
			CheckAmount			NUMERIC(19,5) default NULL,
			UserId				VARCHAR(15) default NULL,
			VENDORID			VARCHAR(30) default NULL,
			VENDNAME			VARCHAR(65) default NULL,
			PONumber			VARCHAR(25) default NULL,	
			APTVCHNM			VARCHAR(21) default NULL,
			PaidInvoice			VARCHAR(21) default NULL,
			PaidAmount			NUMERIC(19,5) default NULL,
			Voucher				VARCHAR(25) default NULL,
			InvoiceNumber		VARCHAR(30) default NULL,
			InvoiceDate			DATETIME default NULL,
			InvoiceDueDate		DATETIME default NULL,
			InvoiceAmount		NUMERIC(19,5) default NULL,
			InvoiceEffectiveDate DATETIME default NULL,
			Container			VARCHAR(15) default NULL,
			ProNumber			VARCHAR(25) default NULL,
			ChassisNumber		VARCHAR(15) default NULL,
			GLAccount			VARCHAR(129) default NULL,
			GLAcctName			VARCHAR(75) default NULL,
			GLCategory			VARCHAR(35) default NULL,
			DebitAmount			NUMERIC(19,5) default NULL,
			Reference			VARCHAR(50) default NULL,
			SystemSource		VARCHAR(100) default NULL,
			ApprovedBy          VARCHAR(100) default NULL,
			ProjectID			INTEGER default NULL,
			Document			VARCHAR(600) default NULL,
			CheckDataDifferent	BIT default NULL,
			DEXFileId			INT default NULL,
			DOCBATCH			VARCHAR(25) NULL
		)
		
	DECLARE @DexViewTable TABLE
	(
		ProjectID			INTEGER default NULL,
		VENDORID			VARCHAR(30) default NULL,  
		InvoiceNumber		VARCHAR(30) default NULL,
		ApprovedBy          VARCHAR(100) default NULL,
		CheckDate			VARCHAR(30) default NULL,
		PONumber			VARCHAR(25) default NULL,
		CheckNumber			VARCHAR(30) default NULL,
		Document			VARCHAR(600) default NULL,
		FileId				INT default NULL
	)
	
	DECLARE @vProjectType VARCHAR(15) = CASE WHEN @nProjectID = 113 THEN 'MSCPD' ELSE 'AP' END
		
	BEGIN TRY;
		SET @vSQL = 'SELECT ' + 
		'''' + @vReportName + ''',' + 
		'''' + @vReportDate + ''',' + 
		'CHK.BACHNUMB, ' + 
		'CPY.CmpnyNam AS Company, ' + 
		'CAST(PER.Year1 AS Char(4)) + ''-'' + CAST(PER.PERIODID AS Char(2)) AS Period, ' +
		'RTRIM(CHK.DOCNUMBR) AS CheckNumber, ' +
		'CHK.DOCDATE AS CheckDate, ' +
		'CHK.POSTEDDT AS EffectiveDate, 
		CHK.DOCAMNT AS CheckAmount,
		CHK.PTDUSRID AS UserId, ' +
		'RTRIM(APL.VENDORID) AS VENDORID, ' +
		'VND.VENDNAME, ' +
		'PMH.PORDNMBR AS PONumber, ' +
		'APL.APTVCHNM, ' +
		'APL.APTODCNM AS PaidInvoice, ' +
		'APL.APFRMAPLYAMT AS PaidAmount,
		PMH.VCHRNMBR AS Voucher, ' +
		'RTRIM(PMH.DOCNUMBR) AS InvoiceNumber, ' +
		'PMH.DOCDATE AS InvoiceDate, ' +
		'PMH.DUEDATE AS InvoiceDueDate, ' +
		'PMH.DOCAMNT AS InvoiceAmo, ' +
		'PMH.POSTEDDT AS InvoiceEffectiveDate,
		VOU.TrailerNumber AS Container, ' +
		'VOU.ProNumber, ' +
		'VOU.ChassisNumber, ' +
		'GLA.ACTNUMST AS GLAccount, ' +
		'GLB.ACTDESCR AS GLAcctName, 
		GLB.USRDEFS1 AS GLCategory, ' +
		'PMD.DEBITAMT AS DebitAmount, ' +
		'PMD.DistRef AS Reference, ' + 
		''''' AS SystemSource, ' +
		''''' AS ApprovedBy, ' +              
		'DXC.ProjectId, Null, null, null,
		PMH.BACHNUMB,
		FROM ' + @vCompany + '.dbo.PM30200 CHK
		INNER JOIN ' + @vCompany + '.dbo.PM30300 APL ON CHK.DOCNUMBR = APL.APFRDCNM
		INNER JOIN ' + @vCompany + '.dbo.PM00200 VND ON CHK.VENDORID = VND.VENDORID
		INNER JOIN ' + @vCompany + '.dbo.SY40100 PER ON CHK.POSTEDDT BETWEEN PER.PERIODDT AND PER.PERDENDT 
			  AND PER.Series = 2 
			  AND PER.ODESCTN = ''General Entry''
		INNER JOIN Dynamics..SY01500 CPY ON CPY.InterId = ' + '''' + @vCompany + '''' +
		' LEFT  JOIN ' + @vCompany + '.dbo.PM30200 PMH ON APL.APTODCNM = PMH.DOCNUMBR
		INNER JOIN ' + @vCompany + '.dbo.PM30600 PMD ON PMH.VCHRNMBR = PMD.VCHRNMBR 
			  AND PMH.TRXSORCE = PMD.TRXSORCE
			  AND PMD.VENDORID = VND.VENDORID 
			  AND PMD.DEBITAMT > 0
		INNER JOIN ' + @vCompany + '.dbo.GL00105 GLA ON PMD.DSTINDX = GLA.ACTINDX
		INNER JOIN ' + @vCompany + '.dbo.GL00100 GLB ON GLA.ACTINDX = GLB.ACTINDX
		LEFT JOIN GPCustom.dbo.DexCompanyProjects DXC ON DXC.Company = '  + '''' + @vCompany + '''' + ' AND DXC.ProjectType = ' + '''' + @vProjectType + '''
		LEFT JOIN GPCustom.dbo.Purchasing_Vouchers VOU ON PMH.VCHRNMBR = VOU.VoucherNumber AND VOU.Source = ''AP''
		WHERE CHK.DOCTYPE = 6 ' +
		CASE ISNULL(@vBACHNUMB,'')
			WHEN '' THEN ''
			ELSE ' AND   CHK.BACHNUMB =  ' + '''' + @vBACHNUMB + ''''
		END +
		CASE ISNULL(@vVENDorID,'')
			WHEN '' THEN ''
			ELSE ' AND  APL.VENDORID = ' + '''' + @vVENDorID + ''''
		END +
		CASE ISNULL(@vGLCategory,'')
			WHEN '' THEN ''
			ELSE ' AND GLB.USRDEFS1 = ' + '''' + @vGLCategory + ''''
		END +
		CASE ISNULL(@vInvoiceNumber,'')
			WHEN '' THEN ''
			ELSE ' AND PMH.DOCNUMBR = ' + '''' + @vInvoiceNumber + ''''
		END +
		CASE ISNULL(@vCheckNumber, '')
			WHEN '' THEN ''
			ELSE ' AND CHK.DOCNUMBR = ' + '''' + @vCheckNumber + ''''
		END +
		' ORDER BY CHK.DOCNUMBR'		
		
		PRINT @vSQL

		INSERT INTO @TableData
		EXECUTE sp_executesql @vSQL 
	
		SET @nRowCount = @@ROWCOUNT
	END TRY
	
	BEGIN CATCH;
		SET @nErrNum = ISNULL(ERROR_NUMBER(), 0)
		SET @sErrMsg = 'Error while inserting data into @TableData from various tables in ' + @vCompany + ': ' + CONVERT(VARCHAR(250),ISNULL(ERROR_MESSAGE(), '')) + ' Error Source: ' + @sErrProcedure
	END CATCH
	IF @nErrNum > 0
	BEGIN	
		RAISERROR (@sErrMsg, 11, 1 );
		RETURN
	END

	SELECT @nRowCount = ISNULL(@nRowCount,0)
	
	IF @nRowCount <> 0 
	BEGIN
		IF @vProjectType = 'MSCPD'
		BEGIN
			INSERT INTO @DexViewTable					
			SELECT	DISTINCT ProjectID,
					DEXVIEW.Field8,
					DEXVIEW.Field4,
					DEXVIEW.Field6,
					DEXVIEW.Field15,
					DEXVIEW.Field16, -- DEXVIEW.Field16 placeholder
					DEXVIEW.Field19,
					DEXVIEW.FullFileName,
					DEXVIEW.FILEID
			FROM	LENSASQL003.FB.dbo.View_DEXDocuments DEXVIEW 
			WHERE	DEXVIEW.ProjectId = @nProjectID
					AND DEXVIEW.Status = 1
					AND DEXVIEW.Field8 IN (SELECT VENDORID FROM @TableData)
					AND	((LEFT(DEXVIEW.Field4, 20) IN (SELECT SUBSTRING(InvoiceNumber, 1, CHARINDEX('_', InvoiceNumber) - 1) FROM @TableData) AND DEXVIEW.Field13 LIKE '%Invoice%')
					OR DEXVIEW.Field9 IN (SELECT InvoiceNumber FROM @TableData))
		END
		ELSE
		BEGIN
			INSERT INTO @DexViewTable		
			SELECT	ProjectID,
					RTRIM(DEXVIEW.Field8),
					RTRIM(DEXVIEW.Field4),
					RTRIM(DEXVIEW.Field6),
					RTRIM(DEXVIEW.Field15),
					LEFT(RTRIM(DEXVIEW.Field16), 25), -- DEXVIEW.Field16 placeholder
					RTRIM(DEXVIEW.Field19),
					RTRIM(DEXVIEW.FullFileName),
					DEXVIEW.FILEID
			FROM	LENSASQL003.FB.dbo.View_DEXDocuments DEXVIEW
			WHERE	DEXVIEW.ProjectId = @nProjectID
					AND DEXVIEW.Status = 1
					AND	DEXVIEW.Field8 IN (SELECT VendorId FROM @TableData)
					AND	(LEFT(DEXVIEW.Field4, 20) IN (SELECT InvoiceNumber FROM @TableData)
					OR DEXVIEW.Field4 IN (SELECT InvoiceNumber FROM @TableData))
		END
		
		UPDATE	@TableData
		SET		ApprovedBy			= DVT.ApprovedBy,
				PONumber			= DVT.PONumber,
				Document			= DVT.Document,
				DEXFileId			= DVT.FileId,
				CheckDataDifferent	= CASE WHEN RTRIM([@TableData].CheckNumber) <> RTRIM(DVT.CheckNumber) THEN 1 ELSE 0 END
		FROM	@DexViewTable DVT
		WHERE	RTRIM([@TableData].VENDORID) = RTRIM(DVT.VENDORID) 
				AND LEFT([@TableData].InvoiceNumber, 20) = LEFT(DVT.InvoiceNumber, 20)
	END
		
	IF @nRowCount = 0 
	BEGIN
	/*	
		Main query did not return any data
		Let's insert the report header fields
	*/
		BEGIN TRY;
			INSERT INTO @TableData 
					(ILSComp_Report_name, ReportDate)
			VALUES 
					(@vReportName, @vReportDate)
		END TRY

		BEGIN CATCH;
			SET @nErrNum = ISNULL(ERROR_NUMBER(), 0)
			SET @sErrMsg = 'Error while inserting report header data into @TableData: ' + CONVERT(VARCHAR(250),ISNULL(ERROR_MESSAGE(), '')) + ' Error Source: ' + @sErrProcedure		
		END CATCH
	END
		
	IF @nErrNum > 0
	BEGIN
		RAISERROR (@sErrMsg, 11, 1 );
		RETURN
	END

	/*	Trim all the VARCHAR fields. The values may be coming from  */
	UPDATE	@TableData	
	SET		BACHNUMB		= RTRIM(ISNULL(BACHNUMB,'')),
			Company			= RTRIM(ISNULL(Company,'')),
			CheckNumber		= RTRIM(ISNULL(CheckNumber,'')),
			UserId			= RTRIM(ISNULL(UserId,'')),
			VENDORID		= RTRIM(ISNULL(VENDORID,'')),
			VENDNAME		= RTRIM(ISNULL(VENDNAME,'')),
			PONumber		= RTRIM(ISNULL(PONumber,'')),
			PaidInvoice		= RTRIM(ISNULL(PaidInvoice,'')),
			Voucher			= RTRIM(ISNULL(Voucher,'')),
			InvoiceNumber	= RTRIM(ISNULL(InvoiceNumber,'')),
			Container		= RTRIM(ISNULL(Container,'')),
			ProNumber		= RTRIM(ISNULL(ProNumber,'')),
			ChassisNumber	= RTRIM(ISNULL(ChassisNumber,'')),
			GLAccount		= RTRIM(ISNULL(GLAccount,'')),
			GLAcctName		= RTRIM(ISNULL(GLAcctName,'')),
			GLCategory		= RTRIM(ISNULL(GLCategory,'')),
			Reference		= RTRIM(ISNULL(Reference,'')),
			SystemSource	= RTRIM(ISNULL(SystemSource,''))
	
	/*	================== FILTER REPORT ON PARAMETERS  ==================*/		
	
	SET @nErrNum = 0
	
	BEGIN TRY;
		IF NOT @vVENDorID IS NULL
		BEGIN
			DELETE	@TableData	
			WHERE	VENDORID <> @vVENDorID
		END
		
		IF NOT @vGLCategory IS NULL
		BEGIN
			DELETE	@TableData	
			WHERE	GLCategory <> @vGLCategory
		END
		
		IF NOT @vInvoiceNumber IS NULL
		BEGIN
			DELETE	@TableData	
			WHERE	InvoiceNumber <> @vInvoiceNumber
		END
		
		IF NOT @vCheckNumber IS NULL 
		BEGIN
			DELETE	@TableData	
			WHERE	CheckNumber	<> @vCheckNumber
		END
		
		IF NOT @nSpecificAmount IS NULL
		BEGIN
			DELETE	@TableData	
			WHERE CheckAmount <= @nSpecificAmount		
		END
			
		SELECT	* 
		FROM	@TableData
		ORDER BY REPLICATE(' ', 25 - LEN(CheckNumber)) + CheckNumber
	END TRY
	BEGIN CATCH;
	    SET @nErrNum = ISNULL(ERROR_NUMBER(), 0)
		SET @sErrMsg = 'Error while updating and selecting from @TableData: ' + CONVERT(VARCHAR(250),ISNULL(ERROR_MESSAGE(), '')) + ' Error Source: ' + @sErrProcedure		
	END CATCH
	IF @nErrNum > 0
	BEGIN
		RAISERROR (@sErrMsg, 11, 1 );
		RETURN
	END
END