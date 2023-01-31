USE [GPCustom]
GO

DECLARE @Company		Varchar(5) = 'GLSO',
		@VendorId		Varchar(15) = '8031',
		@Reversal		Smallint = 0

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

SELECT	ParameterCode AS Parameter,
		VarC AS ParValue
INTO	##tmpParameters
FROM	GPCustom.dbo.Parameters
WHERE	ParameterCode LIKE 'RAISTONE_%'

SET @Query = N'IF NOT EXISTS(SELECT VendorId FROM ' + RTRIM(@Company) + '.dbo.SY06000 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' AND ADRSCODE = ''REMIT'')
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
							CAST(DATEADD(dd, -5, ''' + CONVERT(Char(10), @EffDate, 101) + ''') AS Date) AS PrenoteDate, 1, 1, ''USD2''
					FROM ' + RTRIM(@Company) + '.dbo.PM00200 VND
					WHERE VENDORID = ''' + RTRIM(@VendorId) + '''
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
							SELECT	VENDORID, VADCDTRO,
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

		DROP TABLE ##tmpParameters

		SET @Query = 'SELECT VendorId FROM ' + RTRIM(@Company) + '.dbo.SY06000 WHERE VENDORID = ''' + RTRIM(@VendorId) + ''' AND ADRSCODE = ''REMIT'''

		EXECUTE(@Query)

		-- SELECT * FROM GLSO.dbo.SY06000 WHERE VENDORID = '8186' 

		--DELETE GLSO.dbo.SY06000 WHERE VENDORID = '8106' 


/*
SELECT	*
FROM	SY06000
WHERE	VENDORID IN ('8059','8258','8126')
		AND ADRSCODE = 'REMIT'


UPDATE	GLSO.dbo.SY06000
SET		INACTIVE = 1
WHERE	VENDORID IN ('1151')
		AND ADRSCODE = 'MAIN'
*/