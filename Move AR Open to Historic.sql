/*
SELECT * FROM RM20101 WHERE DocNumbr = '33-16629'
SELECT * FROM RM30101 WHERE DocNumbr = '33-16629'
*/

INSERT INTO RM30101
		(CustNmbr,
		DocNumbr,
		BachNumb,
		BchSourc,
		TrxSorce,
		RmdTypal,
		DueDate,
		DocDate,
		PostDate,
		PstUsrId,
		GLPostDt,
		LstEdtDt,
		LstUsred,
		OrTrxAmt,
		CurTrxAm,
		SlsAmnt,
		CostAmnt,
		FrtAmnt,
		DiscDate,
		TrxDscrn,
		CsPornbr,
		DinVpDof,
		VoidStts,
		VoidDate,
		PymTrmId,
		NoteIndx,
		Tax_Date,
		AplyWith,
		SaleDate)
SELECT CustNmbr,
		DocNumbr,
		BachNumb,
		BchSourc,
		TrxSorce,
		RmdTypal,
		DueDate,
		DocDate,
		PostDate,
		PstUsrId,
		GLPostDt,
		LstEdtDt,
		LstUsred,
		OrTrxAmt,
		CurTrxAm,
		SlsAmnt,
		CostAmnt,
		FrtAmnt,
		DiscDate,
		TrxDscrn,
		CsPornbr,
		DinVpDof,
		VoidStts,
		VoidDate,
		PymTrmId,
		NoteIndx,
		Tax_Date,
		AplyWith,
		SaleDate
FROM	RM20101
WHERE	DocNumbr = '33-16629'

DELETE	RM20101 
WHERE	DocNumbr = '33-16629'