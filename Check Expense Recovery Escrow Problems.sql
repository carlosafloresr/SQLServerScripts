SELECT	*
FROM	View_EscrowTransactions
WHERE	VoucherNumber IN ('DM-A4088','10427')

SELECT	*
FROM	Purchasing_Vouchers
WHERE	VoucherNumber IN ('DM-A4088','10427')

SELECT	*
FROM	View_EscrowTransactions
WHERE	CompanyId = 'AIS'
		AND PostingDate BETWEEN '1/1/2005' AND '03/18/2011'
		AND AccountNumber = '0-00-1102'
		AND ProNumber = '12-01550'

SELECT	*
FROM	GPCustom_20110310.dbo.View_EscrowTransactions
WHERE	CompanyId = 'AIS'
		AND PostingDate BETWEEN '1/1/2005' AND '03/18/2011'
		AND AccountNumber = '0-00-1102'
		AND ProNumber = '12-01550'
		
				
SELECT	*
FROM	Purchasing_Vouchers
WHERE	ProNumber IN (
						SELECT	ProNumber
						FROM	View_EscrowTransactions
						WHERE	CompanyId = 'AIS'
								AND PostingDate BETWEEN '1/1/2005' AND '03/18/2011'
								AND AccountNumber = '0-00-1102'
								AND ProNumber = '12-01550')

SELECT	*
FROM	GPCustom_20110310.dbo.Purchasing_Vouchers
WHERE	ProNumber IN (
						SELECT	ProNumber
						FROM	GPCustom_20110310.dbo.View_EscrowTransactions
						WHERE	CompanyId = 'AIS'
								AND PostingDate BETWEEN '1/1/2005' AND '03/18/2011'
								AND AccountNumber = '0-00-1102'
								AND ProNumber = '12-01550')
								
SELECT	*
FROM	View_EscrowTransactions
WHERE	CompanyId = 'AIS'
		AND PostingDate BETWEEN '1/1/2005' AND '03/18/2011'
		AND AccountNumber = '0-00-1102'
		AND Amount = 299.78

--------------------------------------------------------------------------------------
		


SELECT	*
FROM	GPCustom_20110310.dbo.View_EscrowTransactions
WHERE	CompanyId = 'AIS'
		AND PostingDate BETWEEN '1/1/2005' AND '03/18/2011'
		AND AccountNumber = '0-00-1102'
		AND Amount = 299.78