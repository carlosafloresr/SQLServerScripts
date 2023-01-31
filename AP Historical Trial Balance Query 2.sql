USE AIS
GO

DECLARE @RunDate			Date = '10/02/2021',
		@IncludeCredits		Bit = 1

DECLARE @tblTrialBalance	Table (
		VendorId			Varchar(15),
		VoucherNumber		Varchar(30),
		DocType				Varchar(15),
		DocumentNumber		Varchar(30),
		TrxSource			Varchar(30),
		DocumentDate		Date,
		PostingDate			Date,
		DueDate				Date,
		AgingBucket			Varchar(30),
		DocumentAmount		Numeric(10,2),
		[Current]			Numeric(10,2),
		[0_to_30_Days]		Numeric(10,2),
		[31_to_60_Days]		Numeric(10,2),
		[61_to_90_Days]		Numeric(10,2),
		[91_to_180_Days]	Numeric(10,2),
		[180_and_Over]		Numeric(10,2))

DECLARE	@tblPayables		Table (    
		VENDORID			Varchar(15),
        GLPOSTDT			Date,
        APPLDAMT			Numeric(10,2),
        VCHRNMBR			Varchar(30),
        DOCTYPE				Smallint,
        APTVCHNM			Varchar(30),
        APTODCTY			Smallint,
        ApplyToGLPostDate	Date,
		RLGANLOS			Numeric(10,2))

INSERT INTO @tblPayables
SELECT	VENDORID ,
		GLPOSTDT ,
		APPLDAMT ,
		VCHRNMBR ,
		DOCTYPE ,
		APTVCHNM ,
		APTODCTY ,
		ApplyToGLPostDate,
		RLGANLOS
FROM	dbo.PM10200
WHERE	POSTED = 1
		AND GLPOSTDT <= @RunDate
        AND ApplyFromGLPostDate <= @RunDate
        AND ApplyFromGLPostDate <> '1900-01-01'
		AND VENDORID = '851'
UNION
SELECT	VENDORID ,
		GLPOSTDT ,
		APPLDAMT ,
		VCHRNMBR ,
		DOCTYPE ,
		APTVCHNM ,
		APTODCTY ,
		ApplyToGLPostDate,
		RLGANLOS
FROM	dbo.PM30300
WHERE	GLPOSTDT <= @RunDate
        AND ApplyFromGLPostDate <= @RunDate
        AND ApplyFromGLPostDate <> '1900-01-01'
		AND VENDORID = '851'

SELECT * FROM @tblPayables

