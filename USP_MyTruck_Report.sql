/*
CREATE PROCEDURE USP_MyTruck_Report

SELECT * FROM VendorMaster WHERE Company = 'AIS' AND SubType = 2
SELECT * FROM AIS.dbo.PM00200
SELECT * FROM PM10300 WHERE Company = 'AIS' ORDER BY VendorId, DocDate DESC

SELECT	VendorId, DocDate, ROW_NUMBER() OVER (ORDER BY VendorId) AS RowId
FROM	(SELECT	VendorId, DocDate FROM PM10300 WHERE Company = 'AIS' ORDER BY VendorId, DocDate DESC) VND
*/
DECLARE	@Company	Varchar(5),
		@HireDate	Datetime,
		@VendorId	Varchar(15),
		@VendorName	Varchar(75)

DECLARE DriverData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	VND.Company
		,VND.HireDate
		,VND.VendorId 
		,LEFT(dbo.PROPER(GPS.VendName), 75) AS VendorName
FROM	VendorMaster VND
		INNER JOIN AIS.dbo.PM00200 GPS ON VND.VendorId = GPS.VendorId
WHERE	VND.Company = 'AIS'
		AND VND.SubType = 2

OPEN DriverData 
FETCH FROM DriverData INTO @Company, @HireDate, @VendorId, @VendorName

WHILE @@FETCH_STATUS = 0 
BEGIN
	SELECT	VendorId
			,DocDate 
			,ChekTotl
			,ROW_NUMBER() OVER (PARTITION BY VendorId ORDER BY DocDate DESC) AS RowId
	FROM	PM10300 
	WHERE	Company = @Company
			AND VendorId = @VendorId
			AND ChekTotl <> 0
	ORDER BY 
			VendorId
			,DocDate DESC

	FETCH FROM DriverData INTO @Company, @HireDate, @VendorId, @VendorName
END

CLOSE Deductions
DEALLOCATE Deductions