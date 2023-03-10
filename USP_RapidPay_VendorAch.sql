USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_RapidPay_VendorAch]    Script Date: 10/14/2022 8:15:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
==============================================================================================================================
VERSION		MODIFIED	USER				New Functionality
==============================================================================================================================
1.0			02/17/2022	Carlos A. Flores	Saves/restores vendor master and vendor ACH data for Rapid Pay vendors
1.1			10/21/2022	Carlos A. Flores	Vendor class saved and updated to TRDR
==============================================================================================================================
EXECUTE USP_RapidPay_VendorAch 'AIS', '50010A', 0
==============================================================================================================================
*/
ALTER PROCEDURE [dbo].[USP_RapidPay_VendorAch]
		@Company		Varchar(5),
		@VendorId		Varchar(15),
		@Reversal		Smallint = 0
AS
SET NOCOUNT ON

DECLARE @Query			Varchar(MAX),
		@VNDCHKNM		Varchar(100),
		@PYMTRMID		Varchar(30),
		@EffDate		Date,
		@RecId_ACH		Int,
		@RecId_ADR		Int,
		@VNDCLSID		Varchar(10),
		@ProjectId		Int = 186

DECLARE @tblVndAddr		Table (AddressCode Varchar(30))

SET @EffDate	= ISNULL((SELECT RP_EffectiveDate FROM GPCustom.dbo.GPVendorMaster WHERE Company = @Company AND VendorId = @VendorId), GETDATE())
SET @RecId_ACH	= (SELECT MIN(RecordId) FROM RapidPay_VendorAch WHERE Company = @Company AND VendorId = @VendorId AND EffectiveDate = @EffDate)
SET @RecId_ADR	= (SELECT MIN(RecordId) FROM RapidPay_VendorAddress WHERE Company = @Company AND VendorId = @VendorId AND EffectiveDate = @EffDate)
set @VNDCLSID	= (SELECT RTRIM(VNDCLSID) FROM RapidPay_VendorAch WHERE Company = @Company AND VendorId = @VendorId AND EffectiveDate = @EffDate)
SET @Query		= N'SELECT ADRSCODE FROM ' + @Company + '.dbo.PM00300 WHERE ADRSCODE = ''REMIT'' AND VENDORID = ''' + @VendorId + ''''

INSERT INTO @tblVndAddr
EXECUTE(@Query)

SET @Query	= N'SELECT ''' + RTRIM(@Company) + ''' AS COMPANY
		,RTRIM(VND.VNDCHKNM) AS VNDCHKNM
		,RTRIM(VND.PYMTRMID) AS PYMTRMID
		,RTRIM(VND.VADCDTRO) AS VND_REMITADRSCODE
		,RTRIM(VND.VADDCDPR) AS VND_MAINADRSCODE
		,RTRIM(VND.VNDCLSID) AS VNDCLSID
		,[SYT].[SERIES]
        ,[SYT].[CustomerVendor_ID]
        ,[SYT].[ADRSCODE]
        ,RTRIM(VND.VENDORID) AS VENDORID
        ,[SYT].[CUSTNMBR]
        ,[SYT].[EFTUseMasterID]
        ,[SYT].[EFTBankType]
        ,[SYT].[FRGNBANK]
        ,[SYT].[INACTIVE]
        ,[SYT].[BANKNAME]
        ,[SYT].[EFTBankAcct]
        ,[SYT].[EFTBankBranch]
        ,[SYT].[GIROPostType]
        ,[SYT].[EFTBankCode]
        ,[SYT].[EFTBankBranchCode]
        ,[SYT].[EFTBankCheckDigit]
        ,[SYT].[BSROLLNO]
        ,[SYT].[IntlBankAcctNum]
        ,[SYT].[SWIFTADDR]
        ,[SYT].[CustVendCountryCode]
        ,[SYT].[DeliveryCountryCode]
        ,[SYT].[BNKCTRCD]
        ,[SYT].[CBANKCD]
        ,[SYT].[ADDRESS1]
        ,[SYT].[ADDRESS2]
        ,[SYT].[ADDRESS3]
        ,[SYT].[ADDRESS4]
        ,[SYT].[RegCode1]
        ,[SYT].[RegCode2]
        ,[SYT].[BankInfo7]
        ,[SYT].[EFTTransitRoutingNo]
        ,[SYT].[CURNCYID]
        ,[SYT].[EFTTransferMethod]
        ,[SYT].[EFTAccountType]
        ,[SYT].[EFTPrenoteDate]
        ,[SYT].[EFTTerminationDate]
        ,[SYT].[DEX_ROW_ID]
		,''' + CONVERT(Char(10), @EffDate, 101) + ''' AS [EffectiveDate] 
FROM	' + RTRIM(@Company) + '.dbo.PM00200 VND
		LEFT JOIN ' + RTRIM(@Company) + '.dbo.SY06000 SYT ON VND.VENDORID = SYT.VENDORID AND VND.VADCDTRO = SYT.ADRSCODE
WHERE	VND.VENDORID = ''' + RTRIM(@VendorId) + ''''

-- BACKUP SOME VENDOR MASTER DATA AND ACH/EFT SETUP
IF @Reversal = 0
BEGIN
	DELETE	RapidPay_VendorAch 
	WHERE	Company = @Company 
			AND VendorId = @VendorId 
			AND EffectiveDate = @EffDate

	DELETE	RapidPay_VendorAddress 
	WHERE	Company = @Company 
			AND VendorId = @VendorId 
			AND EffectiveDate = @EffDate
	
	INSERT INTO [dbo].[RapidPay_VendorAch]
			   ([COMPANY]
			   ,[VNDCHKNM]
			   ,[PYMTRMID]
			   ,[VND_REMITADRSCODE]
			   ,[VND_MAINADRSCODE]
			   ,[VNDCLSID]
			   ,[SERIES]
			   ,[CustomerVendor_ID]
			   ,[ADRSCODE]
			   ,[VENDORID]
			   ,[CUSTNMBR]
			   ,[EFTUseMasterID]
			   ,[EFTBankType]
			   ,[FRGNBANK]
			   ,[INACTIVE]
			   ,[BANKNAME]
			   ,[EFTBankAcct]
			   ,[EFTBankBranch]
			   ,[GIROPostType]
			   ,[EFTBankCode]
			   ,[EFTBankBranchCode]
			   ,[EFTBankCheckDigit]
			   ,[BSROLLNO]
			   ,[IntlBankAcctNum]
			   ,[SWIFTADDR]
			   ,[CustVendCountryCode]
			   ,[DeliveryCountryCode]
			   ,[BNKCTRCD]
			   ,[CBANKCD]
			   ,[ADDRESS1]
			   ,[ADDRESS2]
			   ,[ADDRESS3]
			   ,[ADDRESS4]
			   ,[RegCode1]
			   ,[RegCode2]
			   ,[BankInfo7]
			   ,[EFTTransitRoutingNo]
			   ,[CURNCYID]
			   ,[EFTTransferMethod]
			   ,[EFTAccountType]
			   ,[EFTPrenoteDate]
			   ,[EFTTerminationDate]
			   ,[DEX_ROW_ID]
			   ,[EffectiveDate])
	EXECUTE(@Query)

	IF @@ERROR = 0
	BEGIN
		DECLARE @tblEmails Table (RowId Int)

		-- LOAD THE RAISTONE PARAMETERS
		SELECT	ParameterCode AS Parameter,
				VarC AS ParValue
		INTO	##tmpParameters
		FROM	GPCustom.dbo.Parameters
		WHERE	ParameterCode LIKE 'RAISTONE_%'

		SET @VNDCHKNM = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = 'RAISTONE_COMPANY')
		SET @PYMTRMID = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = 'RAISTONE_PYMTRMID')

		-- BACKUP THE ACTIVE REMIT TO ADDRESS DATA
		EXECUTE USP_RapidPay_VendorAddress @Company, @VendorId

		-- VENDOR MASTER TABLE -- 				
		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM00200 
			SET PYMNTPRI = ''EFT'', 
				VADCDTRO = ''REMIT'', 
				VADDCDPR = ''REMIT'', 
				VNDCHKNM = ''' + @VNDCHKNM + ''', 
				PYMTRMID = ''' + @PYMTRMID + ''',
				VNDCNTCT = VENDNAME,
				VNDCLSID = ''TRDR'',
				ADDRESS1 = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_ADDRESS''),
				ADDRESS2 = '''', 
				ADDRESS3 = '''', 
				CITY	 = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_CITY''),
				STATE	 = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_STATE''),
				ZIPCODE	 = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_ZIP'')
			WHERE VENDORID = ''' + RTRIM(@VendorId) + ''''
			
		EXECUTE(@Query)

		-- VENDOR ADDRESS MASTER TABLE
		IF (SELECT COUNT(*) FROM @tblVndAddr) = 0
		BEGIN
			SET @Query = N'INSERT INTO ' + RTRIM(@Company) + '.dbo.PM00300 
						(VENDORID,
						ADRSCODE,
						VNDCNTCT,
						ADDRESS1,
						CITY,
						STATE,
						ZIPCODE)
						SELECT	''' + @VendorId + ''',''REMIT'',
								VNDNAME	= (SELECT VENDNAME FROM ' + RTRIM(@Company) + '.dbo.PM00200 WHERE VENDORID = ''' + RTRIM(@VendorId) + '''),
								ADDRESS = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_ADDRESS''),
								CITY	= (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_CITY''),
								STATE	= (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_STATE''),
								ZIP		= (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_ZIP'')'

			EXECUTE(@Query)
		END
		ELSE
		BEGIN
			SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM00300
				SET		PM00300.ADDRESS1	= DATA.ADDRESS,
						PM00300.ADDRESS2	= '''',
						PM00300.ADDRESS3	= '''',
						PM00300.CITY		= DATA.CITY,
						PM00300.STATE		= DATA.STATE,
						PM00300.ZIPCODE		= DATA.ZIP,
						PM00300.VNDCNTCT	= DATA.VENDNAME
				FROM	(
						SELECT	ADDRESS = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_ADDRESS''),
								CITY	= (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_CITY''),
								STATE	= (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_STATE''),
								ZIP		= (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_ZIP''),
								VND.VENDNAME,
								ADR.DEX_ROW_ID
						FROM	' + RTRIM(@Company) + '.dbo.PM00300 ADR
								INNER JOIN ' + RTRIM(@Company) + '.dbo.PM00200 VND ON ADR.VENDORID = VND.VENDORID AND ADR.ADRSCODE = VND.VADCDTRO
						WHERE	ADR.VENDORID = ''' + RTRIM(@VendorId) + ''' 
						) DATA
				WHERE	PM00300.DEX_ROW_ID = DATA.DEX_ROW_ID
						AND PM00300.ADDRESS1 <> DATA.ADDRESS'
			
			EXECUTE(@Query)
		END
		
		-- INTERNET OPTIONS TABLE
		SET @Query = N'SELECT DEX_ROW_ID FROM ' + @Company + '.dbo.SY01200 WHERE Master_ID = ''' + @VendorId + ''' AND ADRSCODE = ''REMIT'''
		
		INSERT INTO @tblEmails
		EXECUTE(@Query)

		IF (SELECT COUNT(*) FROM @tblEmails) > 0
			SET @Query = N'UPDATE ' + @Company + '.dbo.SY01200 SET EmailToAddress = ''' + (SELECT ParValue FROM ##tmpParameters WHERE Parameter = 'RAISTONE_EMAIL') + ''', EmailCcAddress = '''', EmailBccAddress = '''' WHERE DEX_ROW_ID = ' + CAST((SELECT RowId FROM @tblEmails) AS Varchar)
		ELSE
			SET @Query = N'INSERT INTO ' + @Company + '.dbo.SY01200 (Master_Type, Master_ID, ADRSCODE, EmailToAddress, EmailCcAddress, EmailBccAddress, INETINFO) VALUES 
			(''VEN'',''' + @VendorId + ''',''REMIT'',''' + (SELECT ParValue FROM ##tmpParameters WHERE Parameter = 'RAISTONE_EMAIL') + ''','''','''','''')'
		
		EXECUTE(@Query)

		-- ACH/EFT VENDOR SETUP TABLE
		SET @Query = N'IF NOT EXISTS(SELECT VendorId FROM ' + RTRIM(@Company) + '.dbo.SY06000 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' AND ADRSCODE = ''REMIT'')
				BEGIN
					INSERT INTO ' + RTRIM(@Company) + '.dbo.SY06000
					(SERIES,
					CustomerVendor_Id,
					VENDORID,
					ADRSCODE,
					BANKNAME,
					EFTUseMasterID,
					EFTBankType,
					EFTBankAcct,
					EFTTransitRoutingNo,
					EFTPrenoteDate,
					EFTTransferMethod,
					EFTAccountType,
					CURNCYID)
					SELECT	4, VENDORID, VENDORID, ''REMIT'',
							BANK_NAME = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_BANK''), 1, 31,
							BANKACCT = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_BNK_ACCOUNT''),
							BANKROUTING = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_ACH_ACCOUNT''),
							CAST(DATEADD(dd, -5, ''' + CONVERT(Char(10), ISNULL(@EffDate, GETDATE()), 101) + ''') AS Date) AS PrenoteDate, 1, 1, ''USD2''
					FROM ' + RTRIM(@Company) + '.dbo.PM00200 VND
					WHERE VENDORID = ''' + RTRIM(@VendorId) + '''
				END
				ELSE
				BEGIN
					UPDATE ' + RTRIM(@Company) + '.dbo.SY06000
					SET SERIES = 4,
						CustomerVendor_Id = DATA.VENDORID,
						VENDORID = DATA.VENDORID,
						BANKNAME = DATA.BANK_NAME,
						EFTUseMasterID = 1,
						EFTBankType = 31,
						EFTBankAcct = DATA.BANKACCT,
						EFTTransitRoutingNo = DATA.BANKROUTING,
						EFTPrenoteDate = DATA.PrenoteDate,
						EFTTransferMethod = 1,
						EFTAccountType = 1,
						CURNCYID = ''USD2'',
						INACTIVE = 0
					FROM	(
							SELECT	VENDORID, ''REMIT'' AS ADRSCODE,
									BANK_NAME = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_BANK''), 
									BANKACCT = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_BNK_ACCOUNT''),
									BANKROUTING = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_ACH_ACCOUNT''),
									CAST(DATEADD(dd, -5, ''' + CONVERT(Char(10), @EffDate, 101) + ''') AS Date) AS PrenoteDate  
							FROM ' + RTRIM(@Company) + '.dbo.PM00200 VND
							WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' 
							) DATA
					WHERE	SY06000.VENDORID = DATA.VENDORID
							AND SY06000.ADRSCODE = ''REMIT'';
					PRINT ''UPDATE''
				END'
		
		EXECUTE(@Query)

		SET @Query = N'IF EXISTS(SELECT VendorId FROM ' + RTRIM(@Company) + '.dbo.SY06000 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' AND ADRSCODE <> ''REMIT'')
						UPDATE ' + RTRIM(@Company) + '.dbo.SY06000 SET INACTIVE = 1 WHERE ADRSCODE <> ''REMIT'' AND VENDORID = ''' + RTRIM(@VendorId) + ''''
		
		EXECUTE(@Query)

		-- OPEN TRANSACTIONS TABLE
		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM20000
			SET		DISTKNAM = 0,
					DISCAMNT = 0,
					DSCDLRAM = 0,
					DISCDATE = ''01/01/1900'',
					DUEDATE = DATEADD(dd, 25, DOCDATE),
					DISAMTAV = 0,
					PYMTRMID = ''' + @PYMTRMID + ''',
					DISAVTKN = 0,
					PRCTDISC = 0,
					VADCDTRO = ''REMIT''
			WHERE	VENDORID = ''' + RTRIM(@VendorId) + ''''
		
		EXECUTE(@Query)

		-- WORK TRANSACTIONS TABLE
		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM10000
			SET		DISTKNAM = 0,
					DSCDLRAM = 0,
					DISCDATE = ''01/01/1900'',
					DUEDATE = DATEADD(dd, 30, DOCDATE),
					DISAMTAV = 0,
					PYMTRMID = ''' + @PYMTRMID + ''',
					PRCTDISC = 0,
					VADCDTRO = ''REMIT''
			WHERE	VENDORID = ''' + RTRIM(@VendorId) + ''''

		EXECUTE(@Query)

		DROP TABLE ##tmpParameters

		EXECUTE USP_RapidPay_FileBound_DocCounter @ProjectId, @Company, @VendorId, @Reversal

		UPDATE	GPVendorMaster 
		SET		RP_Active = 1, 
				RapidPay = 1,
				RP_EffectiveDate = GETDATE()
		WHERE	Company = @Company 
				AND VendorId = @VendorId

		EXECUTE USP_RapidPay_InsertBankInformation @Company, @VendorId

		RETURN 1
	END
END
ELSE
BEGIN
	IF @Reversal > 0
	BEGIN
		DECLARE @ADRSCODE	Varchar(20)
		DECLARE @tblEFT		Table (Bank Varchar(50))
	
		DELETE @tblVndAddr

		INSERT INTO @tblEFT
		SELECT	TOP 1 RTRIM(BANKNAME)
		FROM	GPCustom.dbo.RapidPay_VendorAch 
		WHERE	COMPANY = @Company
				AND VENDORID = @VendorId
				AND ADRSCODE = 'MAIN'
				AND BANKNAME <> ''
		ORDER BY EffectiveDate DESC

		SET @Query = N'DELETE ' + RTRIM(@Company) + '.dbo.PM00300 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' AND ADRSCODE = ''REMIT'''
		EXECUTE(@Query)

		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM00300
			SET		PM00300.VNDCNTCT	= ''OBSOLETE'',
					PM00300.ADDRESS1	= '''',
					PM00300.ADDRESS2	= '''',
					PM00300.ADDRESS3	= '''',
					PM00300.CITY		= '''',
					PM00300.STATE		= '''',
					PM00300.ZIPCODE		= ''''
			WHERE	PM00300.VENDORID = ''' + RTRIM(@VendorId) + ''' 
					AND PM00300.ADRSCODE = ''REMIT'''
	
		EXECUTE(@Query)

		SET @Query = N'SELECT TOP 1 ADRSCODE FROM GPCustom.dbo.RapidPay_VendorAddress 
					WHERE	COMPANY = ''' + RTRIM(@Company) + '''
							AND VENDORID = ''' + RTRIM(@VendorId) + ''' 
					ORDER BY EffectiveDate DESC'
	
		INSERT INTO @tblVndAddr
		EXECUTE(@Query)
	
		SET @ADRSCODE = (SELECT TOP 1 RTRIM(AddressCode) FROM @tblVndAddr)

		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM00200 
		SET VNDCHKNM = VENDNAME, 
			PYMNTPRI = ''CHK'', 
			PYMTRMID = ''Net 28 Days'', 
			VADCDTRO = ''MAIN'',
			VADDCDPR = ''MAIN'',
			VNDCLSID = ''' + IIF(@VNDCLSID IS Null, 'TRDR', @VNDCLSID) + ''' 
		WHERE VENDORID = ''' + RTRIM(@VendorId) + ''''

		EXECUTE(@Query)

		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM00200
		SET	PM00200.VNDCNTCT = PM00300.VNDCNTCT,
			PM00200.ADDRESS1 = PM00300.ADDRESS1,
			PM00200.ADDRESS2 = PM00300.ADDRESS2,
			PM00200.ADDRESS3 = PM00300.ADDRESS3,
			PM00200.CITY = PM00300.CITY,
			PM00200.STATE = PM00300.STATE,
			PM00200.ZIPCODE = PM00300.ZIPCODE,
			PM00200.COUNTRY = PM00300.COUNTRY,
			PM00200.PHNUMBR1 = PM00300.PHNUMBR1,
			PM00200.PHNUMBR2 = PM00300.PHNUMBR2,
			PM00200.FAXNUMBR = PM00300.FAXNUMBR
		FROM ' + RTRIM(@Company) + '.dbo.PM00300
		WHERE PM00200.VENDORID = PM00300.VENDORID
				AND PM00300.VENDORID = ''' + @VendorId + '''
				AND PM00300.ADRSCODE = ''MAIN'''

		EXECUTE(@Query)

		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.SY06000
			SET		SY06000.BANKNAME			= '''',
					SY06000.EFTBankAcct			= '''',
					SY06000.EFTTransitRoutingNo	= '''',
					SY06000.EFTPrenoteDate		= ''01/01/1900'',
					SY06000.INACTIVE			= 1
			WHERE	SY06000.VENDORID = ''' + RTRIM(@VendorId) + ''' 
					AND SY06000.ADRSCODE = ''REMIT'';
			DELETE ' + RTRIM(@Company) + '.dbo.PM00300 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' AND ADRSCODE = ''REMIT'''
		EXECUTE(@Query)

		SET @Query = N'DELETE ' + RTRIM(@Company) + '.dbo.SY06000 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''''
		EXECUTE(@Query)

		UPDATE	GPCustom.dbo.GPVendorMaster 
		SET		RP_EffectiveDate = GETDATE(),
				RapidPay = 0,
				RP_Active = 0
		WHERE	Company = @Company 
				AND VendorId = @VendorId

		IF @@ERROR = 0
			RETURN 1
		ELSE
			RETURN 0
	END
END
