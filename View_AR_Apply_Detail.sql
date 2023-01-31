/*
SELECT * FROM View_AR_Apply_Detail WHERE Customer_ID = '25050'
*/
ALTER VIEW View_AR_Apply_Detail
AS
/*
************************************************************
Returns apply detail for all posted receivables transactions.
Only shows functional currency amounts.
Credit documents applied to more than one debit document
will return multiple lines.
Tables used:
	RM00101 – Customer Master
	RM20101 - Open Transactions
	RM20201 – Open Transactions Apply
	RM30101 – Historical Transactions
	RM30201 – Historical Transactions Apply
-- ************************************************************
*/
SELECT	RTRIM(TRN.CUSTNMBR) AS Customer_ID,
		CST.CUSTNAME AS Customer_Name,
		CAST(TRN.DOCDATE AS Date) AS Document_Date,
		CAST(TRN.GLPOSTDT AS Date) AS GL_Posting_Date,
		CASE TRN.RMDTYPAL
			WHEN 7 THEN 'Credit Memo'
			WHEN 8 THEN 'Return'
			WHEN 9 THEN 'Payment'
		END AS RM_Doc_Type,
		RTRIM(TRN.BACHNUMB) AS Payment_Batch,
		RTRIM(TRN.DOCNUMBR) AS Document_Number,
		TRN.ORTRXAMT AS Original_Trx_Amount,
		TRN.CURTRXAM AS Current_Trx_Amount,
		APL.APPTOAMT AS Amount_Applied,
		RTRIM(APL.APTODCNM) AS Applied_to_Doc_Number,
		CAST(APL.APTODCDT AS Date) AS Applied_to_Document_Date,
		CAST(APL.ApplyToGLPostDate AS Date) AS Applied_to_GL_Posting_Date,
		APL.DISTKNAM AS Discount,
		APL.WROFAMNT AS Writeoff,
		CAST(APL.DATE1 AS Date) AS Apply_Document_Date,
		CAST(APL.GLPOSTDT AS Date) AS Apply_GL_Posting_Date,
		DOC.ORTRXAMT AS Applied_To_Doc_Total,
		DOC.CURTRXAM AS Applied_To_Doc_Unapplied_Amount
FROM	(
		SELECT	CUSTNMBR, 
				DOCDATE, 
				GLPOSTDT, 
				RMDTYPAL,
				CASE RMDTYPAL
					  WHEN 7 THEN 'Credit Memo'
					  WHEN 8 THEN 'Return'
					  WHEN 9 THEN CASE CSHRCTYP
										WHEN 0 THEN 'Payment - Check ' + CASE CHEKNMBR WHEN '' THEN '' ELSE '#' + CHEKNMBR END
										WHEN 1 THEN 'Payment - Cash'
										WHEN 2 THEN 'Payment - Credit Card'
								  END
				END AS DocTypeNum,
				DOCNUMBR, 
				ORTRXAMT, 
				CURTRXAM, 
				BACHNUMB,
				ORTRXAMT - CURTRXAM AS AmountApplied 
		FROM	RM20101
		WHERE	RMDTYPAL > 6 
				AND VOIDSTTS = 0
		UNION
		SELECT	CUSTNMBR, 
				DOCDATE, 
				GLPOSTDT, 
				RMDTYPAL,
				CASE RMDTYPAL
					  WHEN 7 THEN 'Credit Memo'
					  WHEN 8 THEN 'Return'
					  WHEN 9 THEN CASE CSHRCTYP
										WHEN 0 THEN 'Payment - Check ' + CASE CHEKNMBR WHEN '' THEN '' ELSE '#' + CHEKNMBR END
										WHEN 1 THEN 'Payment - Cash'
										WHEN 2 THEN 'Payment - Credit Card'
								  END
				END AS DocTypeNum,
				DOCNUMBR, 
				ORTRXAMT, 
				CURTRXAM, 
				BACHNUMB,
				ORTRXAMT - CURTRXAM AS AmountApplied 
		FROM	RM30101
		WHERE	RMDTYPAL > 6
				AND VOIDSTTS = 0
		) TRN
		INNER JOIN RM00101 CST ON TRN.CUSTNMBR = CST.CUSTNMBR 
		INNER JOIN (SELECT	tO1.CUSTNMBR, 
							APTODCTY, 
							APTODCNM,
							APFRDCTY,
							APFRDCNM,
							CASE APTODCTY
								  WHEN 1 THEN 'Sale / Invoice'
								  WHEN 2 THEN 'Scheduled Payment'
								  WHEN 3 THEN 'Debit Memo'
								  WHEN 4 THEN 'Finance Charge'
								  WHEN 5 THEN 'Service Repair'
								  WHEN 6 THEN 'Warranty'
							END AS DebitType,
							APPTOAMT, 
							ApplyToGLPostDate, 
							APTODCDT, 
							tO2.DISTKNAM,
							tO2.WROFAMNT, 
							tO2.DATE1, 
							tO2.GLPOSTDT 
					FROM	RM20201 tO2 
							INNER JOIN RM20101 tO1 ON tO2.APTODCTY = tO1.RMDTYPAL AND tO2.APTODCNM = tO1.DOCNUMBR 
					UNION
					SELECT	tH1.CUSTNMBR, 
							APTODCTY, 
							APTODCNM,
							APFRDCTY, 
							APFRDCNM,
							CASE APTODCTY
								  WHEN 1 THEN 'Sale / Invoice'
								  WHEN 2 THEN 'Scheduled Payment'
								  WHEN 3 THEN 'Debit Memo'
								  WHEN 4 THEN 'Finance Charge'
								  WHEN 5 THEN 'Service Repair'
								  WHEN 6 THEN 'Warranty'
							END AS DebitType,
							APPTOAMT, 
							ApplyToGLPostDate, 
							APTODCDT, 
							tH2.DISTKNAM,
							tH2.WROFAMNT, 
							tH2.DATE1, 
							tH2.GLPOSTDT
					FROM	RM30201 tH2 
							INNER JOIN RM30101 tH1 ON tH2.APTODCTY = tH1.RMDTYPAL AND tH2.APTODCNM = tH1.DOCNUMBR
					) APL ON APL.APFRDCTY = TRN.RMDTYPAL AND APL.APFRDCNM = TRN.DOCNUMBR
					INNER JOIN (SELECT	RMDTYPAL, 
										DOCNUMBR, 
										ORTRXAMT, 
										DINVPDOF, 
										CURTRXAM, 
										CSPORNBR
								 FROM	RM20101
								 UNION
								 SELECT	RMDTYPAL, 
										DOCNUMBR, 
										ORTRXAMT, 
										DINVPDOF, 
										0 AS CURTRXAM, 
										CSPORNBR
								 FROM	RM30101
								 ) DOC ON APL.APTODCTY = DOC.RMDTYPAL AND APL.APTODCNM = DOC.DOCNUMBR
