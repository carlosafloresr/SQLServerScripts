DECLARE	@CutoffDate	Datetime,
		@VendorId	Char(10)

SET		@CutoffDate = GETDATE() + 1
SET		@VendorId	= 'A0095'

SELECT	VENDORID,
		SUM(CASE WHEN DOCTYPE = 5 THEN -1 ELSE 1 END * CurTrxAm) AS Balance
FROM	PM20000 
WHERE	POSTEDDT <= @CutoffDate AND
		VendorId = @VendorId
GROUP BY Vendorid