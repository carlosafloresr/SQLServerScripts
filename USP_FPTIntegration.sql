USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FPTIntegration]    Script Date: 04/14/2009 09:40:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_FPTIntegration]
		@Company		Varchar(5),
		@WeekEndDate	Datetime,
		@VendorId		Varchar(12) = Null
AS
SELECT @WeekEndDate = dbo.DayFwdBack(@WeekEndDate,'N','Saturday') - 7
print @WeekEndDate
SELECT	*
FROM	View_Integration_FPT
WHERE	Company = @Company
		AND WeekEndDate = CONVERT(Char(10), @WeekEndDate, 101)
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND LTRIM(VendorId) = @VendorId))
ORDER BY
		VendorId
		,TransDate
		,FPT_ReceivedDetailId

-- EXECUTE USP_FPTIntegration 'IMC', '4/10/2009', '4465'
