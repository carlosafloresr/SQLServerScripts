USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_Integrations_GL_Select]    Script Date: 9/29/2022 12:26:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Integrations_GL_Select 'AIS','SBA_20220929','SBA', 1
*/
ALTER PROCEDURE [dbo].[USP_Integrations_GL_Select]
		@Company		Varchar(5),
		@BatchId		Varchar(25),
		@Integration	Varchar(10),
		@Processed		Bit = 0
AS
DECLARE	@DivisionsPart	Int = 0
DECLARE	@tblAccounts	Table (OrDivision Varchar(3), RplDivision Varchar(3))

IF @Company = 'NDS'
	SET @DivisionsPart = 4
ELSE
	SET @DivisionsPart = 3

INSERT INTO @tblAccounts
SELECT	RTRIM(Division_Original), RTRIM(Division_Replace)
FROM	PRISQL01P.GPCustom.dbo.RSA_Divisions_Mapping WITH (NOLOCK)
WHERE	MappingType = @Integration
		AND Company = @Company
		AND Inactive = 0

SELECT	GLT.IntegrationsGLId
		,GLT.Integration
		,GLT.Company
		,GLT.BatchId
		,GLT.Refrence
		,GLT.TrxDate
		,GLT.TrxType
		,GLT.SqncLine
		,GLT.Series
		,GLT.CurncyId
		,GLT.XChgRate
		,GLT.RateTpId
		,GLT.ExchDate
		,GLT.RateExpr
		,GLT.UserId
		,CASE WHEN ACT.OrDivision IS Null THEN GLT.ActNumSt ELSE STUFF(GLT.ActNumSt, @DivisionsPart, 2, ACT.RplDivision) END AS ActNumSt
		,GLT.CrdtAmnt
		,GLT.DebitAmt
		,GLT.Dscriptn
		,GLT.VendorId
		,GLT.ProNumber
		,GLT.InvoiceNumber
		,GLT.JrnEntry
		,GLT.PopUpId
		,GLT.Processed
		,JrnlRows = (SELECT COUNT(ISNULL(TM.InvoiceNumber, TM.Refrence)) FROM Integrations_GL TM WHERE TM.Company = GLT.Company AND ISNULL(TM.InvoiceNumber, TM.Refrence) = ISNULL(GLT.InvoiceNumber, GLT.Refrence) AND TM.BatchId = GLT.BatchId) 
		,CAST(IIF(GLT.Integration = 'SBA', 1, 0) AS Bit) AS WithCode
		,CAST(IIF(GLT.Integration = 'SBA', IIF(LEFT(REPLACE(UPPER(GLT.Dscriptn), 'Safety Bonus Accrual ', ''), 3) = 'DRV', 'Driver ' + VendorId, REPLACE(UPPER(GLT.Dscriptn), 'Safety Bonus Accrual ', '')), '') AS Varchar(25)) AS Code
FROM	Integrations_GL GLT WITH (NOLOCK)
		LEFT JOIN @tblAccounts ACT ON SUBSTRING(GLT.ACTNUMST, @DivisionsPart, 2) = ACT.OrDivision
WHERE	GLT.Integration = @Integration
		AND GLT.Company = @Company
		AND GLT.BatchId = @BatchId
		AND GLT.Processed = @Processed
ORDER BY ISNULL(GLT.InvoiceNumber, GLT.Refrence), GLT.SqncLine