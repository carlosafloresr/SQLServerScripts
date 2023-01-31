-- SELECT * FROM FPT_ReceivedDetails WHERE BATCHID = '4_FPT_20080413' AND LEFT(VendorId, 2) = '04'

UPDATE	FPT_ReceivedDetails
SET		VendorId = 'A' + SUBSTRING(VendorId, 3, 5)
WHERE	BATCHID = '4_FPT_20080518' AND 
		LEFT(VendorId, 2) = '04'