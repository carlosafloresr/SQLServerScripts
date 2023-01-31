-- EXECUTE USP_UpdateSalary 41, 1500, 1500, 80000, '03/03/2008', 'TEST', 'CFLORES'

ALTER PROCEDURE USP_UpdateSalary
	@EmployId	Int,
	@Salary		Money,
	@PayPerPeriod	Money,
	@Annual		Money,
	@Effectivedate	Datetime,
	@Reason		Varchar(50),
	@UserId		Varchar(25)
AS
BEGIN TRANSACTION
UPDATE UPR00400 SET PayRtAmt = @Salary WHERE EmployId = @EmployId AND PayRcord IN (SELECT Primary_Pay_Record FROM UPR00100 WHERE EmployId = @EmployId)

IF @@ERROR = 0
BEGIN
	INSERT INTO HRPSLH01 
	       (EmployId, 
		PayRcord, 
		EffectiveDate_I,
		PayRtAmt,
		PayUnit,
		PayUnper,
		PayPerod,
		PayPrPrd,
		AnnualSalary_I,
		ChangeReason_I,
		UserId,
		ChangeDate_I)
	SELECT	EmployId,
		PayRcord,
		@Effectivedate,
		@Salary,
		PayUnit,
		1,
		PayUnper,
		@PayPerPeriod,
		@Annual,
		@Reason,
		@UserId,
		GETDATE()
	FROM	UPR00400
	WHERE	EmployId = @EmployId AND 
		PayRcord IN (SELECT Primary_Pay_Record FROM UPR00100 WHERE EmployId = @EmployId)
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	RETURN -1
END

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	RETURN 1
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	RETURN -1
END
GO

-- SELECT * FROM HRPSLH01
-- SELECT * FROM UPR00400