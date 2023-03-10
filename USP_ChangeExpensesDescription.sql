USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_ChangeExpensesDescription]    Script Date: 05/12/2010 11:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_ChangeExpensesDescription]
	@CompanyId	Varchar(6),
	@VoucherNo	Varchar(25)
AS
DECLARE	@Query	Varchar(2000)

SET	@Query = 'SELECT DISTINCT CONVERT(Char(10), EffDate, 101) AS PostDate, * FROM '
SET	@Query = @Query + LTRIM(RTRIM(@CompanyId)) + '.dbo.View_Expense_Reporting_Open WHERE '
SET	@Query = @Query + 'RIGHT(RTRIM(VoucherNo), ' + RTRIM(CAST(LEN(LTRIM(RTRIM(@VoucherNo))) AS Char(5))) + ') = ''' + LTRIM(RTRIM(@VoucherNo)) + ''''

EXECUTE(@Query)
