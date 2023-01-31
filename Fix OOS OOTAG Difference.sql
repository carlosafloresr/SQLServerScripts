SELECT	*
FROM	EscrowTransactions
WHERE	CompanyId = 'GIS'
		AND LEFT(VoucherNumber, 5) = 'OOTAG'
		AND Amount = 39.07
		AND MONTH(PostingDate) = 2
		AND YEAR(PostingDate) = 2012

--UPDATE	EscrowTransactions
--SET		Amount = 33.21
--WHERE	CompanyId = 'GIS'
--		AND LEFT(VoucherNumber, 5) = 'OOTAG'
--		AND Amount = 39.07
--		AND MONTH(PostingDate) = 2
--		AND YEAR(PostingDate) = 2012
/*
SELECT	*
FROM	GIS.dbo.PM20000
WHERE	VENDORID = 'G9939'

SELECT	*
FROM	GIS.dbo.PM30200
WHERE	VENDORID = 'G9939'
*/