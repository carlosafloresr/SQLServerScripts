USE [GPCustom]
GO

/****** Object:  Table [dbo].[RapidPay_VendorAch]    Script Date: 4/5/2022 11:55:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RapidPay_VendorAch](
	[RecordId] [int] IDENTITY(1,1) NOT NULL,
	[COMPANY] [varchar](5) NOT NULL,
	[VNDCHKNM] [varchar](65) NOT NULL,
	[PYMTRMID] [varchar](30) NOT NULL,
	[VND_REMITADRSCODE] [varchar](30) NOT NULL,
	[VND_MAINADRSCODE] [varchar](30) NOT NULL,
	[SERIES] [smallint] NULL,
	[CustomerVendor_ID] [char](15) NULL,
	[ADRSCODE] [char](15) NULL,
	[VENDORID] [char](15) NULL,
	[CUSTNMBR] [char](15) NULL,
	[EFTUseMasterID] [smallint] NULL,
	[EFTBankType] [smallint] NULL,
	[FRGNBANK] [tinyint] NULL,
	[INACTIVE] [tinyint] NULL,
	[BANKNAME] [char](31) NULL,
	[EFTBankAcct] [char](35) NULL,
	[EFTBankBranch] [char](15) NULL,
	[GIROPostType] [smallint] NULL,
	[EFTBankCode] [char](15) NULL,
	[EFTBankBranchCode] [char](5) NULL,
	[EFTBankCheckDigit] [char](3) NULL,
	[BSROLLNO] [char](31) NULL,
	[IntlBankAcctNum] [char](35) NULL,
	[SWIFTADDR] [char](11) NULL,
	[CustVendCountryCode] [char](3) NULL,
	[DeliveryCountryCode] [char](3) NULL,
	[BNKCTRCD] [char](3) NULL,
	[CBANKCD] [char](9) NULL,
	[ADDRESS1] [char](61) NULL,
	[ADDRESS2] [char](61) NULL,
	[ADDRESS3] [char](61) NULL,
	[ADDRESS4] [char](61) NULL,
	[RegCode1] [char](31) NULL,
	[RegCode2] [char](31) NULL,
	[BankInfo7] [smallint] NULL,
	[EFTTransitRoutingNo] [char](11) NULL,
	[CURNCYID] [char](15) NULL,
	[EFTTransferMethod] [smallint] NULL,
	[EFTAccountType] [smallint] NULL,
	[EFTPrenoteDate] [datetime] NULL,
	[EFTTerminationDate] [datetime] NULL,
	[DEX_ROW_ID] [int] NULL,
	[SAVEDON] [datetime] NOT NULL,
	[EffectiveDate] [date] NOT NULL,
 CONSTRAINT [PK_RapidPay_VendorAch_Primary] PRIMARY KEY CLUSTERED 
(
	[RecordId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RapidPay_VendorAch] ADD  CONSTRAINT [DF_RapidPay_VendorAch_SAVEDON]  DEFAULT (getdate()) FOR [SAVEDON]
GO

ALTER TABLE [dbo].[RapidPay_VendorAch] ADD  CONSTRAINT [DF_RapidPay_VendorAch_EffectiveDate]  DEFAULT (getdate()) FOR [EffectiveDate]
GO

CREATE TABLE [dbo].[RapidPay_VendorAddress](
	[RECORDID] [int] IDENTITY(1,1) NOT NULL,
	[COMPANY] [varchar](5) NOT NULL,
	[VENDORID] [char](15) NOT NULL,
	[ADRSCODE] [char](15) NOT NULL,
	[VNDCNTCT] [char](61) NOT NULL,
	[ADDRESS1] [char](61) NOT NULL,
	[ADDRESS2] [char](61) NOT NULL,
	[ADDRESS3] [char](61) NOT NULL,
	[CITY] [char](35) NOT NULL,
	[STATE] [char](29) NOT NULL,
	[ZIPCODE] [char](11) NOT NULL,
	[COUNTRY] [char](61) NOT NULL,
	[UPSZONE] [char](3) NOT NULL,
	[PHNUMBR1] [char](21) NOT NULL,
	[PHNUMBR2] [char](21) NOT NULL,
	[PHONE3] [char](21) NOT NULL,
	[FAXNUMBR] [char](21) NOT NULL,
	[SHIPMTHD] [char](15) NOT NULL,
	[TAXSCHID] [char](15) NOT NULL,
	[EmailPOs] [tinyint] NOT NULL,
	[POEmailRecipient] [char](81) NOT NULL,
	[EmailPOFormat] [smallint] NOT NULL,
	[FaxPOs] [tinyint] NOT NULL,
	[POFaxNumber] [char](21) NOT NULL,
	[FaxPOFormat] [smallint] NOT NULL,
	[CCode] [char](7) NOT NULL,
	[DECLID] [char](15) NOT NULL,
	[DEX_ROW_TS] [datetime] NOT NULL,
	[DEX_ROW_ID] [int] NOT NULL,
	[EffectiveDate] [date] NOT NULL,
	[SavedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_RapidPay_VendorAddress_Primary] PRIMARY KEY CLUSTERED 
(
	[RECORDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RapidPay_VendorAddress] ADD  CONSTRAINT [DF_RapidPay_VendorAddress_EffectiveDate]  DEFAULT (getdate()) FOR [EffectiveDate]
GO

ALTER TABLE [dbo].[RapidPay_VendorAddress] ADD  CONSTRAINT [DF_RapidPay_VendorAddress_SavedOn]  DEFAULT (getdate()) FOR [SavedOn]
GO

/*
EXECUTE USP_RapidPay_FileBound_DocCounter @ProjectId=180, @Company='GLSO', @VendorId='1038', @Cancellation=0, @JustValidate=1
EXECUTE USP_RapidPay_FileBound_DocCounter @ProjectId=186, @Company='HMIS', @VendorId='1034', @Cancellation=0, @JustValidate=1
*/
CREATE PROCEDURE [dbo].[USP_RapidPay_FileBound_DocCounter] 
		@ProjectId		Int,
		@Company		Varchar(5),
		@VendorId		Varchar(15),
		@Cancellation	Bit = 0,
		@JustValidate	Bit = 0
