/*
EXECUTE USP_BusinessAlert_GLAccountsNotUsed
*/
CREATE PROCEDURE USP_BusinessAlert_GLAccountsNotUsed
AS
SET NOCOUNT ON

DECLARE	@Body					Varchar(MAX) = '',
		@EmailTo				Varchar(250) = 'teds@imccompanies.com;meberly@imcc.com;kpowell@imccompanies.com',
		@EmailCC				Varchar(250) = 'cflores@imcc.com',
		@EmailSubject			Varchar(75) = ''

DECLARE	@Company				Varchar(5),
		@GLAccount				Varchar(20),
		@Description			Varchar(100),
		@AccountType			Varchar(30),
		@Category				Varchar(100),
		@UserDefine				Varchar(100),
		@CreationDate			Date,
		@SimilarSegment			Varchar(150),
		@LastAccount			Varchar(20) = '',
		@HTMLTable				Varchar(500) = '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;">',
		@Counter				Smallint = 0,
		@Query					Varchar(Max)

DECLARE	@tblAccounts			Table (
		Company					Varchar(5),
		GLAccount				Varchar(20),
		Description				Varchar(100),
		AccountType				Varchar(30),
		Category				Varchar(100),
		UserDefine				Varchar(100),
		CreationDate			Date,
		SimilarSegment			Varchar(150))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(InterId) AS Company
FROM	DYNAMICS.dbo.View_AllCompanies
WHERE	InterId  NOT IN ('ABS','ATEST','FIDMO','RCMR')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Executng for ' + @Company

	SET @Query = N'SELECT ''' + @Company + ''' AS Company,
			RTRIM(G1.ACTNUMBR_1) + ''-'' + RTRIM(G1.ACTNUMBR_2) + ''-'' + RTRIM(G1.ACTNUMBR_3) AS GLAccount,
			RTRIM(G1.ACTDESCR) AS Description,
			CASE WHEN G1.PSTNGTYP = 1 THEN ''Profit & Loss'' ELSE ''Balance Sheet'' END AS AccountType,
			RTRIM(G2.ACCATDSC) AS Category,
			RTRIM(G1.USERDEF1) AS UserDefineField,
			CAST(G1.CREATDDT AS Date) AS CreatedOn,
			RTRIM(GC.ACTNUMBR_1) + ''-'' + RTRIM(GC.ACTNUMBR_2) + ''-'' + RTRIM(GC.ACTNUMBR_3) + '' '' + RTRIM(GC.ACTDESCR) AS SimilarSegment3
	FROM	' + @Company + '.dbo.GL00100 G1
			INNER JOIN ' + @Company + '.dbo.GL00102 G2 ON G1.ACCATNUM = G2.ACCATNUM
			LEFT JOIN ' + @Company + '.dbo.GL00100 GC ON G1.ACTNUMBR_3 = GC.ACTNUMBR_3 AND G1.CREATDDT > GC.CREATDDT
	WHERE	G1.ACTIVE = 1
			AND G1.CREATDDT >= ''' + CAST(DATEADD(dd, -30, GETDATE()) AS Varchar) + '''
			AND G1.ACTINDX NOT IN (SELECT ACTINDX FROM ' + @Company + '.dbo.GL20000)'

	DELETE @tblAccounts

	INSERT INTO @tblAccounts
	EXECUTE(@Query)

	SET @Counter		= 0
	SET @LastAccount	= 'NONE'
	SET @Body			= '' 
	SET @EmailSubject	= @Company +  ' - GL Accounts not used in Great Plains since its creation'

	DECLARE curAccounts CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	GLAccount, Description, AccountType, Category, UserDefine, CreationDate, ISNULL(SimilarSegment, '') AS SimilarSegment
	FROM	@tblAccounts

	OPEN curAccounts 
	FETCH FROM curAccounts INTO @GLAccount, @Description, @AccountType, @Category, @UserDefine, @CreationDate, @SimilarSegment

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF @GLAccount <> @LastAccount
		BEGIN
			IF @Counter = 0
			BEGIN
				SET @Body = @HTMLTable
				SET @Body = @Body + '<tr><td style="text-align:center;background-color:Yellow">GL Account</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Description</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Account Type</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Category</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">User Define Field</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Creation Date</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Similar Accounts</td></tr>'
			END
			ELSE
				SET @Body = @Body + '</td></tr>'

			SET @Body = @Body + '<tr><td style="text-align:center;color:blue;vertical-align:top;">' + @GLAccount + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @Description + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @AccountType + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @Category + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @UserDefine + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + CAST(@CreationDate AS Varchar) + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;text-align:left;">' + @SimilarSegment
			SET @LastAccount = @GLAccount
		END
		ELSE
			SET @Body = @Body + '<br/>' + @SimilarSegment

		SET @Counter = @Counter + 1
	
		FETCH FROM curAccounts INTO @GLAccount, @Description, @AccountType, @Category, @UserDefine, @CreationDate, @SimilarSegment
	END

	SET @Body = @Body + '</td></tr></table></body></html>'

	CLOSE curAccounts
	DEALLOCATE curAccounts

	IF @@ERROR = 0 AND @Counter > 0
	BEGIN
		EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'Great Plains Notifications',  
										@recipients = @EmailTo,
										@copy_recipients = @EmailCC,
										@subject = @EmailSubject,
										@body_format = 'HTML',
										@body = @Body
	END

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies