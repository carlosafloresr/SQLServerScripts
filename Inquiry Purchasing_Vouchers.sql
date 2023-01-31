/*
SELECT	* 
FROM	Purchasing_Vouchers PV1
		INNER JOIN GPCustom_10072010.dbo.Purchasing_Vouchers PV2 ON PV1.VoucherLineId = PV2.VoucherLineId
WHERE	PV1.ProNumber <> PV2.ProNumber
		OR PV1.CompanyId <> PV2.CompanyId
		OR PV1.Source <> PV2.Source
		OR PV1.ChassisNumber <> PV2.ChassisNumber


SELECT	*
FROM	Purchasing_Vouchers
WHERE	CompanyId = 'AIS'
		AND VoucherNumber = '1045'
*/
		
SELECT	*
FROM	View_EscrowTransactions
WHERE	CompanyId = 'AIS'
		AND AccountNumber = '0-00-1102'
		AND ProNumber IS Null
		--AND VoucherNumber = '10641'