WITH EXECUTE AS OWNER 
AS
SET NOCOUNT ON

DECLARE @URL			Varchar(150) = 'https://imagews.imcc.com/imaging-bs/v4/getImageCount',
		@Object			Int,
		@Counter		Int = 0,
		@LastSegment	Varchar(1000),
		@ResponseText	Varchar(8000),
		@CompanyAlias	Varchar(10) = (SELECT CompanyAlias FROM View_CompaniesAndAgents WHERE CompanyId = @Company),
		@Body			Varchar(8000),
		@DocType		Varchar(40) = IIF(@Cancellation = 0, 'ENROLLMENT FORM', 'CANCELATION FORM')

SET @Body = N'{
   "applicationId": ' + CAST(@ProjectId AS Varchar) + ',
   "OperatingCompany": "' + @CompanyAlias + '",
   "VendorID": "' + @VendorId + '",
   "documentCategory": "' + @DocType + '"
}'
PRINT @Body
EXECUTE sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
EXECUTE sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false'
EXECUTE sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
EXECUTE sp_OAMethod @Object, 'send', null, @body
EXECUTE sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT

IF RTRIM(@ResponseText) <> ''
BEGIN
	IF CHARINDEX('false',(SELECT @ResponseText)) = 0
	BEGIN
		DECLARE @JsonMain Varchar(MAX) = (SELECT @ResponseText)
		SELECT @LastSegment = Value FROM OPENJSON(@JsonMain) WHERE [Key] = 'imageDetails'
	
		DECLARE @JsonDetail Varchar(MAX) = (SELECT @LastSegment)
		SELECT @Counter = Value FROM OPENJSON(@JsonDetail)
	END
