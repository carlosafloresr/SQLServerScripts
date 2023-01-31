/*
PRINT dbo.GetMonthName('NOV-22')
*/
CREATE FUNCTION GetMonthName (@Period Char(8))
RETURNS Varchar(15)
BEGIN
	DECLARE @ReturnValue	Varchar(15),
			@TempDate		Date = CASE LEFT(@Period, 3)
			 WHEN 'JAN' THEN '01/01/20'
			 WHEN 'FEB' THEN '02/01/20'
			 WHEN 'MAR' THEN '03/01/20'
			 WHEN 'APR' THEN '04/01/20'
			 WHEN 'MAY' THEN '05/01/20'
			 WHEN 'JUN' THEN '06/01/20'
			 WHEN 'JUL' THEN '07/01/20'
			 WHEN 'AUG' THEN '08/01/20'
			 WHEN 'SEP' THEN '09/01/20'
			 WHEN 'OCT' THEN '10/01/20'
			 WHEN 'NOV' THEN '11/01/20'
			 ELSE '12/01/20' END + RIGHT(@Period, 2)

	SET @ReturnValue = DATENAME(month, @TempDate)

	RETURN @ReturnValue
END