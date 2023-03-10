USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_DriverMaster_EmailAddressUpdate]    Script Date: 5/11/2017 2:58:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_DriverMaster_EmailAddressUpdate
EXECUTE USP_DriverMaster_EmailAddressUpdate 'OIS'
EXECUTE USP_DriverMaster_EmailAddressUpdate 'IMC', '13181'
*/
ALTER PROCEDURE [dbo].[USP_DriverMaster_EmailAddressUpdate]
		@Company		Varchar(5) = Null,
		@DriverId		Varchar(15) = Null
AS
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@CompanyNumber	Int

DECLARE	@tblDrivers Table (
		Company			Varchar(5),
		CompanyNumber	Int,
		VendorId		Varchar(15),
		EmailAddress	Varchar(100) Null)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT CompanyId, CompanyNumber
FROM	Companies
WHERE	Trucking = 1
		AND WithDrivers = 1
		AND (@Company IS Null OR (@Company IS NOT Null AND CompanyId = @Company))

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company, @CompanyNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	-- Pull Great Plains drivers
	SET @Query = N'SELECT	*
	FROM	(
			SELECT	VM.Company,
					''' + CAST(@CompanyNumber AS Varchar) + ''' AS CompanyNumber,
					VM.VendorId,
					ISNULL(VM.EmailAddress, GP.EmailToAddress) AS EmailAddress
			FROM	VendorMaster VM
					LEFT JOIN ' + RTRIM(@Company) + '.dbo.SY01200 GP ON VM.VendorId = GP.Master_Id AND GP.Master_Type = ''VEN''
			WHERE	VM.Company = ''' + RTRIM(@Company) + ''''

	IF @DriverId IS NOT Null
		SET @Query = @Query + ' AND VM.VendorId = ''' + RTRIM(@DriverId) + ''''

	SET @Query = @Query + ') DATA'
	
	INSERT INTO @tblDrivers
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company, @CompanyNumber
END

CLOSE curCompanies
DEALLOCATE curCompanies

IF @Company IS NOT Null
BEGIN
	-- Pull SWS drivers with a valid email address
	SELECT @CompanyNumber = CompanyNumber FROM Companies WHERE CompanyId = @Company
	
	IF @DriverId IS Null
		SET @Query = 'SELECT CASE WHEN CO.AgentOf_Cmpy_No > 0 THEN CO.AgentOf_Cmpy_No ELSE DR.Cmpy_No END AS cmpy_no, DR.code, DR.email FROM trk.driver DR INNER JOIN COM.Company CO ON DR.Cmpy_No = CO.No WHERE DR.type = ''O'' AND DR.email <> '''' AND DR.email NOT LIKE ''%@NONE%'' AND CASE WHEN CO.AgentOf_Cmpy_No > 0 THEN CO.AgentOf_Cmpy_No ELSE DR.Cmpy_No END = ''' + CAST(@CompanyNumber AS Varchar) + ''' ORDER BY 1, 2'
	ELSE
		SET @Query = 'SELECT CASE WHEN CO.AgentOf_Cmpy_No > 0 THEN CO.AgentOf_Cmpy_No ELSE DR.Cmpy_No END AS cmpy_no, DR.code, DR.email FROM trk.driver DR INNER JOIN COM.Company CO ON DR.Cmpy_No = CO.No WHERE DR.type = ''O'' AND DR.email <> '''' AND DR.email NOT LIKE ''%@NONE%'' AND CASE WHEN CO.AgentOf_Cmpy_No > 0 THEN CO.AgentOf_Cmpy_No ELSE DR.Cmpy_No END = ''' + CAST(@CompanyNumber AS Varchar) + ''' AND DR.Code = ''' + RTRIM(@DriverId) + ''' ORDER BY 1, 2'
	
	EXECUTE USP_QuerySWS @Query, '##tmpDrivers'

	UPDATE	@tblDrivers
	SET		EmailAddress = LOWER(SWS.email)
	FROM	##tmpDrivers SWS
	WHERE	CompanyNumber = SWS.cmpy_no
			AND VendorId = SWS.code
			AND SWS.email <> ''
			AND GPCustom.dbo.IsEmailAddressValid(SWS.email) = 1
			AND SWS.Email NOT IN ('na@na.com','na@an.com','none@yahoo.com')
			AND EmailAddress IS Null

	DROP TABLE ##tmpDrivers
END
PRINT 'Updating VendorMaster'

--SELECT * FROM @tblDrivers ORDER BY VendorId

UPDATE	VendorMaster
SET		VendorMaster.EmailAddress = DRV.EmailAddress
FROM	@tblDrivers DRV
WHERE	VendorMaster.Company = DRV.Company
		AND VendorMaster.VendorId = DRV.VendorId
		AND DRV.EmailAddress IS NOT Null
		AND (VendorMaster.EmailAddress IS Null
		OR VendorMaster.EmailAddress <> DRV.EmailAddress)

PRINT	'Drivers updated: ' + CAST(@@ROWCOUNT AS Varchar)
