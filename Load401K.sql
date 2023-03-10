/*
EXECUTE Load401K '10/2/2008', '10/30/2008', '401%', '401%', '401%', '401%', '401%', 3, 'CFLORES'
PRINT DATEDIFF(d, '8/7/2008', '7/31/2008') / 7.00
*/
ALTER PROCEDURE [dbo].[Load401K]
	@StartDate 			DATETIME, 
	@EndDate 			DATETIME,
	@StartDednCode 		VARCHAR(7),
	@EndDednCode 		VARCHAR(7),
	@StartBeneCode 		VARCHAR(7),
	@EndBeneCode 		VARCHAR(7),
	@LoanCode 			VARCHAR(7),
	@EmpOptions 		SMALLINT,
	@UserID 			VARCHAR(30)  
AS
DECLARE @EMPLOYID 		VARCHAR(15), 
	@LASTNAME 			VARCHAR(21),
	@FIRSTNAME 			VARCHAR(30),
	@MIDLNAME 			VARCHAR(30),
	@FNAMEMI 			VARCHAR(30),
	@SOCSCNUM 			VARCHAR(15),
	@HIREDATE 			DATETIME,
	@EARNINGS 			NUMERIC(19,5),
	@DEDNCODE 			VARCHAR(7),
	@DEDNAMNT 			NUMERIC(19,5),
	@DEDNPERC 			NUMERIC(19,5),
	@BENECODE 			VARCHAR(7),
	@BENEAMNT 			NUMERIC(19,5),
	@BENEPERC 			NUMERIC(19,5),
	@StartLoanCode 		VARCHAR(7),
	@EndLoanCode 		VARCHAR(7),
	@LOANAMNT 			NUMERIC(19,5),
	@LOANPERC 			NUMERIC(19,5),
	@DEPRTMNT 			VARCHAR(7),
	@YTDHOURS 			NUMERIC(19,5),
	@YTD_DAYS 			INTEGER,
	@YTD_START_DATE 	VARCHAR(30),
	@EMPLOYEELOANPAY	NUMERIC(19,5),
	@EMPLOYERMATCH 		NUMERIC(19,5),
	@TERM_DATE 			DATETIME,
	@GENDER				CHAR(10),
	@TITLE				CHAR(3),
	@PARTTIME			CHAR(3),
	@ADDRESS			VARCHAR(120),
	@MARITALSTATUS		INT,
	@MARITALSTATUS2		CHAR(1),
	@YEARSOFSERVICE		NUMERIC(19,1),
	@PAYROLLENDINGDATE	SMALLDATETIME,
	@STRTDATE			SMALLDATETIME,
	@PRTXEMPCONTRIB		NUMERIC(19,5),
	@PRTXEMPCONTRIBYTD	NUMERIC(19,5),
	@PLANCOMPENSATION	NUMERIC(19,5),
	@ANNUALCONTRIBUTION	NUMERIC(19,5),
	@ANNUALBONUSES		NUMERIC(19,5),
	@LOANAMOUNT			NUMERIC(19,5),
	@LOANPAYMENTS		NUMERIC(19,5),
	@ADDRESS1			VARCHAR(80),
	@ADDRESS2			VARCHAR(80),
	@CITY				VARCHAR(30),
	@STATE				CHAR(2),
	@ZIPCODE			CHAR(12),
	@EMPLOYERMATCHOK	CHAR(15),
	@BRTHDATE			DATETIME,
	@TERMDATE			DATETIME,
	@DRIVERCODE			CHAR(10)

	SET @StartLoanCode 		= @LoanCode 
	SET @EndLoanCode 		= @LoanCode 
	SET @PAYROLLENDINGDATE	= @EndDate

	DELETE IMC_401KREP WHERE USERID = @USERID
	
	IF @EmpOptions = 0 
	    BEGIN
		DECLARE EMPLOYEES CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT 	EMPLOYID, DEPRTMNT, LASTNAME, FRSTNAME, MIDLNAME, SOCSCNUM, STRTDATE, GENDER, MARITALSTATUS, STRTDATE, BRTHDATE,
				CASE WHEN EMPLOYMENTTYPE = 3 OR EMPLOYMENTTYPE = 4 THEN 'YES' ELSE 'NO'	END AS PARTTIME, DEMPINAC
		FROM 	UPR00100 
		WHERE 	INACTIVE = 0 AND
				STRTDATE <= @EndDate
		ORDER BY EMPLOYID
	    END
	    --SELECT * FROM UPR00100
	IF @EmpOptions = 1 
	    BEGIN
		DECLARE EMPLOYEES CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	EMPLOYID, DEPRTMNT, LASTNAME, FRSTNAME, MIDLNAME, SOCSCNUM, STRTDATE, GENDER, MARITALSTATUS, STRTDATE, BRTHDATE,
				CASE WHEN EMPLOYMENTTYPE = 3 OR EMPLOYMENTTYPE = 4 THEN 'YES' ELSE 'NO'	END AS PARTTIME, DEMPINAC
		FROM 	UPR00100 
		WHERE 	INACTIVE = 1 AND
				STRTDATE <= @EndDate
		ORDER BY EMPLOYID
	    END

	IF @EmpOptions = 2
	    BEGIN
		DECLARE EMPLOYEES CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT 	EMPLOYID, DEPRTMNT, LASTNAME, FRSTNAME, MIDLNAME, SOCSCNUM, STRTDATE, GENDER, MARITALSTATUS, STRTDATE, BRTHDATE,
				CASE WHEN EMPLOYMENTTYPE = 3 OR EMPLOYMENTTYPE = 4 THEN 'YES' ELSE 'NO'	END AS PARTTIME, DEMPINAC
		FROM 	UPR00100
		WHERE	STRTDATE <= @EndDate
		ORDER BY EMPLOYID
	    END

	IF @EmpOptions = 3
	    BEGIN
		DECLARE EMPLOYEES CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT 	EMPLOYID, DEPRTMNT, LASTNAME, FRSTNAME, MIDLNAME, SOCSCNUM, STRTDATE, GENDER, MARITALSTATUS, STRTDATE, BRTHDATE,
				CASE WHEN EMPLOYMENTTYPE = 3 OR EMPLOYMENTTYPE = 4 THEN 'YES' ELSE 'NO'	END AS PARTTIME, DEMPINAC
		FROM 	UPR00100 
				LEFT JOIN (SELECT EMPID_I, 
						MAX(TERMINATIONDATE_I) AS TERMINATIONDATE_I 
						FROM TE024230
						GROUP BY EMPID_I) TE024230 ON UPR00100.EMPLOYID = TE024230.EMPID_I
		WHERE	INACTIVE = 0
				OR (INACTIVE = 1
				AND TE024230.TERMINATIONDATE_I > UPR00100.STRTDATE
				AND YEAR(TE024230.TERMINATIONDATE_I) >= YEAR(CAST(@StartDate AS DateTime)))
				OR (INACTIVE = 1 AND (YEAR(TE024230.TERMINATIONDATE_I) < 1980 OR TE024230.TERMINATIONDATE_I IS Null))
				AND STRTDATE <= @EndDate
		ORDER BY EMPLOYID
	    END

