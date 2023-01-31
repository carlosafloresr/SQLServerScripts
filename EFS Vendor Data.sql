DECLARE	@Company	Varchar(5) = 'AIS', --'NDS',
		@Vendor		Varchar(20) = '926',
		@InvoiceNo	Varchar(20) = '217101' --'5-103089_35'

SET NOCOUNT ON
DECLARE	@ProjectId	Int,
		@Query		Varchar(MAX)

DECLARE	@tblData TABLE
		(Container		Varchar(20) Null,
		Chassis			Varchar(20) Null,
		Approver		Varchar(25) Null,
		PONumber		Varchar(30) Null,
		DocImage		Varchar(500) Null)

SET	@ProjectId = (SELECT ProjectId FROM DexCompanyProjects WHERE ProjectType = 'AP' AND Company = @Company)

INSERT INTO @tblData
SELECT	Field14,
		Field3,
		Field6,
		Field16,
		FullFileName
FROM	LENSASQL003.FB.dbo.View_DEXDocuments DEXVIEW
WHERE	DEXVIEW.ProjectId = @ProjectId
		AND DEXVIEW.Status = 1
		AND	DEXVIEW.Field8 = @Vendor
		AND	(DEXVIEW.Field4 = @InvoiceNo
		OR LEFT(DEXVIEW.Field4, 20) = @InvoiceNo)

IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO @tblData (Container)
	SELECT	TOP 1 Equipment
	FROM	ILSINT02.Integrations.dbo.View_Integration_FSI_Vendors
	WHERE	Company = @Company
			AND RecordCode = @Vendor
			AND VendorDocument = @InvoiceNo

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO @tblData  (Container)
		SELECT	DISTINCT Container
		FROM	ILSINT02.Integrations.dbo.Integrations_AP
		WHERE	Company = @Company
				AND DOCNUMBR = @InvoiceNo
	END
END

SELECT	*
FROM	@tblData