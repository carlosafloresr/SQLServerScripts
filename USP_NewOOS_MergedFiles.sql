USE [GPCustom]
GO

CREATE PROCEDURE USP_NewOOS_MergedFiles
		@Company	varchar(5),
		@Weekending	date,
		@Division	varchar(3),
		@FileName	varchar(100)
AS
IF NOT EXISTS(SELECT Company FROM NewOOS_MergedFiles WHERE Company = @Company AND Weekending = @Weekending AND Division = @Division)
	INSERT INTO [dbo].[NewOOS_MergedFiles]
           ([Company]
           ,[Weekending]
           ,[Division]
           ,[FileName])
     VALUES
           (@Company
           ,@Weekending
           ,@Division
           ,@FileName)
GO


