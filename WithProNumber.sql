USE [GPCustom]
GO
/****** Object:  UserDefinedFunction [dbo].[FindProNumber]    Script Date: 1/6/2023 4:16:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	
PRINT dbo.WithProNumber('BNSF|95200771|MSKU4596130')
*/
ALTER FUNCTION [dbo].[WithProNumber] (@Text Varchar(100))
RETURNS Bit
AS
BEGIN
	DECLARE	@ReturnValue	Bit = 0

	SET @Text = REPLACE(REPLACE(LTRIM(RTRIM(UPPER(@Text))), ' ', ''), ' ', '')
	SET @ReturnValue = (IIF(@Text LIKE '%[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]%', 1, 0))

	RETURN @ReturnValue
END