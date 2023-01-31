UPDATE	CM00100
SET		CURRBLNC = ROUND(CURRBLNC, 2, 1)
WHERE	CURRBLNC <> ROUND(CURRBLNC, 2, 1)

UPDATE	CM20500
SET		ClrePayAmt			= ROUND(ClrePayAmt, 2, 1),
		ClrdDepAmt			= ROUND(ClrdDepAmt, 2, 1),
		CUTOFFBAL			= ROUND(CUTOFFBAL, 2, 1),
		StmntBal			= ROUND(StmntBal, 2, 1),
		Cleared_Difference	= ROUND(Cleared_Difference, 2, 1),
		OUTPAYTOT			= ROUND(OUTPAYTOT, 2, 1),
		OUTDEPTOT			= ROUND(OUTDEPTOT, 2, 1)
WHERE	ClrePayAmt <> ROUND(ClrePayAmt, 2, 1)
		OR CUTOFFBAL <> ROUND(CUTOFFBAL, 2, 1)
		OR ClrdDepAmt <> ROUND(ClrdDepAmt, 2, 1)
		OR StmntBal <> ROUND(StmntBal, 2, 1)
		OR Cleared_Difference <> ROUND(Cleared_Difference, 2, 1)
		OR OUTPAYTOT <> ROUND(OUTPAYTOT, 2, 1)
		OR OUTDEPTOT <> ROUND(OUTDEPTOT, 2, 1)

UPDATE	CM20200
SET		TRXAMNT				= ROUND(TRXAMNT, 2, 1),
		ClrdAmt				= ROUND(ClrdAmt, 2, 1),
		ORIGAMT				= ROUND(ORIGAMT, 2, 1),
		Checkbook_Amount	= ROUND(Checkbook_Amount, 2, 1)
WHERE	(TRXAMNT <> ROUND(TRXAMNT, 2, 1)
		OR ClrdAmt <> ROUND(ClrdAmt, 2, 1)
		OR ORIGAMT <> ROUND(ORIGAMT, 2, 1)
		OR Checkbook_Amount <> ROUND(Checkbook_Amount, 2, 1))

select * from CM20200 where right(ClrdAmt,3)<>0
or right(TRXAMNT,3)<>0
or right(ORIGAMT,3)<>0
or right(Checkbook_Amount,3)<>0

select * from CM20500 where right(StmntBal,3)<>0
or right(CUTOFFBAL,3)<>0
or right(ClrePayAmt,3)<>0
or right(ClrdDepAmt,3)<>0
or right(ClrdDepAmt,3)<>0
or right(Cleared_Difference,3)<>0
or right(OUTPAYTOT,3)<>0
or right(OUTDEPTOT,3)<>0
or right(IINADJTOT,3)<>0
or right(DECADJTOT,3)<>0
or right(ASOFBAL,3)<>0