END

EXECUTE sp_OADestroy @Object

IF @JustValidate = 0
	UPDATE	GPVendorMaster 
	SET		RP_Documents = IIF(@Counter > 0, 1, 0)
	WHERE	Company = @Company
			AND VendorId = @VendorId
ELSE
	SELECT	@Counter AS FileBoundValid

GO

/*
EXECUTE USP_RapidPay_FileBound_Validation 'GLSO', '1038'
*/
CREATE PROCEDURE [dbo].[USP_RapidPay_FileBound_Validation]
		@Company		Varchar(5),
		@VendorId		Varchar(15)
AS
SET NOCOUNT ON

DECLARE @ReturnValue	Bit = 0
		
DECLARE @tblFileBound	Table (DocsCount Int)

INSERT INTO @tblFileBound
EXECUTE USP_RapidPay_FileBound_DocCounter 186, @Company, @VendorId

SELECT @ReturnValue = DocsCount FROM @tblFileBound

SELECT	ISNULL(@ReturnValue, 0) AS FileBoundValid
GO

/*
EXECUTE USP_RapidPay_VendorAch 'GLSO', '7903', 1
*/
CREATE PROCEDURE [dbo].[USP_RapidPay_VendorAch]
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
		@ProjectId		Int = 186

DECLARE @tblVndAddr		Table (AddressCode Varchar(30))

SET @EffDate	= (SELECT RP_EffectiveDate FROM GPCustom.dbo.GPVendorMaster WHERE Company = @Company AND VendorId = @VendorId)
SET @RecId_ACH	= (SELECT MIN(RecordId) FROM RapidPay_VendorAch WHERE Company = @Company AND VendorId = @VendorId AND EffectiveDate = @EffDate)
SET @RecId_ADR	= (SELECT MIN(RecordId) FROM RapidPay_VendorAddress WHERE Company = @Company AND VendorId = @VendorId AND EffectiveDate = @EffDate)
SET @Query		= N'SELECT ADRSCODE FROM ' + @Company + '.dbo.PM00300 WHERE ADRSCODE = ''REMIT'' AND VENDORID = ''' + @VendorId + ''''

INSERT INTO @tblVndAddr
EXECUTE(@Query)

SET @Query	= N'SELECT ''' + RTRIM(@Company) + ''' AS COMPANY
		,RTRIM(VND.VNDCHKNM) AS VNDCHKNM
		,RTRIM(VND.PYMTRMID) AS PYMTRMID
		,RTRIM(VND.VADCDTRO) AS VND_REMITADRSCODE
		,RTRIM(VND.VADDCDPR) AS VND_MAINADRSCODE
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
		,''' + CONVERT(Char(10), @EffDate, 101) + ''' 
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

		-- VENDOR MASTER TABLE
		SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.PM00200 
			SET PYMNTPRI = ''EFT'', 
				VADCDTRO = ''REMIT'', 
				VADDCDPR = ''REMIT'', 
				VNDCHKNM = ''' + @VNDCHKNM + ''', 
				PYMTRMID = ''' + @PYMTRMID + ''',
				VNDCNTCT = VENDNAME,
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
				SELECT	4, VENDORID, VENDORID, VADCDTRO,
						BANK_NAME = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_BANK''), 1, 31,
						BANKACCT = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_BNK_ACCOUNT''),
						BANKROUTING = (SELECT ParValue FROM ##tmpParameters WHERE Parameter = ''RAISTONE_ACH_ACCOUNT''),
						CAST(DATEADD(dd, -5, ''' + CONVERT(Char(10), @EffDate, 101) + ''') AS Date) AS PrenoteDate, 1, 1, ''USD2''
				FROM ' + RTRIM(@Company) + '.dbo.PM00200 VND
				WHERE VENDORID = ''' + RTRIM(@VendorId) + ''';
				UPDATE ' + RTRIM(@Company) + '.dbo.SY06000 SET INACTIVE = 1 WHERE ADRSCODE <> ''REMIT'' AND VENDORID = ''' + RTRIM(@VendorId) + '''
				END'
		
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
				RapidPay = 1 
		WHERE	Company = @Company 
				AND VendorId = @VendorId

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
			VADDCDPR = ''MAIN''
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

		UPDATE	RapidPay_AddressDelete
		SET		Company		= @Company,
				VendorId	= @VendorId

		IF @@ERROR = 0
			RETURN 1
		ELSE
			RETURN 0
	END
END
GO

/*
EXECUTE USP_RapidPay_VendorAddress 'GLSO', '1173'
*/
CREATE PROCEDURE [dbo].[USP_RapidPay_VendorAddress]
		@Company		Varchar(5),
		@VendorId		Varchar(15)
AS
DECLARE @Query			Varchar(MAX),
		@EffectiveDate	Date = (SELECT RP_EffectiveDate FROM GPVendorMaster WHERE Company = @Company AND VendorId = @VendorId)

SET @Query = N'SELECT ''' + RTRIM(@Company) + ''' AS COMPANY,
		[VENDORID]
		,[ADRSCODE]
		,[VNDCNTCT]
		,[ADDRESS1]
		,[ADDRESS2]
		,[ADDRESS3]
		,[CITY]
		,[STATE]
		,[ZIPCODE]
		,[COUNTRY]
		,[UPSZONE]
		,[PHNUMBR1]
		,[PHNUMBR2]
		,[PHONE3]
		,[FAXNUMBR]
		,[SHIPMTHD]
		,[TAXSCHID]
		,[EmailPOs]
		,[POEmailRecipient]
		,[EmailPOFormat]
		,[FaxPOs]
		,[POFaxNumber]
		,[FaxPOFormat]
		,[CCode]
		,[DECLID]
		,[DEX_ROW_TS]
		,[DEX_ROW_ID]
		,''' + CONVERT(Char(10), @EffectiveDate, 101) + ''' 
FROM	' + RTRIM(@Company) + '.dbo.PM00300
WHERE	VENDORID = ''' + RTRIM(@VendorId) + ''' 
		AND ADRSCODE IN (SELECT VADCDTRO FROM ' + RTRIM(@Company) + '.dbo.PM00200 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''')'

