USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_DriverPayrollInformation]    Script Date: 5/21/2018 10:30:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_DriverPayrollInformation 'GIS', 'G0124'
EXECUTE USP_DriverPayrollInformation 'AIS', 'A50088'
EXECUTE USP_DriverPayrollInformation 'IMC', '10209'
EXECUTE USP_DriverPayrollInformation 'IMCG', '10209'
EXECUTE USP_DriverPayrollInformation 'NDS', 'N22209'
*/
ALTER PROCEDURE [dbo].[USP_DriverPayrollInformation]
		@Company	Varchar(5),
		@VendorId	Varchar(12)
AS
DECLARE	@PayDate	Date,
		@WeekEnd	Date,
		@WeekEnd2	Date,
		@OnlyMain	Bit = 0,
		@CompanyId	Varchar(5)

DECLARE	@tblData	Table
		(PayDate	Date Null,
		Description	Varchar(50) Null,
		Amount		Numeric(10,2) Null,
		Document	Varchar(150) Null,
		Sort		Smallint Null)

SET		@CompanyId	= (SELECT TOP 1 CompanyId FROM View_CompanyAgents WHERE CompanyId = @Company OR CompanyAlias = @Company)
SET		@PayDate	= (SELECT MAX(DocDate) FROM GPCustom.dbo.PM10300 WHERE Company = @CompanyId AND VendorId = @VendorId) --CONVERT(Char(10), CASE WHEN DATENAME(weekday, GETDATE()) = 'Thursday' THEN GETDATE() ELSE dbo.DayFwdBack(GETDATE(), 'P', 'Thursday') END, 101)
SET		@WeekEnd	= dbo.DayFwdBack(@PayDate, 'P', 'Saturday')

INSERT INTO @tblData
	SELECT	DISTINCT @PayDate AS PayDate
			,'A/P Balance If Negative' AS 'Description'
			,ISNULL(dbo.DriverBalance(@Company, @VendorId, @PayDate), 0) AS Amount
			,Null AS Document
			,0 AS Sort
	FROM	VendorMaster
	WHERE	Company = @CompanyId
			AND VendorId = @VendorId
	UNION
	SELECT	@PayDate AS PayDate
			,AccountAlias AS 'Description'
			,ISNULL(Balance, 0) AS Amount
			,Null AS Document
			,1 AS Sort
	FROM	View_EscrowAdvanceBalances
	WHERE	CompanyId = @CompanyId
			AND VendorId = @VendorId
			AND MobileAppVisible = 1
			AND (((@OnlyMain = 1 AND Fk_EscrowModuleId <> 3) OR @OnlyMain = 0)
			OR RemittanceAdvise = 1)
	UNION
	SELECT	@PayDate AS PayDate,
			'Drayage (Previous Week)' AS 'Description'
			,ISNULL(Drayage + DriverFuelRebate, 0) AS Balance
			,Null AS Document
			,2 AS Sort
	FROM	Integration_APDetails DE
			INNER JOIN Integration_APHeader HE ON DE.BatchId = HE.BatchId
	WHERE	HE.Company = @CompanyId
			AND HE.WeekEndDate = @WeekEnd
			AND DE.VendorId = @VendorId

INSERT INTO @tblData
	SELECT	TOP 4 *
			,4 AS Sort
	FROM	(
			SELECT	DISTINCT CAST(DD.WeekEndingDate AS Date) AS WeekEndingDate
					,'Remittance Advise ' + CONVERT(Varchar, DD.WeekEndingDate, 101) AS 'Description'
					,ISNULL(PM.ChekTotl, 0.0) AS Amount
					,DD.DocumentName AS Document
			FROM	View_DriverDocuments DD
					LEFT JOIN PM10300 PM ON DD.VendorId = PM.VendorId AND PM.DocDate BETWEEN dbo.DayFwdBack(DD.WeekEndingDate, 'P', 'Monday') AND DD.WeekEndingDate
			WHERE	DD.Fk_DocumentTypeId = 1 
					AND DD.Company = @CompanyId
					AND DD.VendorId = @VendorId
					AND DD.WeekEndingDate > DATEADD(dd, -40, GETDATE())
			) RECS
	WHERE	Amount IS NOT Null
	ORDER BY 5, 1 DESC

SELECT	*
FROM	@tblData
ORDER BY 5, 1 DESC