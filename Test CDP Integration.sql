/*
EXECUTE USP_Pull_CDPInformation 'IMC', '03/16/2013'
*/
ALTER PROCEDURE USP_Pull_CDPInformation
	@Company		Varchar(5),
	@WeekEndingDate	Date
AS
DECLARE	@Query		Varchar(MAX),
		@CompanyNum	Smallint = 0,
		@WithData	Smallint = 0

SELECT	@CompanyNum	= CompanyNumber
FROM	Companies
WHERE	CompanyId	= @Company

SET @Query = 'SELECT Company_Number, Division_Code, Driver_Code, Driver_Type, Driver_Name, DPTrxType_Code, Pay_Miles, Truck_AMount, FuelCredit_Amount, Driver_Total, WeekEndingDate, Driver_HireDate, Driver_TermDate FROM GPS.DPY WHERE Company_Number = ' + CAST(@CompanyNum AS Varchar) + ' AND WeekEndingDate = ''' + CAST(@WeekEndingDate AS Varchar) + ''' AND Driver_Type = ''C'' ORDER BY Company_Number, Division_Code, Driver_Code'

EXECUTE USP_QuerySWS @Query, '##tmpSWS'

BEGIN TRANSACTION

INSERT INTO CDP_Details
SELECT	'CDP_' + RTRIM(COM.CompanyId) + RTRIM(SWS.Division_Code) + '-' + REPLACE(CAST(SWS.WeekEndingDate AS Char(10)), '-','') AS BatchId
		,SWS.Division_Code
		,SWS.Driver_Type
		,SWS.Driver_Code
		,SWS.DPTrxType_Code
		,SWS.Pay_Miles
		,SWS.Truck_AMount
		,SWS.FuelCredit_Amount
		,SWS.Driver_Total
		,SWS.Driver_HireDate
		,SWS.Driver_TermDate
		,0
		,0
FROM	##tmpSWS SWS
		INNER JOIN Companies COM ON SWS.Company_Number = COM.CompanyNumber
WHERE	'CDP_' + RTRIM(COM.CompanyId) + RTRIM(SWS.Division_Code) + '-' + REPLACE(CAST(SWS.WeekEndingDate AS Char(10)), '-','') NOT IN (SELECT BatchId FROM CDP_Header)
ORDER BY COM.CompanyId, SWS.Division_Code,SWS.Driver_Code

INSERT INTO CDP_Header
SELECT	DISTINCT COM.CompanyId
		,'CDP_' + RTRIM(COM.CompanyId) + RTRIM(SWS.Division_Code) + '-' + REPLACE(CAST(SWS.WeekEndingDate AS Char(10)), '-','') AS BatchId
		,SWS.Division_Code
		,SWS.WeekEndingDate
		,GETDATE()
		,0
		,0
FROM	##tmpSWS SWS
		INNER JOIN Companies COM ON SWS.Company_Number = COM.CompanyNumber
WHERE	'CDP_' + RTRIM(COM.CompanyId) + RTRIM(SWS.Division_Code) + '-' + REPLACE(CAST(SWS.WeekEndingDate AS Char(10)), '-','') NOT IN (SELECT BatchId FROM CDP_Header)
ORDER BY COM.CompanyId, SWS.Division_Code

SET @WithData = @@ROWCOUNT

DROP TABLE ##tmpSWS

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	RETURN @WithData
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	RETURN 0
END