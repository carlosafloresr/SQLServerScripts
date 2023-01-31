DECLARE	@Company	Varchar(5), 
		@VendorId	Varchar(12), 
		@PayDate	Datetime

SET		@Company	= 'NDS'
SET		@VendorId	= 'N16041'
SET		@PayDate	= '02/23/2012'

--SELECT	ISNULL(SUM(Amount + ApplyTo), 0)
--		FROM	(
				SELECT	PM1.VendorId
						,PM1.DocNumbr
						,PM1.VchrNmbr
						,PM1.DocAmnt AS Amount
						,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM NDS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @PayDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0) * -1
						,PM1.DocType
				FROM	NDS.dbo.PM20000 PM1
				WHERE	PM1.PstgDate <= @PayDate
						AND PM1.VendorId = @VendorId
						AND PM1.Voided = 0
						AND PM1.DocType NOT IN (5,6)
				--UNION
				--SELECT	PM1.VendorId
				--		,PM1.DocNumbr
				--		,PM1.VchrNmbr
				--		,PM1.DocAmnt * -1 AS Amount
				--		,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM NDS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @PayDate AND PM1.DocNumbr = PM2.ApFrDcNm AND PM1.VendorId = PM2.VendorId), 0)
				--		,PM1.DocType
				--FROM	NDS.dbo.PM20000 PM1
				--WHERE	PM1.PstgDate <= @PayDate
				--		AND PM1.VendorId = @VendorId
				--		AND PM1.Voided = 0
				--		AND PM1.DocType IN (5,6)
		--		) TRN
		--WHERE	DocType NOT IN (5,6)