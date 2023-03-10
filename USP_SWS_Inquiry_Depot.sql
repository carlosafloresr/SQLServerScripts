/*
EXECUTE USP_SWS_Inquiry_Depot '1|APZU479721'
EXECUTE USP_SWS_Inquiry_Depot '9|APZU479721'
*/
ALTER PROCEDURE [dbo].[USP_SWS_Inquiry_Depot]
		@LinkData		Varchar(15)
AS
DECLARE	@Query			Varchar(MAX),
		@CompanyNum		Varchar(3),
		@Equipment		Varchar(15)

SET	@CompanyNum = LEFT(@LinkData, dbo.AT('|', @LinkData, 1) - 1)
SET @Equipment	= REPLACE(@LinkData, @CompanyNum + '|', '')

DECLARE	@tblDepot		Table (
		StatusCode		Varchar(3),
		StatusName		Varchar(50),
		UDate			Date,
		UTime			Varchar(15),
		Interchange		Varchar(12),
		BillTo			Varchar(15),
		Companion		Varchar(15),
		SiteCode		Varchar(10))

IF @LinkData = ''
BEGIN
	SELECT	Null AS [Status],
			Null AS UDate,
			Interchange,
			BillTo,
			Companion,
			SiteCode
	FROM	@tblDepot MOV
END
ELSE
BEGIN
	SET @Query = N'SELECT EQST.dmstatus_code,
		STTS.description,
		EQST.udate,
		EQST.utime,
		EQST.refcode,
		EQST.dmbillto_code,
		EQST.dmeqmast_code_companion,
		EQST.dmsite_code		
		FROM 	public.dmeqstatus EQST
		INNER JOIN public.dmstatus STTS ON EQST.dmstatus_code = STTS.code
		WHERE 	EQST.cmpy_no = ' + @CompanyNum + 
		' AND EQST.dmeqmast_code = ''' + @Equipment + ''''

	INSERT INTO @tblDepot
	EXECUTE USP_QuerySWS_ReportData @Query

	SELECT	RTRIM(StatusCode) + ' - ' + StatusName AS [Status],
			CAST(CAST(UDate AS Varchar) + ' ' + UTime AS DateTime) AS UDate,
			Interchange,
			BillTo,
			Companion,
			SiteCode
	FROM	@tblDepot
	ORDER BY 2, 1
END