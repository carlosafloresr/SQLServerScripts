USE [GPCustom]
GO

CREATE PROCEDURE USP_SWS_Reports_ProNumbers
		@UserId		Varchar(30),
		@ProNumber	Varchar(15)
AS
INSERT INTO [dbo].[SWS_Reports_ProNumbers]
           ([UserId]
           ,[ProNumber])
     VALUES
           (@UserId,
           @ProNumber)
GO


