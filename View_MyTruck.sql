CREATE VIEW View_MyTruck
AS
SELECT	DAT.RowNumber
		,MYT.MyTruckId
		,MYT.CompanyId
		,MYT.VendorId
		,MYT.PayDate
		,MYT.Description
		,MYT.Balance
FROM	MyTruck MYT
		INNER JOIN (SELECT	ROW_NUMBER() OVER(PARTITION BY CompanyId, VendorId ORDER BY PayDate DESC) AS RowNumber
		,* FROM (SELECT DISTINCT CompanyId, VendorId ,PayDate FROM MyTruck) DAT) DAT ON MYT.CompanyId = DAT.CompanyId AND MYT.VendorId = DAT.VendorId AND MYT.PayDate = DAT.PayDate
WHERE	DAT.RowNumber < 25