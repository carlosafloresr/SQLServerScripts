USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_DriverDocumentsFinder]    Script Date: 3/28/2022 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_DriverDocumentsFinder @Company = 'OIS', @DriverId = 'V50029', @PayrollDateIni = '04/01/2021', @PayrollDateEnd = '10/15/2021' --@DocTypes = '3,'
EXECUTE USP_DriverDocumentsFinder @Company = 'AIS', @DriverId = 'A51662', @PayrollDateIni = '03/03/2022', @PayrollDateEnd = '03/28/2022' --, @DocTypes = '3,'
*/
ALTER PROCEDURE [dbo].[USP_DriverDocumentsFinder]
		@Company		Varchar(5),
		@DriverId		Varchar(10),
		@PayrollDateIni	Date,
		@PayrollDateEnd	Date = Null,
		@DocTypes		Varchar(30) = Null
AS
DECLARE	@FilesPath		Varchar(50),
		@NewOOSDate		Date,
		@CompanyNum		Int,
		@CompanyId		Varchar(5)

SELECT	TOP 1
		@CompanyNum	= CompanyNumber,
		@CompanyId	= CompanyId
FROM	View_CompaniesAndAgents 
WHERE	CompanyId = @Company 
		OR CompanyAlias = @Company

EXECUTE USP_DriverMaster_EmailAddressUpdate @CompanyId, @DriverId

IF @DocTypes = 'ALL'
	SET @DocTypes = Null

IF @PayrollDateEnd IS Null AND @PayrollDateIni IS NOT Null
	SET @PayrollDateEnd = @PayrollDateIni

SET @NewOOSDate = ISNULL((SELECT NewOOSDate FROM VendorMaster WHERE Company = @CompanyId AND VendorId = @DriverId),GETDATE())

SELECT	@FilesPath = RTRIM(VarC)
FROM	[Parameters]
WHERE	ParameterCode = 'DRIVERSIMAGINGPATH'

SELECT	*
FROM	(
		SELECT	IIF(DRD.BatchId = '', 'LEGACY', DRD.BatchId) AS BatchId,
				DOT.DocumentType,
				DOT.Sort,
				CAST(DRD.WeekEndingDate AS Date) AS WeekEndingDate,
				@FilesPath + RTRIM(DRD.VendorId) + '\' + DRD.FileName AS DocumentName,
				165 AS ProjectId,
				0 AS FileId
		FROM	DriverDocuments DRD
				INNER JOIN DocumentTypes DOT ON DRD.Fk_DocumentTypeId = DOT.DocumentTypeId
		WHERE	DRD.Company = @CompanyId
				AND DRD.VendorId = @DriverId
				AND DRD.WeekEndingDate BETWEEN @PayrollDateIni AND @PayrollDateEnd
				AND (@DocTypes IS Null OR PATINDEX('%' + CAST(DRD.Fk_DocumentTypeId AS Varchar) + '%', @DocTypes) > 0)
				AND ((DRD.WeekEndingDate <= @NewOOSDate)
				OR (DRD.WeekEndingDate > @NewOOSDate AND DRD.Fk_DocumentTypeId = 2))
		UNION
		SELECT	'NONE',
				DOT.DocumentType,
				DOT.Sort,
				DATEADD(DD, 5, DEX.Field4),
				FullFileName AS DocumentName,
				165 AS ProjectId,
				DEX.FileId
		FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments DEX
				INNER JOIN DocumentTypes DOT ON DEX.Field5 = DOT.OOS_DocType
		WHERE	DEX.ProjectID = 165
				AND DEX.Field1 = @CompanyNum
				AND DEX.Field2 = @DriverId
				AND CAST(DEX.Field4 AS Date) BETWEEN DATEADD(DD, -7, @PayrollDateIni) AND DATEADD(DD, -7,  @PayrollDateEnd)
				AND (@DocTypes IS Null OR PATINDEX('%' + CAST(DOT.DocumentTypeId AS Varchar) + '%', @DocTypes) > 0)
		) DATA
ORDER BY WeekEndingDate DESC, Sort