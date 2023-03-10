SELECT	P.VENDORID VENDor_ID,
		V.VENDNAME VENDor_Name,
		V.VNDCHKNM VENDor_Check_Name,
		CASE P.PYENTTYP
		  WHEN 0 THEN 'Check'
		  WHEN 1 THEN 'Cash'
		  WHEN 2 THEN 'Credit Card'
		  WHEN 3 THEN 'EFT'
		  ELSE 'Other'
		  END Payment_Type,
		CASE WHEN P.PYENTTYP IN (0,1,3) THEN P.CHEKBKID
		  ELSE '' END Checkbook_ID,
		CASE P.PYENTTYP WHEN 2 THEN P.CARDNAME
		  ELSE '' END Credit_Card_ID,
		P.DOCDATE Payment_Date,
		P.PSTGDATE Payment_GL_Date,
		P.VCHRNMBR Payment_Voucher_Number,
		P.DOCNUMBR Payment_Document_Number,
		P.DOCAMNT Payment_Functional_Amount,
		P.TRXDSCRN Payment_Description,
		COALESCE(PA.APTVCHNM,'') Apply_To_Voucher_Number,
		CASE PA.APTODCTY
		  WHEN 1 THEN 'Invoice'
		  WHEN 2 THEN 'Finance Charge'
		  WHEN 3 THEN 'Misc Charge'
		  ELSE ''
		  END Apply_To_Doc_Type,
		COALESCE(PA.APTODCNM,'') Apply_To_Doc_Number,
		COALESCE(PA.APTODCDT,'1/1/1900') Apply_To_Doc_Date,
		COALESCE(PA.ApplyToGLPostDate,'1/1/1900') Apply_To_GL_Date,
		COALESCE(AD.DUEDATE,'1/1/1900') Apply_To_Due_Date,
		COALESCE(PA.APPLDAMT,0) Applied_Amount,
		COALESCE(PA.DISTKNAM,0) Discount_Amount,
		COALESCE(AD.TRXDSCRN,'') Apply_To_Doc_Description
INTO	#tmpData
FROM	(
		SELECT	VENDORID, DOCTYPE, DOCDATE, VCHRNMBR, DOCNUMBR,
				DOCAMNT, VOIDED, TRXSORCE, CHEKBKID, PSTGDATE,
				PYENTTYP, CARDNAME, TRXDSCRN
		FROM	PM30200
		UNION
		SELECT	VENDORID, DOCTYPE, DOCDATE, VCHRNMBR, DOCNUMBR,
				DOCAMNT, VOIDED, TRXSORCE, CHEKBKID, PSTGDATE,
				PYENTTYP, CARDNAME, TRXDSCRN
		FROM	PM20000 
		) P
		INNER JOIN PM00200 V ON P.VENDORID = V.VENDORID
		LEFT OUTER JOIN (SELECT	VENDORID, VCHRNMBR, DOCTYPE, APTVCHNM, APTODCTY,
								APTODCNM, APTODCDT, ApplyToGLPostDate, APPLDAMT, DISTKNAM
						FROM	PM10200
						UNION
						SELECT	VENDORID, VCHRNMBR, DOCTYPE, APTVCHNM, APTODCTY,
								APTODCNM, APTODCDT, ApplyToGLPostDate, APPLDAMT, DISTKNAM
						FROM	PM30300
						) PA ON P.VCHRNMBR = PA.VCHRNMBR AND P.VENDORID = PA.VENDORID AND P.DOCTYPE = PA.DOCTYPE
		LEFT OUTER JOIN (SELECT	DOCTYPE, VCHRNMBR, DUEDATE, TRXDSCRN FROM PM30200
						UNION
						SELECT	DOCTYPE, VCHRNMBR, DUEDATE, TRXDSCRN FROM PM20000
						) AD ON PA.APTODCTY = AD.DOCTYPE AND PA.APTVCHNM = AD.VCHRNMBR
WHERE	P.DOCNUMBR IN ('TIP0518181357') --,'TIP0518181621','T1P0518181537')

SELECT	SUM(Applied_Amount) AS SumAmount
FROM	#tmpData

SELECT	*
FROM	#tmpData

DROP TABLE #tmpData