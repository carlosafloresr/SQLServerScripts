USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[BNK_Insert_Header]    Script Date: 8/17/2016 3:10:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================
Author:			Percy Brown
Create date:	2012-06-18
Description:	Insert record into table dbo.BAI_Header and return BAI_HeaderId
Revised by:		Percy Brown
Revised date:	2012-07-25
Description:	Added @CompanyID
=============================================
*/
ALTER PROCEDURE [dbo].[BNK_Insert_Header]
		@TrxDate		Datetime,
		@AbaNum			Varchar(15),
		@Currency		Char(3) = NULL,
		@AcctNum		Varchar(15),
		@AcctName		Varchar(15) = NULL,
		@BegBal			Numeric(19,5),
		@DepCr			Numeric(19,5) = 0,
		@ChkDb			Numeric(19,5) = 0,
		@UnCr			Numeric(19,5) = 0,
		@UnDb			Numeric(19,5) = 0,
		@EndBal			Numeric(19,5),
		@UploadDate		Datetime,
		@IsRecon		Bit = 0,
		@ReconDate		Datetime = NULL,
		@BaiFileName	Varchar(50) = NULL
AS
SET NOCOUNT ON

DECLARE @CompanyID		Int

DECLARE @tblAccounts	Table
		(Company		Varchar(5),
		CHEKBKID		Varchar(50),
		BNKACTNM		Varchar(25),
		CMPANYID		SmallInt,
		LastDate		Date,
		ACTNUMST		Varchar(20),
		INACTIVE		Bit)

INSERT INTO @tblAccounts
	EXECUTE USP_Bank_Accounts

SET @CompanyID = (SELECT TOP 1 CMPANYID FROM @tblAccounts WHERE INACTIVE = 0 AND BNKACTNM = @AcctNum)

IF NOT EXISTS(SELECT TOP 1 BAI_HeaderId FROM BAI_Header WHERE TrxDate = @TrxDate AND AcctNum = @AcctNum AND BaiFileName = @BaiFileName AND Cmpanyid = @CompanyID AND BegBal = @BegBal AND EndBal = @EndBal)
BEGIN
	INSERT INTO dbo.BAI_Header
			(TrxDate
			,AbaNum
			,Currency
			,AcctNum
			,AcctName
			,BegBal
			,DepCr
			,ChkDb
			,UnCr
			,UnDb
			,EndBal
			,UploadDate
			,IsRecon
			,ReconDate
			,BaiFileName
			,Cmpanyid) 
	VALUES
			(@TrxDate
			,@AbaNum
			,@Currency
			,@AcctNum
			,@AcctName
			,@BegBal
			,@DepCr
			,@ChkDb
			,@UnCr
			,@UnDb
			,@EndBal
			,@UploadDate
			,@IsRecon
			,@ReconDate
			,@BaiFileName
			,@CompanyID)

	RETURN SCOPE_IDENTITY()
END
ELSE
	RETURN 0