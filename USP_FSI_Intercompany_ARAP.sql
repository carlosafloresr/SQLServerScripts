USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_Intercompany_ARAP]    Script Date: 3/27/2019 9:13:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[USP_FSI_Intercompany_ARAP]
	@Company			Varchar(5),
	@LinkedCompany		Varchar(5),
	@RecordType			Char(1),
	@Account			Varchar(12),
	@TransType			Char(3) = 'FRG',
	@Action				Char(1) = 'S'
AS
DECLARE	@UserId			Varchar(25) = (SELECT LEFT(UPPER(SYSTEM_USER), 25))

IF @Action = 'S'
BEGIN
	-- SAVE DATA
	INSERT INTO FSI_Intercompany_ARAP
		(Company
		,LinkedCompany
		,RecordType
		,Account
		,TransType)
	VALUES
		(@Company
		,@LinkedCompany
		,@RecordType
		,@Account
		,@TransType)
END
ELSE
BEGIN
	-- DELETE DATA
	DELETE	FSI_Intercompany_ARAP 
	WHERE	Company = @Company 
			AND RecordType = @RecordType 
			AND Account = @Account 
			AND TransType = @TransType
END

IF @@ERROR = 0
BEGIN
	IF @RecordType = 'C'
		UPDATE	PRISQL01P.GPCustom.dbo.CustomerMaster
		SET		Changed = 1,
				Trasmitted = 0,
				ChangedBy = @UserId
		WHERE	CompanyId = @Company
				AND CustNmbr = @Account
	ELSE
		UPDATE	PRISQL01P.GPCustom.dbo.GPVendorMaster
		SET		Changed = 1,
				ChangedOn = GETDATE()
		WHERE	Company = @Company
				AND VendorId = @Account
END
GO