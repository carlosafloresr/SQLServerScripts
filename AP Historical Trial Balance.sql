/******************************************************************
This view is for the Payables HATB for aging the document
date (using the payment terms on the document) and
picking transactions using the GL Posting Date.

Tables used:
- PM20000 - PM Transaction OPEN File
- PM30200 - PM Paid Transaction History File
- PM10200 - PM Apply To WORK OPEN File
- PM30300 - PM Apply To History File
- PM40101 - PM Period Setup File
- PM40102 - Payables Document Types
- SY03300 - Payment Terms Master
******************************************************************/
DECLARE	@ExecutionDate	Date = '06/30/2018',
		@VendorClass	Varchar(5) = 'DRV',
		@PostingDate	Date

SET @PostingDate = CAST(MONTH(@ExecutionDate) AS Varchar) + '/1/' + CAST(YEAR(@ExecutionDate) AS Varchar)
		
DECLARE	@tblData		Table (
		VendorId		Varchar(20),
		VoucherNumber	Varchar(40),
		DocumentType	Varchar(15),
		DocumentNumber	Varchar(35),
		DocumentDate	Date,
		PostingDate		Date,
		DueDate			Date,
		AgingBucket		Varchar(20),
		BucketIndex		Smallint,
		DocumentAmount	Numeric(10,2),
		CurrentBalance	Numeric(10,2))

SELECT	*
INTO	#tmpAPData
FROM	(
		SELECT	VCHRNMBR ,
				A.VENDORID ,
				DOCTYPE ,
				DOCDATE ,
				DOCNUMBR ,
				DOCAMNT ,
				BACHNUMB ,
				TRXSORCE ,
				BCHSOURC ,
				DISCDATE ,
				VOIDED ,
				PSTGDATE ,
				DATEADD(dd, ISNULL(C.DUEDTDS, 0), DOCDATE) AS DUEDATE ,
				'1900-01-01' AS VOIDPDATE
		FROM	dbo.PM20000 A
				INNER JOIN dbo.PM00200 VM ON A.VENDORID = VM.VENDORID
				LEFT OUTER JOIN dbo.SY03300 C ON A.PYMTRMID = C.PYMTRMID
		WHERE	PSTGDATE < @PostingDate
				AND VOIDED = 0
				AND VM.VNDCLSID = @VendorClass
		UNION
		SELECT	VCHRNMBR ,
				A.VENDORID ,
				DOCTYPE ,
				DOCDATE ,
				DOCNUMBR ,
				DOCAMNT ,
				BACHNUMB ,
				TRXSORCE ,
				BCHSOURC ,
				DISCDATE ,
				VOIDED ,	
				PSTGDATE ,
				DATEADD(dd, ISNULL(C.DUEDTDS, 0), DOCDATE) AS DUEDATE ,
				VOIDPDATE
		FROM    dbo.PM30200 A
				INNER JOIN dbo.PM00200 VM ON A.VENDORID = VM.VENDORID
				LEFT OUTER JOIN dbo.SY03300 C ON A.PYMTRMID = C.PYMTRMID
		WHERE	PSTGDATE < @PostingDate
				AND VOIDED = 0
				AND VM.VNDCLSID = @VendorClass
		) DATA

INSERT INTO @tblData
SELECT  RTRIM(W.VENDORID) ,
        RTRIM(W.VCHRNMBR) ,
		W1.DOCTYNAM AS DOCTYPE ,
        RTRIM(W.DOCNUMBR) ,
        CAST(W.DOCDATE AS Date) AS DOCDATE ,
        CAST(W.PSTGDATE AS Date) AS PSTGDATE,
        CAST(W.DUEDATE AS Date) AS DUEDATE,
        W.AGINGBUCKET ,
		PE.INDEX1 ,
        W.DOCUMENTAMT,
        W.CURTRXAMT