IF NOT EXISTS(SELECT VendorId FROM RapidPay_VendorAddress WHERE Company = @Company AND VendorId = @VendorId AND EffectiveDate = @EffectiveDate)
BEGIN
	INSERT INTO [dbo].[RapidPay_VendorAddress]
			   ([COMPANY]
			   ,[VENDORID]
			   ,[ADRSCODE]
			   ,[VNDCNTCT]
			   ,[ADDRESS1]
			   ,[ADDRESS2]
			   ,[ADDRESS3]
			   ,[CITY]
			   ,[STATE]
			   ,[ZIPCODE]
			   ,[COUNTRY]
			   ,[UPSZONE]
			   ,[PHNUMBR1]
			   ,[PHNUMBR2]
			   ,[PHONE3]
			   ,[FAXNUMBR]
			   ,[SHIPMTHD]
			   ,[TAXSCHID]
			   ,[EmailPOs]
			   ,[POEmailRecipient]
			   ,[EmailPOFormat]
			   ,[FaxPOs]
			   ,[POFaxNumber]
			   ,[FaxPOFormat]
			   ,[CCode]
			   ,[DECLID]
			   ,[DEX_ROW_TS]
			   ,[DEX_ROW_ID]
			   ,[EffectiveDate])
	EXECUTE(@Query)
END
GO

/*
EXECUTE USP_GPVendorMaster 'GLSO', '1150', 1, Null, Null, 0, 0, 0, 'cflores', 0, '03/22/2022', 1
*/
ALTER PROCEDURE [dbo].[USP_GPVendorMaster]
		@Company				Varchar(5),
		@VendorId				Varchar(15),
		@SWSVendor				Bit,
		@SWSAlias				Varchar(6) = Null,
		@SWSBillTo				Varchar(25) = Null,
		@AlternativeInvoice		Bit = 0,
		@Override				Bit = 0,
		@ExcludeAutoHold		Bit = 0,
		@UserId					Varchar(25) = Null,
		@RapidPay				Bit = 0,
		@RP_EffectiveDate		Date = Null,
		@Restore				Int = 0
