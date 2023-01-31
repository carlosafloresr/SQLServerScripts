-- EXECUTE USP_PayrollNotice_Batch 'IILS', '~000~002~003~', '03/06/2008', 0.0425, '10/1/2007', 'IILS_2008030601', 4, 'CFLORES'
-- SELECT * FROM View_AllEmployees

ALTER PROCEDURE USP_PayrollNotice_Batch
	@Company	Char(6),
	@Departments	Varchar(2000),
	@EffectiveDate	DateTime,
	@Percentage	Money,
	@ExcludeDate	DateTime,
	@BatchId	Char(15),
	@NoticeType	Int,
	@UserId		Varchar(25)
AS
DECLARE	@Query		Varchar(2000)
SET	@Query		= 'EXECUTE ' + RTRIM(@Company) + '.dbo.USP_PayrollNotice_Batch ''' + RTRIM(@Company) + ''''
SET	@Query		= @Query + ', ''' + @Departments + ''''
SET	@Query		= @Query + ', ''' + CONVERT(Char(10), @EffectiveDate, 101) + ''''
SET	@Query		= @Query + ', ' + RTRIM(LTRIM(CONVERT(Char(10), @Percentage * 1.0, 0)))
SET	@Query		= @Query + ', ''' + CONVERT(Char(10), @ExcludeDate, 101) + ''''
SET	@Query		= @Query + ', ''' + RTRIM(@BatchId) + ''''
SET	@Query		= @Query + ', ' + RTRIM(CAST(@NoticeType AS Char(5)))
SET	@Query		= @Query + ', ''' + RTRIM(@UserId) + ''''

EXECUTE(@Query)
GO

SELECT * FROM PayrollNotice WHERE BatchId = 'IILS_2008030601'

SELECT MAX(BatchId) AS BatchId FROM PayrollNoticeBatch WHERE BatchId LIKE '%IILS_20080306%' AND BatchId IS NOT Null