FROM    ( SELECT    X.VENDORID ,
                    X.VCHRNMBR ,
                    X.DOCTYPE ,
                    X.DOCNUMBR ,
                    X.DOCDATE ,
                    X.TRXSORCE ,
                    X.VOIDED ,
                    X.PSTGDATE ,
                    X.DUEDATE ,
                    X.DAYSDUE ,
                    CASE WHEN X.DAYSDUE > 999 THEN (SELECT TOP 1 DSCRIPTN FROM dbo.PM40101 ORDER BY ENDGPDYS DESC)
                         WHEN X.DAYSDUE < 0 THEN 'Not Due'
                         ELSE ISNULL((SELECT TOP 1 DSCRIPTN FROM dbo.PM40101 AG WHERE X.DAYSDUE <= AG.ENDGPDYS ORDER BY ENDGPDYS), '')
                    END AS AGINGBUCKET ,
                    X.VOIDPDATE ,
                    X.DOCUMENTAMT ,
                    X.APPLIEDAMT ,
                    X.WRITEOFFAMT ,
                    X.DISCTAKENAMT ,
                    X.REALGAINLOSSAMT ,
                    CASE WHEN X.DOCTYPE <= 3
                         THEN ( X.DOCUMENTAMT - X.APPLIEDAMT - X.WRITEOFFAMT - X.DISCTAKENAMT + X.REALGAINLOSSAMT )
                         ELSE ( X.DOCUMENTAMT - X.APPLIEDAMT - X.WRITEOFFAMT - X.DISCTAKENAMT + X.REALGAINLOSSAMT ) * -1
                    END AS CURTRXAMT
          FROM      ( SELECT    Z.VCHRNMBR ,
                                Z.VENDORID ,
                                Z.DOCTYPE ,
                                Z.DOCDATE ,
                                Z.DOCNUMBR ,
                                Z.DOCAMNT AS DOCUMENTAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.APPLDAMT)
                                                                     FROM   ( SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <@PostingDate
                                                                            AND Y.ApplyFromGLPostDate <@PostingDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     WHEN DOCTYPE > 3
                                          AND DOCTYPE <= 6 THEN ISNULL(( SELECT SUM(Y.APPLDAMT)
                                                                         FROM   ( SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                                ) Y
                                                                         WHERE  Y.GLPOSTDT <@PostingDate
                                                                                AND Y.ApplyToGLPostDate <@PostingDate
                                                                                AND Y.ApplyToGLPostDate <> '1900-01-01'
                                                                                AND Y.VENDORID = Z.VENDORID
                                                                                AND Y.VCHRNMBR = Z.VCHRNMBR
                                                                                AND Y.DOCTYPE = Z.DOCTYPE
                                                                       ), 0)
                                     ELSE 0
                                END AS APPLIEDAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.WROFAMNT)
                                                                     FROM   ( SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <@PostingDate
                                                                            AND Y.ApplyFromGLPostDate <@PostingDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                    ELSE 0
                                END AS WRITEOFFAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.DISTKNAM)
                                                                     FROM   ( SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate,
																						DISTKNAM
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate,
																						DISTKNAM
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <@PostingDate
                                                                            AND Y.ApplyFromGLPostDate <@PostingDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     ELSE 0
                                END AS DISCTAKENAMT ,
                                CASE WHEN DOCTYPE > 3 THEN ISNULL(( SELECT  SUM(Y.RLGANLOS)
                                                                    FROM    ( SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate,
																						RLGANLOS
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate,
																						RLGANLOS
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                            ) Y
                                                                    WHERE   Y.GLPOSTDT <@PostingDate
                                                                            AND Y.ApplyToGLPostDate <@PostingDate
                                                                            AND Y.ApplyToGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.VCHRNMBR = Z.VCHRNMBR
                                                                            AND Y.DOCTYPE = Z.DOCTYPE
                                                                  ), 0)
                                     ELSE 0
                                END AS REALGAINLOSSAMT ,
                                Z.TRXSORCE ,
                                Z.VOIDED ,
                                Z.PSTGDATE ,
                                Z.DUEDATE ,
                                DATEDIFF(dd, Z.DOCDATE, @PostingDate) AS DAYSDUE ,
                                Z.VOIDPDATE
                      FROM      #tmpAPData Z
                      WHERE     Z.PSTGDATE < @PostingDate
                                AND Z.VOIDED = 0
                    ) X
          UNION ALL
          SELECT    X.VENDORID ,
                    X.VCHRNMBR ,
                    X.DOCTYPE ,
                    X.DOCNUMBR ,
                    X.DOCDATE ,
                    X.TRXSORCE ,
                    X.VOIDED ,
                    X.PSTGDATE ,
                    X.DUEDATE ,
                    X.DAYSDUE ,
                    CASE WHEN X.DAYSDUE > 999 THEN ( SELECT TOP 1
                                                            DSCRIPTN
                                                     FROM   dbo.PM40101
                                                     ORDER BY ENDGPDYS DESC
                                                   )
                         WHEN X.DAYSDUE < 0 THEN 'Not Due'
                         ELSE ISNULL(( SELECT TOP 1
                                                DSCRIPTN
                                       FROM     dbo.PM40101 AG
                                       WHERE    X.DAYSDUE <= AG.ENDGPDYS
                                       ORDER BY ENDGPDYS
                                     ), '')
                    END AS AGINGBUCKET ,
                    X.VOIDPDATE ,
                    X.DOCUMENTAMT ,
                    X.APPLIEDAMT ,
                    X.WRITEOFFAMT ,
                    X.DISCTAKENAMT ,
                    X.REALGAINLOSSAMT ,
                    CASE WHEN X.DOCTYPE <= 3
                         THEN ( X.DOCUMENTAMT - X.APPLIEDAMT - X.WRITEOFFAMT - X.DISCTAKENAMT + X.REALGAINLOSSAMT )
                         ELSE ( X.DOCUMENTAMT - X.APPLIEDAMT - X.WRITEOFFAMT - X.DISCTAKENAMT + X.REALGAINLOSSAMT ) * -1
                    END AS CURTRXAMT
          FROM      ( SELECT    Z.VCHRNMBR ,
                                Z.VENDORID ,
                                Z.DOCTYPE ,
                                Z.DOCDATE ,
                                Z.DOCNUMBR ,
                                Z.DOCAMNT AS DOCUMENTAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.APPLDAMT)
                                                                     FROM   ( SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT < @PostingDate
                                                                            AND Y.ApplyFromGLPostDate < @PostingDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     WHEN DOCTYPE > 3
                                          AND DOCTYPE <= 6 THEN ISNULL(( SELECT SUM(Y.APPLDAMT)
                                                                         FROM   ( SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						APPLDAMT,
																						ApplyToGLPostDate
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                                ) Y
                                                                         WHERE  Y.GLPOSTDT <@PostingDate
                                                                                AND Y.ApplyToGLPostDate <@PostingDate
                                                                                AND Y.ApplyToGLPostDate <> '1900-01-01'
                                                                                AND Y.VENDORID = Z.VENDORID
                                                                                AND Y.VCHRNMBR = Z.VCHRNMBR
                                                                                AND Y.DOCTYPE = Z.DOCTYPE
                                                                       ), 0)
                                     ELSE 0
                                END AS APPLIEDAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.WROFAMNT)
																		FROM   (SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <@PostingDate
                                                                            AND Y.ApplyFromGLPostDate <@PostingDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     ELSE 0
                                END AS WRITEOFFAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.DISTKNAM)
                                                                     FROM   ( SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						DISTKNAM
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						WROFAMNT,
																						DISTKNAM
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT < @PostingDate
                                                                            AND Y.ApplyFromGLPostDate < @PostingDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     ELSE 0
                                END AS DISCTAKENAMT ,
                                CASE WHEN DOCTYPE > 3 THEN ISNULL(( SELECT  SUM(Y.RLGANLOS)
                                                                    FROM    ( SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						RLGANLOS,
																						ApplyToGLPostDate,
																						WROFAMNT
																				FROM	dbo.PM10200 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	POSTED = 1
																						AND VM.VNDCLSID = @VendorClass
																				UNION
																				SELECT	AP.VENDORID ,
																						ApplyFromGLPostDate ,
																						GLPOSTDT ,
																						APTVCHNM ,
																						APTODCTY ,
																						VCHRNMBR ,
																						DOCTYPE ,
																						RLGANLOS,
																						ApplyToGLPostDate,
																						WROFAMNT
																				FROM	dbo.PM30300 AP
																						INNER JOIN dbo.PM00200 VM ON AP.VENDORID = VM.VENDORID
																				WHERE	VM.VNDCLSID = @VendorClass
                                                                            ) Y
                                                                    WHERE   Y.GLPOSTDT <@PostingDate
                                                                            AND Y.ApplyToGLPostDate <@PostingDate
                                                                            AND Y.ApplyToGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.VCHRNMBR = Z.VCHRNMBR
                                                                            AND Y.DOCTYPE = Z.DOCTYPE
                                                                  ), 0)
                                    ELSE 0
                                END AS REALGAINLOSSAMT ,
                                Z.TRXSORCE ,
                                Z.VOIDED ,
                                Z.PSTGDATE ,
                                Z.DUEDATE ,
                                DATEDIFF(dd, Z.DOCDATE, @PostingDate) AS DAYSDUE ,
                                Z.VOIDPDATE
                      FROM      #tmpAPData Z
                      WHERE     Z.PSTGDATE < @PostingDate
                                AND Z.VOIDED = 1
                                AND Z.VOIDPDATE > @PostingDate
                    ) X
        ) W
		INNER JOIN dbo.PM40101 PE ON W.AGINGBUCKET = PE.DSCRIPTN
        INNER JOIN dbo.PM40102 W1 ON W.DOCTYPE = W1.DOCTYPE
WHERE   W.CURTRXAMT <> 0

DROP TABLE #tmpAPData

SELECT	*
FROM	@tblData
ORDER BY 
		VendorId,
		BucketIndex