AS
SET NOCOUNT ON

DECLARE	@Query					Varchar(MAX),
		@RecordChanged			Bit = 0,
		@RPDocuments			Int = 0

DECLARE @tblVendors				Table (
		Company					Varchar(5) NOT NULL,
		VendorId				Char(15) NOT NULL,
		VendName				Varchar(30) NULL,
		Address1				Varchar(30) NULL,
		Address2				Varchar(30) NULL,
		City					Varchar(35) NULL,
		State					Varchar(29) NULL,
		ZipCode					Varchar(11) NULL,
		Status					Char(1) NOT NULL,
		Phone					Varchar(12) NULL,
		Email					Varchar(40) NULL,
		VendClass				Varchar(10) NOT NULL,
		PYMNTPRI				Varchar(30),
		Changed					Bit NOT NULL,
		ChangedOn				Datetime NOT NULL)

SET @Query = N'	SELECT DISTINCT ''' + @Company + ''',
			RTRIM(P2.VendorId) AS VendorId,
			RTRIM(LEFT(VendName, 30)) AS VendName,
			RTRIM(LEFT(P3.Address1, 30)) as Address1,
			RTRIM(LEFT(P3.Address2, 30)) as Address2,
			RTRIM(P3.City) AS City,
			RTRIM(P3.State) AS State,
			RTRIM(P3.ZipCode) AS ZipCode,
			CASE WHEN VendStts = 1 THEN ''A'' ELSE ''I'' END AS Status,
			CASE WHEN P3.PHNUMBR1 IS Null THEN ''''
					WHEN P3.PHNUMBR1 = '''' THEN ''''
					WHEN LEFT(P3.PHNUMBR1, 6) = ''000000'' THEN ''''
					ELSE SUBSTRING(REPLACE(REPLACE(REPLACE(P3.PHNUMBR1, ''-'', ''''), '')'', ''''), ''('', ''''), 1, 3) + ''-'' + SUBSTRING(REPLACE(REPLACE(REPLACE(P3.PHNUMBR1, ''-'', ''''), '')'', ''''), ''('', ''''), 4, 3) + ''-'' + SUBSTRING(REPLACE(REPLACE(REPLACE(P3.PHNUMBR1, ''-'', ''''), '')'', ''''), ''('', ''''), 7, 4)
			END AS Phone,
			'''' AS Email,
			RTRIM(P2.VNDCLSID) AS VendClass,
			RTRIM(PYMNTPRI) AS PYMNTPRI,
			1 AS Changed,
			GETDATE() AS ChangedOn
	FROM	' + @Company + '.dbo.PM00200 P2
			LEFT JOIN ' + @Company + '.dbo.PM00300 P3 ON P2.VendorId = P3.VendorId AND P3.AdrsCode = ''MAIN''
			LEFT JOIN ' + @Company + '.dbo.SY04906 SY ON SY.EmailRecipientTypeTo = 1 AND P2.VendorId = SY.EmailCardid 
	WHERE	P2.VendorId = ''' + RTRIM(@VendorId) + ''''

INSERT INTO @tblVendors
EXECUTE(@Query)	

IF EXISTS(SELECT VendorId FROM GPVendorMaster WHERE Company = @Company AND VendorId = @VendorId)
BEGIN
	SET @RecordChanged = IIF((SELECT RapidPay FROM GPVendorMaster WHERE Company = @Company AND VendorId = @VendorId) <> @RapidPay, 1, 0)

	UPDATE	GPVendorMaster
	SET		GPVendorMaster.VendName				= DATA.VendName,
			GPVendorMaster.Address1				= DATA.Address1,
			GPVendorMaster.Address2				= DATA.Address2,
			GPVendorMaster.City					= DATA.City,
			GPVendorMaster.State				= DATA.State,
			GPVendorMaster.ZipCode				= DATA.ZipCode,
			GPVendorMaster.[Status]				= CASE WHEN GPVendorMaster.SWSVendor = 1 AND @SWSVendor = 0 THEN 'I' ELSE DATA.[Status] END,
			GPVendorMaster.Phone				= DATA.Phone,
			GPVendorMaster.Email				= DATA.Email,
			GPVendorMaster.Changed				= 1,
			GPVendorMaster.SWSVendor			= @SWSVendor,
			GPVendorMaster.SWSVendorId			= @SWSAlias,
			GPVendorMaster.SWSBillTo			= @SWSBillTo,
			GPVendorMaster.AlternativeInvoice	= @AlternativeInvoice,
			GPVendorMaster.Override				= @Override,
			GPVendorMaster.ExcludeAutoHold		= @ExcludeAutoHold,
			GPVendorMaster.RapidPay				= @RapidPay,
			GPVendorMaster.RP_EffectiveDate		= @RP_EffectiveDate,
			GPVendorMaster.PYMNTPRI				= DATA.PYMNTPRI,
			GPVendorMaster.ChangedOn			= GETDATE(),
			GPVendorMaster.UserId				= @UserId
	FROM	@tblVendors DATA
	WHERE	GPVendorMaster.Company = DATA.Company
			AND GPVendorMaster.VendorId = DATA.VendorId
END
ELSE
BEGIN
	SET @RecordChanged = 1

	INSERT INTO GPVendorMaster
			(Company,
			VendorId,
			VendName,
			Address1,
			Address2,
			City,
			State,
			ZipCode,
			Status,
			Phone,
			Email,
			VendClass,
			PYMNTPRI,
			SWSVendor,
			SWSVendorId,
			SWSBillTo,
			AlternativeInvoice,
			Override,
			ExcludeAutoHold,
			UserId,
			RapidPay,
			RP_EffectiveDate,
			Changed,
			ChangedOn)
	SELECT	Company,
			VendorId,
			VendName,
			Address1,
			Address2,
			City,
			State,
			ZipCode,
			Status,
			Phone,
			Email,
			VendClass,
			PYMNTPRI,
			@SWSVendor,
			@SWSAlias,
			@SWSBillTo,
			@AlternativeInvoice,
			@Override,
			@ExcludeAutoHold,
			@UserId,
			@RapidPay,
			@RP_EffectiveDate,
			1,
			ChangedOn 
	FROM	@tblVendors
END

IF @Restore > 0
BEGIN
	SET @Query = N'DELETE ' + RTRIM(@Company) + '.dbo.PM00300 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' AND ADRSCODE LIKE ''%REMIT%'''
	EXECUTE(@Query)
END
GO

/*
EXECUTE USP_GPVendorMaster_Reader 'GLSO', '1040'
*/
ALTER PROCEDURE [dbo].[USP_GPVendorMaster_Reader]
		@Company	Varchar(5),
		@VendorId	Varchar(20)
AS
DECLARE	@CompanyPar	Bit = ISNULL((SELECT ParBit FROM Companies_Parameters WHERE CompanyId = @Company AND ParameterCode = 'AlternativeInvoice'), 0)

EXECUTE USP_RapidPay_FileBound_DocCounter 180, @Company, @VendorId;

SELECT	SWSVendor, 
		SWSVendorId, 
		SWSBillTo,
		CASE WHEN @CompanyPar = 1 THEN AlternativeInvoice ELSE Null END AS AlternativeInvoice,
		Override,
		ExcludeAutoHold,
		RapidPay,
		RP_EffectiveDate,
		RP_Active,
		RP_Documents AS FileBoundValid
FROM	GPVendorMaster 
WHERE	Company = @Company
		AND VendorId = @VendorId