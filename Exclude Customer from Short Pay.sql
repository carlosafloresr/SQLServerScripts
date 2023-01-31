USE [GPCustom]
GO

UPDATE	CustomerMaster
SET		ExcludeFromShortPay = 1
WHERE	CompanyId = 'GIS'
		AND CustNmbr = '11304'