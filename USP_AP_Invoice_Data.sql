USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_AP_Invoice_Data]    Script Date: 10/5/2022 1:10:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_AP_Invoice_Data 'GIS', 'G19487', '252915'
EXECUTE USP_AP_Invoice_Data 'AIS', '50170A', '85-108157'
EXECUTE USP_AP_Invoice_Data 'AIS', '50170A', '85-109072'
EXECUTE USP_AP_Invoice_Data 'DNJ', '50236D', '68526'
*/
ALTER PROCEDURE [dbo].[USP_AP_Invoice_Data]
		@Company	Varchar(5),
		@Vendor		Varchar(20),
		@InvoiceNo	Varchar(25)
AS
-- Used by RegalPay 
SET NOCOUNT ON
DECLARE	@ProjectId	Int,
		@Query		Varchar(MAX),
		@FileName	Varchar(100),
		@Result		Int

DECLARE	@tblData TABLE
		(FileId			Int Null,
		Container		Varchar(30) Null,
		Chassis			Varchar(30) Null,
		Approver		Varchar(50) Null,
		PONumber		Varchar(50) Null,
		DocImage		Varchar(1000) Null)

SET	@ProjectId = (SELECT ProjectId FROM DexCompanyProjects WHERE ProjectType = 'AP' AND Company = @Company)

INSERT INTO @tblData
SELECT	TOP 1 FileId,
		Field14,
		Field3,
		Field6,
		Field16,
		FullFileName
FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments DEXVIEW
WHERE	DEXVIEW.ProjectId = @ProjectId
		AND DEXVIEW.Status = 1
		AND	DEXVIEW.Field8 = @Vendor
		AND DEXVIEW.Field4 = @InvoiceNo
ORDER BY DocumentID

SELECT	@FileName = DocImage
FROM	@tblData

EXECUTE XP_FileExist @FileName, @Result OUTPUT

IF @Result = 0
BEGIN
	DELETE @tblData

	INSERT INTO @tblData
	SELECT	TOP 1 FileId,
			Field14,
			Field3,
			Field6,
			Field16,
			FullFileName
	FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments DEXVIEW
	WHERE	DEXVIEW.ProjectId = @ProjectId
			AND DEXVIEW.Status = 1
			AND	DEXVIEW.Field8 = @Vendor
			AND DEXVIEW.Field4 = @InvoiceNo
	ORDER BY DocumentID DESC
END

IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO @tblData (Container)
	SELECT	Equipment
	FROM	[findata-intg-ms.imcc.com].Integrations.dbo.View_FSI_VendorData --View_Integration_FSI_Vendors
	WHERE	Company = @Company
			AND VendorNumber = @Vendor
			AND VendorDocument = @InvoiceNo

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO @tblData  (Container)
		SELECT	DISTINCT Container
		FROM	[findata-intg-ms.imcc.com].Integrations.dbo.Integrations_AP
		WHERE	Company = @Company
				AND DOCNUMBR = @InvoiceNo
	END
END

SELECT	Container,
		Chassis,
		Approver,
		PONumber,
		DocImage
FROM	@tblData
WHERE	Approver IS NOT Null