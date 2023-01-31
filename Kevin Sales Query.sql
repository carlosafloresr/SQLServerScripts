DECLARE @begindate				DATE = '10/13/2016',
		@numofdays				INT,
		@enddate				DATE = '10/13/2017',
		@SalesForPeriod			NUMERIC(19, 5),
		@SalesOutstanding		NUMERIC(19, 5),
		@DaysSalesOutstanding	FLOAT,
		@AverageSalesPerDay		FLOAT,
		@CUSTNMBR				Varchar(20) = '20960'

SET @numofdays = DATEDIFF(day, @begindate, @enddate) + 1

SET @SalesForPeriod = ( (SELECT SUM(ortrxamt * CASE WHEN rmdtypal > 6 THEN -1 ELSE 1 END)
                         FROM	RM20101
                         WHERE  docdate BETWEEN @begindate AND @enddate
                                AND voidstts = 0 
								AND rmdtypal <> 9
                                AND CUSTNMBR = @CUSTNMBR) + 
						(SELECT SUM(ortrxamt * CASE WHEN rmdtypal > 6 THEN -1 ELSE 1 END)
						 FROM   RM30101
                         WHERE  docdate BETWEEN @begindate AND @enddate
                                AND voidstts = 0
								AND rmdtypal <> 9
                                AND CUSTNMBR = @CUSTNMBR))

SET @AverageSalesPerDay = @SalesForPeriod / @numofdays

SET @SalesOutstanding =(SELECT	SUM(custblnc)
                        FROM	RM00103 
						WHERE	CUSTNMBR = @CUSTNMBR)

SET @DaysSalesOutstanding = @SalesOutstanding / @AverageSalesPerDay

SELECT	@numofdays AS 'Number Of Days',
		ROUND(@SalesForPeriod, 2) AS 'Sales For Period',
		ROUND(@AverageSalesPerDay, 2) AS 'Average Sales Per Day',
		ROUND(@SalesOutstanding, 2) AS 'Sales Outstanding',
		ROUND(@DaysSalesOutstanding, 2) 'Days Sales Outstanding'
