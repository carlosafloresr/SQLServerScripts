USE [GPCustom]
GO

ALTER PROCEDURE USP_GP_FinancialTransactions
	@Company		varchar(5),
    @JournalNumber	bigint,
	@Sequence		int,
    @ProNumber		varchar(20),
    @Chassis		varchar(15),
    @Container		varchar(15),
    @SWSId			bigint,
    @Integration	varchar(15)
AS
INSERT INTO [dbo].[GP_FinancialTransactions]
           ([Company]
           ,[JournalNumber]
		   ,[Sequence]
           ,[ProNumber]
           ,[Chassis]
           ,[Container]
           ,[SWSId]
           ,[Integration])
     VALUES
           (@Company
           ,@JournalNumber
		   ,@Sequence
           ,@ProNumber
           ,@Chassis
           ,@Container
           ,@SWSId
           ,@Integration)
GO


