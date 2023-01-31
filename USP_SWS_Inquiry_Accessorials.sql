/*
EXECUTE USP_SWS_Inquiry_Accessorial 104166733
*/
ALTER PROCEDURE USP_SWS_Inquiry_Accessorial
		@OrderNumber	Int
AS
DECLARE	@Query			Varchar(MAX)

DECLARE	@tblAccessorial	Table (
		Sequence		Int,
		ADate			Date,
		ATime			Varchar(15),
		T300Code		Varchar(5),
		AccDescription	Varchar(50),
		Amount			Numeric(10,2),
		Quantity		Numeric(10,2),
		Total			Numeric(10,2))

IF @OrderNumber = 0
BEGIN
	SELECT	Sequence,
			ADate,
			T300Code,
			AccDescription,
			Amount,
			Quantity,
			Total
	FROM	@tblAccessorial
END
ELSE
BEGIN
	SET @Query = N'SELECT seq, adate, atime, t300_code, description, amount, qty, total FROM TRK.orchrg WHERE Or_No = ' + CAST(@OrderNumber AS Varchar)

	INSERT INTO @tblAccessorial
	EXECUTE USP_QuerySWS_ReportData @Query

	SELECT	Sequence,
			CAST(CAST(ADate AS Varchar) + ' ' + ATime AS DateTime) AS ADate,
			T300Code,
			AccDescription,
			Amount,
			Quantity,
			Total
	FROM	@tblAccessorial
	ORDER BY Sequence
END