USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_Import_GPCheckBooks]    Script Date: 8/29/2016 10:21:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Import_GPCheckBooks
*/
ALTER PROCEDURE [dbo].[USP_Import_GPCheckBooks]
AS
DECLARE @tblAccount TABLE
	(Company		Varchar(5),
	ChekBkId		Varchar(30),
	BnkActNm		Varchar(20),
	CmpanyId		Int,
	LastRecvd		Date,
	ActNumSt		Varchar(20),
	Inactive		Bit)

INSERT INTO @tblAccount
	EXECUTE USP_Bank_Accounts

INSERT INTO GP_Bank_Accounts
SELECT	*
FROM	@tblAccount
WHERE	RTRIM(Company) + '_' + RTRIM(BnkActNm) NOT IN (SELECT RTRIM(Company) + '_' + RTRIM(BnkActNm) FROM GP_Bank_Accounts)

UPDATE	GP_Bank_Accounts
SET		GP_Bank_Accounts.Inactive	= DATA.Inactive,
		GP_Bank_Accounts.LastRecvd	= DATA.LastRecvd
FROM	@tblAccount DATA
WHERE	GP_Bank_Accounts.Company = DATA.Company
		AND GP_Bank_Accounts.BnkActNm = DATA.BnkActNm
		AND (GP_Bank_Accounts.Inactive <> DATA.Inactive
		OR GP_Bank_Accounts.LastRecvd <> DATA.LastRecvd)