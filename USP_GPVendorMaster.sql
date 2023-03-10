USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GPVendorMaster]    Script Date: 11/16/2022 1:23:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
		@Restore				Int = 0,
		@SWSInactive			Bit = 0
AS
/*
========================================================================================================================
VERSION		MODIFIED	USER				MODIFICATION
========================================================================================================================
1.2			08/22/2022	Carlos A. Flores	New parameter added for RMIS - SWS Inactive
1.3			11/16/2022	Carlos A. Flores	Field lenght modification for VendName, Address1 and Address2
========================================================================================================================
*/
SET NOCOUNT ON

DECLARE	@Query					Varchar(MAX),
		@RecordChanged			Bit = 0,
		@RPDocuments			Int = 0

DECLARE @tblVendors				Table (
		Company					Varchar(5) NOT NULL,
		VendorId				Char(15) NOT NULL,
		VendName				Varchar(65) NULL,
		Address1				Varchar(61) NULL,
		Address2				Varchar(61) NULL,
		City					Varchar(35) NULL,
		State					Varchar(29) NULL,
		ZipCode					Varchar(11) NULL,
		Status					Char(1) NOT NULL,
		Phone					Varchar(21) NULL,
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

	IF @RecordChanged = 1 AND @RapidPay = 0
	BEGIN
		DECLARE @tblVerify Table (DocCounter Int)

		INSERT INTO @tblVerify
		EXECUTE USP_RapidPay_FileBound_DocCounter 180, @Company, @VendorId, 1, 1

		IF (SELECT DocCounter FROM @tblVerify) = 0
		BEGIN
			SET @RapidPay = 1
			SET @RecordChanged = 0
		END
	END

	INSERT INTO [dbo].[GPVendorMaster_Log]
           ([Company]
           ,[VendorId]
           ,[VendName]
           ,[Address1]
           ,[Address2]
           ,[City]
           ,[State]
           ,[ZipCode]
           ,[Status]
           ,[Phone]
           ,[Email]
           ,[VendClass]
           ,[PYMNTPRI]
           ,[SWSVendor]
           ,[SWSVendorId]
           ,[SWSBillTo]
           ,[AlternativeInvoice]
           ,[Changed]
           ,[ChangedOn]
           ,[PierPassType]
           ,[Override]
           ,[ExcludeAutoHold]
           ,[UserId]
           ,[RapidPay]
           ,[RP_EffectiveDate]
           ,[RP_Active]
           ,[RP_Documents]
           ,[SWSInactive])
	SELECT	[Company]
			,[VendorId]
			,[VendName]
			,[Address1]
			,[Address2]
			,[City]
			,[State]
			,[ZipCode]
			,[Status]
			,[Phone]
			,[Email]
			,[VendClass]
			,[PYMNTPRI]
			,[SWSVendor]
			,[SWSVendorId]
			,[SWSBillTo]
			,[AlternativeInvoice]
			,[Changed]
			,[ChangedOn]
			,[PierPassType]
			,[Override]
			,[ExcludeAutoHold]
			,[UserId]
			,[RapidPay]
			,[RP_EffectiveDate]
			,[RP_Active]
			,[RP_Documents]
			,[SWSInactive]
	FROM	GPVendorMaster
	WHERE	Company = @Company
			AND VendorId = @VendorId

	UPDATE	GPVendorMaster
	SET		GPVendorMaster.VendName				= DATA.VendName,
			GPVendorMaster.Address1				= DATA.Address1,
			GPVendorMaster.Address2				= DATA.Address2,
			GPVendorMaster.City					= DATA.City,
			GPVendorMaster.State				= DATA.State,
			GPVendorMaster.ZipCode				= DATA.ZipCode,
			GPVendorMaster.[Status]				= DATA.[Status],
			GPVendorMaster.Phone				= DATA.Phone,
			GPVendorMaster.Email				= DATA.Email,
			GPVendorMaster.VendClass			= DATA.VendClass,
			GPVendorMaster.Changed				= 1,
			GPVendorMaster.SWSVendor			= @SWSVendor,
			GPVendorMaster.SWSVendorId			= @SWSAlias,
			GPVendorMaster.SWSBillTo			= @SWSBillTo,
			GPVendorMaster.AlternativeInvoice	= @AlternativeInvoice,
			GPVendorMaster.Override				= @Override,
			GPVendorMaster.ExcludeAutoHold		= @ExcludeAutoHold,
			GPVendorMaster.RapidPay				= @RapidPay,
			GPVendorMaster.RP_EffectiveDate		= IIF(@RecordChanged = 1, @RP_EffectiveDate, GPVendorMaster.RP_EffectiveDate),
			GPVendorMaster.PYMNTPRI				= DATA.PYMNTPRI,
			GPVendorMaster.ChangedOn			= GETDATE(),
			GPVendorMaster.UserId				= @UserId,
			GPVendorMaster.SWSInactive			= @SWSInactive
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
			SWSInactive,
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
			@SWSInactive,
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
