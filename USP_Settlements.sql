USE [ILS_Datawarehouse]
GO

ALTER PROCEDURE USP_Settlements
		@Company		varchar(5),
		@Weekending		date = Null
AS
IF @Weekending IS Null
	SET @Weekending = GPCustom.dbo.DayFwdBack(GETDATE(),'N','Thursday')

IF NOT EXISTS(SELECT TOP 1 Company FROM Settlements WHERE Company = @Company AND Weekending = @Weekending)
	INSERT INTO [dbo].[Settlements]
			([Company]
			,[Weekending]
			,[Settlements])
     VALUES
			(@Company,
			@Weekending,
			1)
GO