-- START GENERAL INFORMATION
OPEN EMPLOYEES 
FETCH FROM EMPLOYEES INTO @EMPLOYID, @DEPRTMNT, @LASTNAME, @FIRSTNAME, @MIDLNAME, @SOCSCNUM, @HIREDATE,
			  @GENDER, @MARITALSTATUS, @STRTDATE, @BRTHDATE, @PARTTIME, @TERMDATE
WHILE @@FETCH_STATUS = 0 
BEGIN
	SELECT 	@EARNINGS = SUM(uprtrxam) 
	FROM	UPR30300 
	WHERE	CHEKDATE BETWEEN @STARTDATE AND @ENDDATE AND 
		PYRLRTYP = 1 AND 
		EMPLOYID = @EMPLOYID 
	
	SET @EARNINGS 			= ISNULL(@EARNINGS, 0)
	SET @FNAMEMI 			= RTRIM(ISNULL(@FIRSTNAME,'')) + ' ' + RTRIM(ISNULL(@MIDLNAME,''))
	SET @FNAMEMI 			= ISNULL(@FNAMEMI, '')
	SET @YTDHOURS 			= 0  
	SET @YTD_START_DATE 	= '1-JAN-' + LTRIM(STR(YEAR(@EndDate)))
	
	IF @YTD_START_DATE < @HIREDATE 
  		SET @YTD_START_DATE = @HIREDATE

	SELECT	@TERM_DATE = MAX(TERMINATIONDATE_I) 
	FROM 	TE024230 
	WHERE 	EMPID_I = @EMPLOYID

	SELECT	@DRIVERCODE = RTRIM(UserDef1)
	FROM	UPR00100
	WHERE 	EmployId = @EMPLOYID

	IF @TERM_DATE < '1/1/1980'
		SET @TERM_DATE = NULL

	IF @TERM_DATE >= @YTD_START_DATE OR @TERM_DATE IS Null
	BEGIN
		SET @YTD_DAYS = DATEDIFF(d, @YTD_START_DATE, CASE WHEN @TERM_DATE < @EndDate THEN @TERMDATE ELSE @EndDate END)
	END
	ELSE
	BEGIN
		SET @YTD_DAYS = 0
	END

	SET @YTD_DAYS = @YTD_DAYS / 7.0
	SET @YTDHOURS = @YTD_DAYS * CASE WHEN @PARTTIME = 'YES' THEN 25.0 ELSE 40.0 END
	SET @YTDHOURS = (SELECT SUM((MTDHOURS_1 + MTDHOURS_2 + MTDHOURS_3 + MTDHOURS_4 + MTDHOURS_5 + MTDHOURS_6 + MTDHOURS_7 + MTDHOURS_8 + MTDHOURS_9 + MTDHOURS_10 + MTDHOURS_11 + MTDHOURS_12) / 100.00) FROM UPR30301 WHERE EmployId = @EMPLOYID AND PayrolCd IN ('HOUR', 'SALARY') AND Year1 = YEAR(@EndDate))
	SET @YTDHOURS = CASE WHEN @DRIVERCODE = '' THEN ISNULL(@YTDHOURS, 0.0) ELSE (40 * @YTD_DAYS) END
	SET @YEARSOFSERVICE = (DATEDIFF(d, @STRTDATE, @EndDate) / 365.0)

	IF @DRIVERCODE <> ''
		PRINT @EMPLOYID
		PRINT @DRIVERCODE

	IF @GENDER = 1
		SET @TITLE = 'Mr'
	ELSE
		SET @TITLE = 'Mrs'

	IF @MARITALSTATUS = 1
		SET @MARITALSTATUS2 = 'M'
	ELSE
		SET @MARITALSTATUS2 = 'S'

	SELECT 	@ADDRESS = (SELECT RTRIM(Address1) + ', ' + RTRIM(City) + ', ' + RTRIM(State) + ' ' + ZipCode FROM UPR50000 WHERE EMPLOYID = @EMPLOYID)
	SELECT	@ADDRESS1 = Address1, @ADDRESS2 = Address2, @CITY = City, @STATE = State, @ZIPCODE = ZipCode FROM UPR00102 WHERE EMPLOYID = @EMPLOYID

	SET @TERM_DATE = ISNULL(@TERM_DATE, NULL)
	SET @PLANCOMPENSATION = (SELECT SUM(UPRTRXAM) FROM UPR30300 WHERE EMPLOYID = @EMPLOYID AND CHEKDATE BETWEEN @StartDate AND @EndDate AND PYRLRTYP = 1)
	SET @ANNUALCONTRIBUTION = (SELECT SUM(UPRTRXAM) FROM UPR30300 WHERE EMPLOYID = @EMPLOYID AND YEAR1 = YEAR(@EndDate) AND PYRLRTYP = 1)
	SET @ANNUALBONUSES = (SELECT ISNULL(SUM(UPRTRXAM), 0.0) FROM UPR30300 WHERE EMPLOYID = @EMPLOYID AND YEAR1 = YEAR(@EndDate) AND PYRLRTYP = 1 AND PAYROLCD IN ('BONUS', 'BONUSC'))
	SET @LOANAMOUNT = (SELECT ISNULL(DEDLTMAX, 0.00) FROM UPR00500 WHERE EMPLOYID = @EMPLOYID AND DEDUCTON = @LoanCode AND INACTIVE = 0)
	SET @LOANPAYMENTS = (SELECT ISNULL(SUM(UPRTRXAM), 0.00) FROM UPR30300 WHERE PAYROLCD = @LoanCode AND EMPLOYID = @EMPLOYID AND YEAR1 = YEAR(@EndDate))

	IF @LOANAMOUNT = 0
		SET @LOANPAYMENTS = 0

	SET @EMPLOYERMATCH = (SELECT SUM(UPRTRXAM) FROM UPR30300 WHERE YEAR(CHEKDATE) = YEAR(@EndDate) AND PAYROLCD BETWEEN @StartBeneCode AND @EndBeneCode AND EMPLOYID = @EMPLOYID AND PYRLRTYP = 3)
	SET @EMPLOYEELOANPAY = (SELECT SUM(UPRTRXAM) FROM UPR30300 WHERE CHEKDATE BETWEEN @StartDate AND @EndDate AND LEFT(PAYROLCD, 4) = '401L' AND EMPLOYID = @EMPLOYID AND PYRLRTYP = 2)
	SELECT @PRTXEMPCONTRIBYTD = SUM(UPRTRXAM) FROM UPR30300 WHERE YEAR(CHEKDATE) = YEAR(@EndDate) AND PAYROLCD BETWEEN @StartDednCode AND @EndDednCode AND EMPLOYID = @EMPLOYID AND PYRLRTYP = 2
	SELECT @PRTXEMPCONTRIB = SUM(UPRTRXAM) FROM UPR30300 WHERE CHEKDATE BETWEEN @StartDate AND @EndDate AND PAYROLCD BETWEEN @StartDednCode AND @EndDednCode AND EMPLOYID = @EMPLOYID AND PYRLRTYP = 2

	INSERT INTO IMC_401KREP (
			EMPLOYID, 
			DEPRTMNT, 
			LASTNAME, 
			FNAMEMI, 
			SOCSCNUM, 
			HIREDATE, 
			EARNINGS, 
			DEDNCODE, 
			DEDNAMNT,
			DEDNPERC, 
			BENECODE, 
			BENEAMNT, 
			BENEPERC, 
			LOANCODE, 
			LOANAMNT, 
			LOANPERC, 
			STARTDATE, 
			ENDDATE, 
			USERID, 
			YTDHOURS,
			EMPLOYEELOANPAY,
			EMPLOYERMATCH,
			EMPLOYERMATCHOK,
			TERMDATE,
			GENDER,
			TITLE,
			PARTTIME,
			ADDRESS,
			MARITALSTATUS,
			YEARSOFSERVICE,
			PRTXEMPCONTRIB,
			PRTXEMPCONTRIBYTD,
			PAYROLLENDINGDATE,
			PLANCOMPENSATION,
			ANNUALCOMPENSATION,
			EXCLUDEDCOMPENSATION,
			LOANPAYOFF,
			ADDRESS1,
			ADDRESS2,
			CITY,
			STATE,
			ZIPCODE,
			BRTHDATE) 
	VALUES (@EMPLOYID, 
			@DEPRTMNT, 
			@LASTNAME, 
			@FNAMEMI, 
			@SOCSCNUM, 
			@HIREDATE, 
			@EARNINGS,
			'' , 
			0,
			0, 
			'', 
			0, 
			0, 
			@LoanCode,
			0, 
			0, 
			@STARTDATE, 
			@ENDDATE, 
			@USERID, 
			@YTDHOURS, 
			ISNULL(@EMPLOYEELOANPAY, 0.0),
			ISNULL(@EMPLOYERMATCH, 0.0),
			'OK',
			@TERM_DATE,
			@GENDER,
			@TITLE,
			@PARTTIME,
			@ADDRESS,
			@MARITALSTATUS2,
			@YEARSOFSERVICE,
			ISNULL(@PRTXEMPCONTRIB, 0.0),
			ISNULL(@PRTXEMPCONTRIBYTD, 0.0),
			ISNULL(@PAYROLLENDINGDATE, 0.0),
			ISNULL(@PLANCOMPENSATION, 0.0),
			ISNULL(@ANNUALCONTRIBUTION, 0.0),
			ISNULL(@ANNUALBONUSES, 0.0),
			ISNULL(@LOANAMOUNT - @LOANPAYMENTS, 0.0),
			@ADDRESS1,
			@ADDRESS2,
			@CITY,
			@STATE,
			@ZIPCODE,
			@BRTHDATE)
	
	-- START DEDUCTIONS INFORMATION
	DECLARE DEDUCTIONS CURSOR LOCAL KEYSET OPTIMISTIC FOR 
	SELECT 	SUM(UPRTRXAM), PAYROLCD 
	FROM 	UPR30300 
	WHERE 	CHEKDATE BETWEEN @STARTDATE AND @ENDDATE AND 
		PYRLRTYP = 2 AND 
		PAYROLCD BETWEEN @StartDednCode AND @EndDednCode AND 
		EMPLOYID = @EMPLOYID 
	GROUP BY PAYROLCD 
		
	OPEN DEDUCTIONS
	FETCH FROM DEDUCTIONS INTO @DEDNAMNT, @DEDNCODE
	WHILE @@FETCH_STATUS = 0 
	    BEGIN
		SELECT	@DEDNPERC = DEDNPRCT_1 
	 	FROM	UPR00500 
	 	WHERE	EMPLOYID = @EMPLOYID AND 
		 	DEDUCTON = @DEDNCODE 
	 
		SET @DEDNPERC = ISNULL(@DEDNPERC, 0.00)
		SET @EMPLOYERMATCH = 0.00
	
		SET @EMPLOYERMATCH = ISNULL(@EMPLOYERMATCH, 0.00)

		IF EXISTS(SELECT * FROM IMC_401KREP WHERE EMPLOYID = @EMPLOYID AND USERID = @USERID AND (LEN(DEDNCODE) = 0 OR DEDNCODE = @DEDNCODE))
		     BEGIN

			UPDATE	IMC_401KREP 
			SET		DEDNCODE 		= @DEDNCODE, 
					DEDNAMNT 		= @DEDNAMNT, 
					DEDNPERC 		= @DEDNPERC
			WHERE	EMPLOYID = @EMPLOYID AND 
					USERID = @USERID 
			END 
		 ELSE
		    BEGIN
			INSERT INTO IMC_401KREP (
					EMPLOYID, 
					DEPRTMNT, 
					LASTNAME, 
					FNAMEMI, 
					SOCSCNUM, 
					HIREDATE, 
					EARNINGS, 
					DEDNCODE, 
					DEDNAMNT,
					DEDNPERC, 
					BENECODE, 
					BENEAMNT, 
					BENEPERC, 
					LOANCODE, 
					LOANAMNT, 
					LOANPERC, 
					STARTDATE, 
					ENDDATE, 
					USERID, 
					YTDHOURS,
					TERMDATE,
					GENDER,
					TITLE,
					PARTTIME,
					ADDRESS,
					MARITALSTATUS,
					YEARSOFSERVICE) 
			VALUES (@EMPLOYID, 
					@DEPRTMNT, 
					@LASTNAME, 
					@FNAMEMI, 
					@SOCSCNUM, 
					@HIREDATE, 
					@EARNINGS,
					'' , 
					0,
					0, 
					'', 
					0, 
					0, 
					'', 
					0, 
					0, 
					@STARTDATE, 
					@ENDDATE, 
					@USERID, 
					@YTDHOURS,
					@TERM_DATE,
					@GENDER,
					@TITLE,
					@PARTTIME,
					@ADDRESS,
					@MARITALSTATUS2,
					@YEARSOFSERVICE)
		     END
	 
	 	FETCH NEXT 
	 	FROM DEDUCTIONS 
	 	INTO 
	 		@DEDNAMNT, 
	 		@DEDNCODE
	    END
	
	CLOSE DEDUCTIONS	
	DEALLOCATE DEDUCTIONS
	-- END DEDUCTIONS INFORMATION

	-- START BENEFITS INFORMATION
	DECLARE BENEFITS CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT 	PAYROLCD, 
			SUM(UPRTRXAM)
	FROM	UPR30300 
	WHERE	CHEKDATE BETWEEN @STARTDATE AND @ENDDATE AND 
			PYRLRTYP = 3 AND
			PAYROLCD BETWEEN @StartBeneCode AND @EndBeneCode AND 
			EMPLOYID = @EMPLOYID
	GROUP BY PAYROLCD 
	
	OPEN BENEFITS
	
	FETCH FROM BENEFITS INTO @BENECODE, @BENEAMNT
	WHILE @@FETCH_STATUS = 0 
	    BEGIN
	    	SELECT	@BENEPERC = BNFPRCNT_1 
	    	FROM	UPR00600 
	    	WHERE	EMPLOYID = @EMPLOYID AND 
	    			BENEFIT = @BENECODE  
	    		
	    	SET	@BENEPERC = ISNULL(@BENEPERC, 0) 

	 	IF EXISTS(SELECT * FROM IMC_401KREP WHERE EMPLOYID = @EMPLOYID AND USERID = @USERID AND (LEN(BENECODE) = 0 OR BENECODE = @BENECODE))
	  	    BEGIN
	   		UPDATE	IMC_401KREP 
	   		SET		BENECODE 	= @BENECODE, 
	   				BENEAMNT 	= @BENEAMNT, 
	   				BENEPERC 	= @BENEPERC
	   		WHERE	EMPLOYID = @EMPLOYID AND 
	   				USERID = @USERID 
	  	    END
	  	ELSE
	  	    BEGIN
	   		INSERT INTO IMC_401KREP (
					EMPLOYID, 
					DEPRTMNT, 
					LASTNAME, 
					FNAMEMI, 
					SOCSCNUM, 
					HIREDATE, 
					EARNINGS, 
					DEDNCODE, 
					DEDNAMNT,
					DEDNPERC, 
					BENECODE, 
					BENEAMNT, 
					BENEPERC, 
					LOANCODE, 
					LOANAMNT, 
					LOANPERC, 
					STARTDATE, 
					ENDDATE, 
					USERID, 
					YTDHOURS, 
					TERMDATE,
					GENDER,
					TITLE,
					PARTTIME,
					ADDRESS,
					MARITALSTATUS,
					YEARSOFSERVICE) 
			VALUES (@EMPLOYID, 
					@DEPRTMNT, 
					@LASTNAME, 
					@FNAMEMI, 
					@SOCSCNUM, 
					@HIREDATE, 
					@EARNINGS,
					'' , 
					0,
					0, 
					'', 
					0, 
					0, 
					'', 
					0, 
					0, 
					@STARTDATE, 
					@ENDDATE, 
					@USERID, 
					@YTDHOURS,
					@TERM_DATE,
					@GENDER,
					@TITLE,
					@PARTTIME,
					@ADDRESS,
					@MARITALSTATUS2,
					@YEARSOFSERVICE)
	  	    END
	  	    
	 	FETCH NEXT FROM BENEFITS INTO @BENECODE, @BENEAMNT
	    END
	
	CLOSE BENEFITS
	DEALLOCATE BENEFITS
	-- END BENEFITS INFORMATION

	-- START LOANS INFORMATION
	DECLARE LOANS CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	PAYROLCD,
		SUM(UPRTRXAM)
	FROM	UPR30300 
	WHERE	CHEKDATE BETWEEN @STARTDATE AND @ENDDATE AND 
		PYRLRTYP = 2 AND
		PAYROLCD BETWEEN @StartLoanCode AND @EndLoanCode AND 
		EMPLOYID = @EMPLOYID 
	GROUP BY PAYROLCD 
	
	OPEN LOANS
	FETCH FROM LOANS INTO @LOANCODE, @LOANAMNT
	WHILE @@FETCH_STATUS = 0 
	    BEGIN
		SELECT	@LOANPERC = DEDNPRCT_1 
		FROM	UPR00500 
		WHERE	EMPLOYID = @EMPLOYID AND 
			DEDUCTON = @LOANCODE 
			
		SET @LOANPERC = ISNULL(@DEDNPERC, 0) 

		IF EXISTS(SELECT * FROM IMC_401KREP WHERE EMPLOYID = @EMPLOYID AND USERID = @USERID AND (LEN(LOANCODE) = 0 OR LOANCODE = @LOANCODE))
		     BEGIN
			UPDATE	IMC_401KREP 
			SET	LOANCODE = @LOANCODE, 
				LOANAMNT = @LOANAMNT, 
				LOANPERC = @LOANPERC 
			WHERE	EMPLOYID = @EMPLOYID AND 
				USERID = @USERID
		     END 
		ELSE
		     BEGIN
			INSERT INTO IMC_401KREP (
				EMPLOYID, 
				DEPRTMNT, 
				LASTNAME, 
				FNAMEMI, 
				SOCSCNUM, 
				HIREDATE, 
				EARNINGS, 
				DEDNCODE, 
				DEDNAMNT,
				DEDNPERC, 
				BENECODE, 
				BENEAMNT, 
				BENEPERC, 
				LOANCODE, 
				LOANAMNT, 
				LOANPERC, 
				STARTDATE, 
				ENDDATE, 
				USERID, 
				YTDHOURS,
				TERMDATE) 
			VALUES (
				@EMPLOYID, 
				@DEPRTMNT, 
				@LASTNAME, 
				@FNAMEMI, 
				@SOCSCNUM, 
				@HIREDATE, 
				0, 
				'', 
				0, 
				0, 
				'', 
				0, 
				0, 
				@LOANCODE, 
				@LOANAMNT, 
				@LOANPERC, 
				@STARTDATE, 
				@ENDDATE, 
				@USERID, 
				@YTDHOURS,
				@TERM_DATE)	    
		     END

		FETCH NEXT FROM LOANS INTO @LOANCODE, @LOANAMNT
            END

	CLOSE LOANS
	DEALLOCATE LOANS
	-- END LOANS INFORMATION

	FETCH FROM EMPLOYEES 
	INTO	@EMPLOYID, 
		@DEPRTMNT, 
		@LASTNAME, 
		@FIRSTNAME, 
		@MIDLNAME, 
		@SOCSCNUM, 
		@HIREDATE,
		@GENDER,
		@MARITALSTATUS,
		@STRTDATE,
		@BRTHDATE,
		@PARTTIME,
		@TERMDATE
END
CLOSE EMPLOYEES
DEALLOCATE EMPLOYEES
-- END GENERAL INFORMATION

SELECT	RTRIM(LASTNAME) + ', ' + FNAMEMI AS FullName, *
FROM	IMC_401KREP 
WHERE	USERID = @USERID
ORDER BY 1

