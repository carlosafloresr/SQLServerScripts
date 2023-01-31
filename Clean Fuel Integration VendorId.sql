SELECT * FROM FPT_ReceivedDetails WHERE LEFT(VendorId, 1) IN (' ', '0')

UPDATE	FPT_ReceivedDetails 
SET		VendorId = LTRIM(SUBSTRING(VendorId, 2, 10))
WHERE	LEFT(VendorId, 1) = (' ')

UPDATE	FPT_ReceivedDetails 
SET		VendorId = CAST(CAST(VendorId AS Int) AS Varchar(10))
WHERE	LEFT(VendorId, 1) = ('0')