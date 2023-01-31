ALTER FUNCTION [dbo].[DateRangeTable]
(     
      @RangeType        Char(1),
      @StartDate        Date,
      @EndDate          Date,
	  @Increment		Int
)
RETURNS  
@SelectedRange    TABLE 
(IndividualDate Date)
AS 
BEGIN
      ;WITH cteRange (DateRange) AS (
            SELECT	@StartDate
            UNION ALL
            SELECT 
                  CASE
                        WHEN @RangeType = 'd' THEN DATEADD(dd, @Increment, DateRange)
                        WHEN @RangeType = 'w' THEN DATEADD(ww, @Increment, DateRange)
                        WHEN @RangeType = 'm' THEN DATEADD(mm, @Increment, DateRange)
                  END
            FROM	cteRange
            WHERE	DateRange <= 
                  CASE
                        WHEN @RangeType = 'd' THEN DATEADD(dd, @Increment * -1, @EndDate)
                        WHEN @RangeType = 'w' THEN DATEADD(ww, @Increment * -1, @EndDate)
                        WHEN @RangeType = 'm' THEN DATEADD(mm, @Increment * -1, @EndDate)
                  END)
          
      INSERT INTO @SelectedRange (IndividualDate)

      SELECT	DateRange
      FROM		cteRange
      OPTION	(MAXRECURSION 3660);
      RETURN
END
GO