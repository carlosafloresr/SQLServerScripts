USE [FI_Data]
GO
/****** Object:  StoredProcedure [dbo].[USP_Estimate]    Script Date: 12/12/2011 11:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_Estimate]
		@Inv_No		int,
		@Inv_Date	date = NULL,
        @Est_Date	date,
        @Rep_Date	date = NULL,
        @Entry_Date	date,
        @BatchId	varchar(25) = NULL,
        @OnlyInsert	Bit = 1
AS
IF EXISTS(SELECT Inv_No FROM Estimates WHERE Inv_No = @Inv_No)
BEGIN
	IF @OnlyInsert = 0
	BEGIN
		DECLARE	@Est_Date2	date,
				@Rep_Date2	date
		
		SELECT	@Est_Date2	= Est_Date,
				@Rep_Date2	= Rep_Date
		FROM	Estimates
		WHERE	Inv_No		= @Inv_No
		
		IF @Rep_Date <> @Rep_Date2
		BEGIN
			UPDATE	Estimates
			SET		Inv_Date	= @Inv_Date,
					Est_Date	= @Est_Date,
					Rep_Date	= @Rep_Date,
					BatchId		= @BatchId
			WHERE	Inv_No		= @Inv_No
		END
	END
END
ELSE
BEGIN
	INSERT INTO Estimates
		(Inv_No
		,Inv_Date
		,Est_Date
		,Rep_Date
		,Entry_Date
		,BatchId)
	VALUES
		(@Inv_No
		,@Inv_Date
		,@Est_Date
		,@Rep_Date
		,@Entry_Date
		,@BatchId)
END

