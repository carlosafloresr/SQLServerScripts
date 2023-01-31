/*
SELECT	*
FROM	OOS_Transactions 
WHERE	OOS_TransactionId IN (
SELECT	TransactionId
FROM	View_OOS_Transactions 
WHERE	Company = 'GIS' 
		AND DeductionDate = '1/29/2009'
		AND VendorId NOT IN (SELECT VendorId FROM VendorMaster WHERE Company = 'GIS'))
*/

DELETE	OOS_Transactions 
WHERE	OOS_TransactionId IN (
SELECT	TransactionId
FROM	View_OOS_Transactions 
WHERE	Company = 'GIS' 
		AND DeductionDate = '1/29/2009'
		AND VendorId NOT IN (SELECT VendorId FROM VendorMaster WHERE Company = 'GIS'))