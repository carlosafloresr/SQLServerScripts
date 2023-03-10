USE [GPCustom] 
GO
/****** Object:  StoredProcedure [dbo].[USP_CustomerMaster]    Script Date: 4/12/2022 8:26:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_CustomerMaster]
		@CustomerMasterId	Int,
		@CompanyId			Char(6),
		@CustNmbr			Char(10),
		@CustName			Varchar(65),
		@CustClas			Char(15),
		@Address1			Varchar(61),
		@Address2			Varchar(61),
		@City				Varchar(35),
		@State				Varchar(29),
		@Zip				Char(11),
		@Phone1				Varchar(25),
		@Inactive			Bit,
		@Hold				Bit,
		@CntCprsn			Varchar(61),
		@ChangedBy			Varchar(25),
		@SalsTerr			Varchar(12) = ' ',
		@AltShipperOnly		Bit = 0,
		@InvoiceEmailOption SmallInt = 1,
		@SWSCustomerId		Varchar(6) = Null,
		@ReferenceOnEmail	Bit = 0,
		@EmailJustInvoice	Bit = 0
AS
DECLARE	@ReturnValue		Int,
		@Query				Varchar(2000)

DECLARE @tblCustData		Table (
		COMPANY				Varchar(5),
		CUSTNMBR			Varchar(15),
		STMTNAME			Varchar(65),
		ADRSCODE			Varchar(15),
		CHEKBKID			Varchar(15),
		CRLMTAMT			Numeric(12,2),
		CRLMTTYP			Smallint,
		MXWOFTYP			Smallint,
		MXWROFAM			Numeric(12,2),
		TAXEXMT1			Varchar(25),
		TAXEXMT2			Varchar(25),
		TXRGNNUM			Varchar(25),
		STMTCYCL			Smallint,
		BALNCTYP			Smallint,
		BANKNAME			Varchar(31),
		BNKBRNCH			Varchar(21),
		COMMENT1			Varchar(31),
		COMMENT2			Varchar(31),
		USERDEF1			Varchar(21),
		USERDEF2			Varchar(21),
		COUNTRY				Varchar(61),
		CPRCSTNM			Varchar(15),
		CRLMTPAM			numeric(19, 5),
		CRLMTPER			smallint,
		CURNCYID			Varchar(15),
		CUSTDISC			smallint,
		FAX					Varchar(21),
		PHONE2				Varchar(21),
		PHONE3				Varchar(21),
		FNCHATYP			smallint,
		FNCHPCNT			smallint,
		FINCHDLR			numeric(19, 5),
		MINPYTYP			smallint,
		MINPYDLR			numeric(19, 5),
		MINPYPCT			smallint,
		PRBTADCD			Varchar(15),
		PRSTADCD			Varchar(15),
		PRCLEVEL			Varchar(11),
		SHRTNAME			Varchar(15),
		STADDRCD			Varchar(15))

SET @Query = N'SELECT ''' + @CompanyId + ''', CUSTNMBR,
		STMTNAME,
		ADRSCODE,
		CHEKBKID,
		CRLMTAMT,
		CRLMTTYP,
		MXWOFTYP,
		MXWROFAM,
		TAXEXMT1,
		TAXEXMT2,
		TXRGNNUM,
		STMTCYCL,
		BALNCTYP,
		RTRIM(BANKNAME),
		RTRIM(BNKBRNCH),
		RTRIM(COMMENT1),
		RTRIM(COMMENT2),
		RTRIM(USERDEF1),
		RTRIM(USERDEF2),
		RTRIM(COUNTRY),
		RTRIM(CPRCSTNM),
		CRLMTPAM,
		CRLMTPER,
		RTRIM(CURNCYID),
		CUSTDISC,
		RTRIM(FAX),
		RTRIM(PHONE2),
		RTRIM(PHONE3),
		FNCHATYP,
		FNCHPCNT,
		FINCHDLR,
		MINPYTYP,
		MINPYDLR,
		MINPYPCT,
		RTRIM(PRBTADCD),
		RTRIM(PRSTADCD),
		RTRIM(PRCLEVEL),
		RTRIM(SHRTNAME),
		RTRIM(STADDRCD)
	FROM ' + RTRIM(@CompanyId) + '.dbo.RM00101 
	WHERE CUSTNMBR = ''' + RTRIM(@CustomerMasterId) + ''''

INSERT INTO @tblCustData
EXECUTE(@Query)

IF @InvoiceEmailOption IS NULL
	SET @InvoiceEmailOption = 1

BEGIN TRANSACTION
	IF EXISTS(SELECT CompanyId FROM CustomerMaster WHERE CustomerMasterId = @CustomerMasterId)
	BEGIN
		UPDATE 	CustomerMaster
		SET		CustName					= @CustName,
				CustClas					= @CustClas,
				Address1					= @Address1,
				Address2					= @Address2,
				City						= @City,
				State						= @State,
				Zip							= @Zip,
				Phone1						= @Phone1,
				Inactive					= @Inactive,
				Hold						= @Hold,
				CntCprsn					= @CntCprsn,
				SalsTerr					= @SalsTerr,
				CustomerMaster.Changed		= 1,
				CustomerMaster.Trasmitted 	= 0,
				AltShipperOnly				= @AltShipperOnly,
				ChangedBy					= @ChangedBy,
				InvoiceEmailOption			= @InvoiceEmailOption,
				SWSCustomerId				= @SWSCustomerId,
				ReferenceOnEmail			= @ReferenceOnEmail,
				Result						= '',
				EmailJustInvoice			= @EmailJustInvoice
		WHERE	CustomerMasterId			= @CustomerMasterId

		SET		@ReturnValue				= @CustomerMasterId
	END
	ELSE
	BEGIN
		INSERT INTO CustomerMaster
			   (CompanyiD,
				CustNmbr,
				CustName,
				CustClas,
				Address1,
				Address2,
				City,
				State,
				Zip,
				Phone1,
				Inactive,
				Hold,
				CntCprsn,
				SalsTerr,
				AltShipperOnly,
				InvoiceEmailOption,
				SWSCustomerId,
				ReferenceOnEmail,
				EmailJustInvoice,
				ChangedBy)
		VALUES (@CompanyiD,
				@CustNmbr,
				@CustName,
				@CustClas,
				@Address1,
				@Address2,
				@City,
				@State,
				@Zip,
				@Phone1,
				@Inactive,
				@Hold,
				@CntCprsn,
				@SalsTerr,
				@AltShipperOnly,
				@InvoiceEmailOption,
				@SWSCustomerId,
				@ReferenceOnEmail,
				@EmailJustInvoice,
				@ChangedBy)

		SET	@ReturnValue = @@IDENTITY
	END

	UPDATE 	CustomerMaster
	SET		CustomerMaster.STMTNAME	= DATA.STMTNAME,
			CustomerMaster.ADRSCODE	= DATA.ADRSCODE,
			CustomerMaster.CHEKBKID	= DATA.CHEKBKID,
			CustomerMaster.CRLMTAMT = DATA.CRLMTAMT,
			CustomerMaster.CRLMTTYP = DATA.CRLMTTYP,
			CustomerMaster.MXWOFTYP = DATA.MXWOFTYP,
			CustomerMaster.MXWROFAM = DATA.MXWROFAM,
			CustomerMaster.TAXEXMT1 = DATA.TAXEXMT1,
			CustomerMaster.TAXEXMT2 = DATA.TAXEXMT2,
			CustomerMaster.TXRGNNUM = DATA.TXRGNNUM,
			CustomerMaster.STMTCYCL = DATA.STMTCYCL,
			CustomerMaster.BALNCTYP = DATA.BALNCTYP,
			CustomerMaster.BANKNAME = DATA.BANKNAME,
			CustomerMaster.BNKBRNCH = DATA.BNKBRNCH,
			CustomerMaster.COMMENT1 = DATA.COMMENT1,
			CustomerMaster.COMMENT2 = DATA.COMMENT2,
			CustomerMaster.USERDEF1 = DATA.USERDEF1,
			CustomerMaster.USERDEF2 = DATA.USERDEF2,
			CustomerMaster.COUNTRY  = DATA.COUNTRY,
			CustomerMaster.CPRCSTNM = DATA.CPRCSTNM,
			CustomerMaster.CRLMTPAM = DATA.CRLMTPAM,
			CustomerMaster.CRLMTPER = DATA.CRLMTPER,
			CustomerMaster.CURNCYID = DATA.CURNCYID,
			CustomerMaster.CUSTDISC = DATA.CUSTDISC,
			CustomerMaster.FAX		= DATA.FAX,
			CustomerMaster.PHONE2   = DATA.PHONE2,
			CustomerMaster.PHONE3   = DATA.PHONE3,
			CustomerMaster.FNCHATYP = DATA.FNCHATYP,
			CustomerMaster.FNCHPCNT = DATA.FNCHPCNT,
			CustomerMaster.FINCHDLR = DATA.FINCHDLR,
			CustomerMaster.MINPYTYP = DATA.MINPYTYP,
			CustomerMaster.MINPYDLR = DATA.MINPYDLR,
			CustomerMaster.MINPYPCT = DATA.MINPYPCT,
			CustomerMaster.PRBTADCD = DATA.PRBTADCD,
			CustomerMaster.PRSTADCD = DATA.PRSTADCD,
			CustomerMaster.PRCLEVEL = DATA.PRCLEVEL,
			CustomerMaster.SHRTNAME = DATA.SHRTNAME,
			CustomerMaster.STADDRCD = DATA.STADDRCD
	FROM	@tblCustData DATA
	WHERE	CustomerMaster.CompanyId = @CompanyId
			AND CustomerMaster.CustNmbr = DATA.CUSTNMBR

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		RETURN @ReturnValue
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		RETURN -1
	END