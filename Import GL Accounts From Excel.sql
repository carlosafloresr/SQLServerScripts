/* 
********************************************
**** INSERT GL ACCOUNT INTO GREAT PLAINS *** 
********************************************
*/ 
DECLARE	@ActIndx	Int,
		@Segment1	Int,
		@Segment2	Int,
		@Segment3	Int,
		@Seg1Leng	Int

SET		@ActIndx	= (SELECT ISNULL(MAX(ActIndx), 0) + 1 FROM dbo.GL00100)

IF DB_NAME() = 'NDS'
	BEGIN
		SET		@Segment1	= 1
		SET		@Segment2	= 3
		SET		@Segment3	= 5
		SET		@Seg1Leng	= 2
		
	END
ELSE
	IF (SELECT TOP 1 CASE WHEN GPCustom.dbo.AT('-', AccountNumber, 1) > 0 THEN  1 ELSE 0 END FROM GPCustom.dbo.FI_Accounts) = 1
	BEGIN
		SET		@Segment1	= 1
		SET		@Segment2	= 3
		SET		@Segment3	= 6
		SET		@Seg1Leng	= 1
	END
	ELSE
	BEGIN
		SET		@Segment1	= 1
		SET		@Segment2	= 2
		SET		@Segment3	= 4
		SET		@Seg1Leng	= 1
	END

INSERT INTO dbo.GL00100 (ActIndx, ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTDESCR, ACTALIAS, PSTNGTYP, UserDef1, UsrDefs1)
SELECT	@ActIndx + ROW_NUMBER() OVER (ORDER BY ACTNUMBR_1) AS ActIndx,
		*
FROM	(
		SELECT	DISTINCT SUBSTRING(ACCT.AccountNumber, @Segment1, @Seg1Leng) AS ACTNUMBR_1
				,SUBSTRING(ACCT.AccountNumber, @Segment2, 2) AS  ACTNUMBR_2
				,SUBSTRING(ACCT.AccountNumber, @Segment3, 4) AS  ACTNUMBR_3
				,LEFT(ACCT.AcctDescription, 51) AS ACTDESCR
				,LEFT(ACCT.AcctDescription, 21) AS ACTALIAS
				,CASE WHEN ACCT.PostingType = 'Balance Sheet' THEN 0 ELSE 1 END AS PSTNGTYP
				,LEFT(ISNULL(ACCT.AccountCategory, ''), 21) AS UserDef1
				,LEFT(ISNULL(ACCT.UserDef1, ''), 31) AS UsrDefs1
		FROM	GPCustom.dbo.FI_Accounts ACCT
				LEFT JOIN dbo.GL00100 GLAC ON SUBSTRING(ACCT.AccountNumber, @Segment1, @Seg1Leng) = GLAC.ACTNUMBR_1 AND SUBSTRING(ACCT.AccountNumber, @Segment2, 2) = GLAC.ACTNUMBR_2 AND SUBSTRING(ACCT.AccountNumber, @Segment3, 4) = GLAC.ACTNUMBR_3
		WHERE	GLAC.ACTNUMBR_1 IS Null
				AND ACCT.AccountNumber <> ''
		) DATA
ORDER BY 1, 2, 3

-- SELECT * FROM GL00105 WHERE ACTNUMBR_2 = '14' ORDER BY ACTNUMST
IF @@ROWCOUNT > 0 AND @@ERROR = 0
BEGIN
	UPDATE	GL00100
	SET		GL00100.ACCATNUM = DATA.ACCATNUM,
			GL00100.ACTIVE = 1,
			GL00100.ACCTTYPE = 1,
			GL00100.ACCTENTR = 1,
			GL00100.PostSlsIn = 1,
			GL00100.PostIvIn = 1,
			GL00100.PostPurchIn = 1,
			GL00100.PostPRIn = 1
	FROM	(
			SELECT	GL2.ACTINDX
					,SUBSTRING(AccountNumber, @Segment1, @Seg1Leng) AS ACTNUMBR_1
					,SUBSTRING(AccountNumber, @Segment2, 2) AS  ACTNUMBR_2
					,SUBSTRING(AccountNumber, @Segment3, 4) AS  ACTNUMBR_3
					,GL2.ACCATNUM
			FROM	GPCustom.dbo.FI_Accounts FI
					LEFT JOIN GL00102 GL1 ON FI.AccountCategory = GL1.ACCATDSC
					LEFT JOIN GL00100 GL2 ON SUBSTRING(AccountNumber, @Segment1, @Seg1Leng) = GL2.ACTNUMBR_1 AND SUBSTRING(AccountNumber, @Segment2, 2) = GL2.ACTNUMBR_2 AND SUBSTRING(AccountNumber, @Segment3, 4) = GL2.ACTNUMBR_3
			) DATA
	WHERE	GL00100.ACTINDX = DATA.ACTINDX
END