INSERT INTO @tblTrialBalance
SELECT  W.VENDORID ,
        W.VCHRNMBR ,
		W1.DOCTYNAM AS DOCTYPE ,
        W.DOCNUMBR ,
		W.TRXSORCE ,
        W.DOCDATE ,
        W.PSTGDATE ,
        W.DUEDATE ,
        W.AGINGBUCKET ,
        W.DOCUMENTAMT ,
		CASE WHEN DATEDIFF(d, W.DOCDATE, @RunDate) <= 30 THEN W.CURTRXAMTT ELSE 0 END [Current],
		CASE WHEN DATEDIFF(d, W.DOCDATE, @RunDate) <= 30 THEN W.CURTRXAMTT ELSE 0 END [0_to_30_Days],
		CASE WHEN DATEDIFF(d, W.DOCDATE, @RunDate) BETWEEN 31 AND 60 THEN W.CURTRXAMTT ELSE 0 END [31_to_60_Days],
		CASE WHEN DATEDIFF(d, W.DOCDATE, @RunDate) BETWEEN 61 AND 90 THEN W.CURTRXAMTT ELSE 0 END [61_to_90_Days],
		CASE WHEN DATEDIFF(d, W.DOCDATE, @RunDate) BETWEEN 91 AND 180 THEN W.CURTRXAMTT ELSE 0 END [91_to_180_Days],
		CASE WHEN DATEDIFF(d, W.DOCDATE, @RunDate) > 180 THEN W.CURTRXAMTT ELSE 0 END [180_and_Over]
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
                    CASE WHEN X.DAYSDUE > 999 THEN ( SELECT TOP 1 DSCRIPTN
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
                    END AS CURTRXAMTT
          FROM      ( SELECT    Z.VCHRNMBR ,
                                Z.VENDORID ,
                                Z.DOCTYPE ,
                                Z.DOCDATE ,
                                Z.DOCNUMBR ,
                                Z.DOCAMNT AS DOCUMENTAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.APPLDAMT)
                                                                     FROM   ( SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        APPLDAMT
                                                                              FROM      dbo.PM10200
                                                                              WHERE     POSTED = 1
                                                                              UNION
                                                                              SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        APPLDAMT
                                                                              FROM      dbo.PM30300
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     WHEN DOCTYPE > 3
                                          AND DOCTYPE <= 6 THEN ISNULL(( SELECT SUM(Y.APPLDAMT)
                                                                         FROM   @tblPayables Y
                                                                         WHERE  Y.GLPOSTDT <= @RunDate
                                                                                AND Y.ApplyToGLPostDate <= @RunDate
                                                                                AND Y.ApplyToGLPostDate <> '1900-01-01'
                                                                                AND Y.VENDORID = Z.VENDORID
                                                                                AND Y.VCHRNMBR = Z.VCHRNMBR
                                                                                AND Y.DOCTYPE = Z.DOCTYPE
                                                                       ), 0)
                                     ELSE 0
                                END AS APPLIEDAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.WROFAMNT)
                                                                     FROM   ( SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        WROFAMNT
                                                                              FROM      dbo.PM10200
                                                                              WHERE     POSTED = 1
                                                                              UNION
                                                                              SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        WROFAMNT
                                                                              FROM      dbo.PM30300
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                    ELSE 0
                                END AS WRITEOFFAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.DISTKNAM)
                                                                     FROM   ( SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        DISTKNAM
                                                                              FROM      dbo.PM10200
                                                                              WHERE     POSTED = 1
                                                                              UNION
                                                                              SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        DISTKNAM
                                                                              FROM      dbo.PM30300
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     ELSE 0
                                END AS DISCTAKENAMT ,
                                CASE WHEN DOCTYPE > 3 THEN ISNULL(( SELECT  SUM(Y.RLGANLOS)
                                                                    FROM    @tblPayables Y
                                                                    WHERE   Y.GLPOSTDT <= @RunDate
                                                                            AND Y.ApplyToGLPostDate <= @RunDate
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
                                DATEDIFF(dd, Z.DOCDATE, @RunDate) AS DAYSDUE ,
                                Z.VOIDPDATE
                      FROM      ( SELECT    VCHRNMBR ,
                                            VENDORID ,
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
                                  FROM      dbo.PM20000 A
                                            LEFT OUTER JOIN dbo.SY03300 C ON A.PYMTRMID = C.PYMTRMID
                                  UNION ALL
                                  SELECT    VCHRNMBR ,
                                            VENDORID ,
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
                                  FROM      dbo.PM30200 A
                                            LEFT OUTER JOIN dbo.SY03300 C ON A.PYMTRMID = C.PYMTRMID
                                ) Z
                      WHERE     Z.PSTGDATE <= @RunDate
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
                    END AS CURTRXAMTT
          FROM      ( SELECT    Z.VCHRNMBR ,
                                Z.VENDORID ,
                                Z.DOCTYPE ,
                                Z.DOCDATE ,
                                Z.DOCNUMBR ,
                                Z.DOCAMNT AS DOCUMENTAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.APPLDAMT)
                                                                     FROM   ( SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        APPLDAMT
                                                                              FROM      dbo.PM10200
                                                                              WHERE     POSTED = 1
                                                                              UNION
                                                                              SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        APPLDAMT
                                                                              FROM      dbo.PM30300
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     WHEN DOCTYPE > 3
                                          AND DOCTYPE <= 6 THEN ISNULL(( SELECT SUM(Y.APPLDAMT)
                                                                         FROM   @tblPayables Y
                                                                         WHERE  Y.GLPOSTDT <= @RunDate
                                                                                AND Y.ApplyToGLPostDate <= @RunDate
                                                                                AND Y.ApplyToGLPostDate <> '1900-01-01'
                                                                                AND Y.VENDORID = Z.VENDORID
                                                                                AND Y.VCHRNMBR = Z.VCHRNMBR
                                                                                AND Y.DOCTYPE = Z.DOCTYPE
                                                                       ), 0)
                                     ELSE 0
                                END AS APPLIEDAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.WROFAMNT)
                                                                     FROM   ( SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        WROFAMNT
                                                                              FROM      dbo.PM10200
                                                                              WHERE     POSTED = 1
                                                                              UNION
                                                                              SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        WROFAMNT
                                                                              FROM      dbo.PM30300
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     ELSE 0
                                END AS WRITEOFFAMT ,
                                CASE WHEN DOCTYPE <= 3 THEN ISNULL(( SELECT SUM(Y.DISTKNAM)
                                                                     FROM   ( SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        DISTKNAM
                                                                              FROM      dbo.PM10200
                                                                              WHERE     POSTED = 1
                                                                              UNION
                                                                              SELECT    VENDORID ,
                                                                                        ApplyFromGLPostDate ,
                                                                                        GLPOSTDT ,
                                                                                        APTVCHNM ,
                                                                                        APTODCTY ,
                                                                                        VCHRNMBR ,
                                                                                        DOCTYPE ,
                                                                                        DISTKNAM
                                                                              FROM      dbo.PM30300
                                                                            ) Y
                                                                     WHERE  Y.GLPOSTDT <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <= @RunDate
                                                                            AND Y.ApplyFromGLPostDate <> '1900-01-01'
                                                                            AND Y.VENDORID = Z.VENDORID
                                                                            AND Y.APTVCHNM = Z.VCHRNMBR
                                                                            AND Y.APTODCTY = Z.DOCTYPE
                                                                   ), 0)
                                     ELSE 0
                                END AS DISCTAKENAMT ,
                                CASE WHEN DOCTYPE > 3 THEN ISNULL(( SELECT  SUM(Y.RLGANLOS)
                                                                    FROM    @tblPayables Y
                                                                    WHERE   Y.GLPOSTDT <= @RunDate
                                                                            AND Y.ApplyToGLPostDate <= @RunDate
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
                                DATEDIFF(dd, Z.DOCDATE, @RunDate) AS DAYSDUE ,
                                Z.VOIDPDATE
                      FROM      ( SELECT    VCHRNMBR ,
                                            VENDORID ,
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
                                  FROM      dbo.PM20000 A
                                            LEFT OUTER JOIN dbo.SY03300 C ON A.PYMTRMID = C.PYMTRMID
                                  UNION
                                  SELECT    VCHRNMBR ,
                                            VENDORID ,
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
                                  FROM      dbo.PM30200 A
                                            LEFT OUTER JOIN dbo.SY03300 C ON A.PYMTRMID = C.PYMTRMID
                                ) Z
                      WHERE     Z.PSTGDATE <= @RunDate
                                AND Z.VOIDED = 1
                                AND Z.VOIDPDATE >= @RunDate
                    ) X
        ) W
        INNER JOIN dbo.PM40102 W1 ON W.DOCTYPE = W1.DOCTYPE
WHERE   (@IncludeCredits = 1 AND W.CURTRXAMTT <> 0)
		OR (@IncludeCredits = 0 AND W.CURTRXAMTT > 0)

SELECT	VendorId,
		VoucherNumber,
		DocType,
		DocumentNumber,
		TrxSource,
		DocumentDate,
		PostingDate,
		DueDate,
		AgingBucket,
		DocumentAmount,
		--[Current],
		[0_to_30_Days],
		[31_to_60_Days],
		[61_to_90_Days],
		[91_to_180_Days],
		[180_and_Over]
FROM	@tblTrialBalance
ORDER BY VendorId, DocumentDate, DocumentNumber