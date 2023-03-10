USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_InfoSecPasswordExpirationsSent]    Script Date: 5/24/2022 8:07:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_InfoSecPasswordExpirationsSent '05/18/2022'
*/
ALTER PROCEDURE [dbo].[USP_InfoSecPasswordExpirationsSent]
		@RunDate		Date
AS
DECLARE @ReturnValue	Int = 0

IF EXISTS(SELECT SubmittedOn FROM InfoSecPasswordExpirationsSent WHERE SubmittedOn = @RunDate)
	SET @ReturnValue = 1
ELSE
	INSERT INTO InfoSecPasswordExpirationsSent (SubmittedOn) VALUES (@RunDate)

SELECT CAST(@ReturnValue AS Bit) AS ReturnValue