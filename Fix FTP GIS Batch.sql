UPDATE	FPT_ReceivedDetails 
SET		VendorId = 'G' + VendorId
WHERE	BatchId = '2_FPT_20090829' 
		AND VendorId IN ('9491','9631','9662','9769','9829','9870')