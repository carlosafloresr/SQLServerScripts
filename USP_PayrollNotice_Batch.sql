-- EXECUTE USP_PayrollNotice_Batch 'IILS', '~000~002~003~', '03/06/2008', 0.0425, '10/1/2007', 'IILS_2008030601', 4, 'CFLORES'
-- SELECT * FROM View_AllEmployees

CREATE PROCEDURE USP_PayrollNotice_Batch
	@Company		Char(6),
	@Departments		Varchar(2000),
	@EffectiveDate		DateTime,
	@Percentage		Money,
	@ExcludeDate		DateTime,
	@BatchId		Char(15),
	@NoticeType		Int,
	@UserId			Varchar(25)
AS
DECLARE	@EmployeeId		Int,
	@EmploymentDate		DateTime,
	@Supervisor		Char(15), 
	@Location		Char(15), 
	@GridClassification	Int, 
	@DOLStatus		Int, 
	@MBO_Eligible		Bit, 
	@MBO_Percentage		Numeric(18,2), 
	@Department		Char(10), 
        @JobPosition		Char(10), 
	@Amount			Money, 
	@Anual			Money,
	@FTPT			Char(1), 
	@Comments		Varchar(2500), 
	@RecommendedBy		Varchar(35), 
	@ApprovedBy1		Varchar(35), 
	@ApprovedBy2		Varchar(35),
	@Hourly			Bit,
	@CurrentSalary		Money,
	@WorkingDays		Int

DELETE GPCustom.dbo.PayrollNotice WHERE BatchId = @BatchId

DECLARE curEmployees CURSOR FOR
	SELECT	EmPloyId AS EmployeeId,
		HireDate AS EmploymentDate,
		SupervisorId AS Supervisor,
		LocationId AS Location,
		DepartmentId AS Department,
		JobTitleId AS JobPosition,
		CASE WHEN EmploymentType = 1 THEN 'F' ELSE 'P' END AS FTPT,
		Hourly,
		PayRate AS CurrentSalary
	FROM 	View_AllEmployees
	WHERE	Inactive = 0 AND
		((@ExcludeDate IS NOT Null AND HireDate < =@ExcludeDate) OR @ExcludeDate IS Null) AND
		PATINDEX('%' + RTRIM(DepartmentId) + '%', @Departments) > 0

OPEN curEmployees

FETCH NEXT FROM curEmployees INTO @EmployeeId, @EmploymentDate, @Supervisor, @Location, @Department, @JobPosition, @FTPT, @Hourly, @CurrentSalary

WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRANSACTION
	
	SET	@WorkingDays		= CASE WHEN @FTPT = 'F' THEN 40 ELSE 32 END
	SET	@Amount			= ROUND(@CurrentSalary * (1 + @Percentage), 2)
	SET	@Anual			= @Amount * (CASE WHEN @Hourly = 1 THEN @WorkingDays ELSE 1 END)

	IF EXISTS (SELECT EmployeeId FROM GPCustom.dbo.Payroll_Employees WHERE Company = @Company AND EmployeeId = @EmployeeId)
	BEGIN
		SELECT	@GridClassification	= GridClassification,
			@DOLStatus		= DOL_Status, 
			@MBO_Eligible		= MBO_Eligible, 
			@MBO_Percentage		= MBO_Percentage
		FROM	GPCustom.dbo.Payroll_Employees
		WHERE	Company			= @Company AND
			EmployeeId		= @EmployeeId
	END
	ELSE
	BEGIN
		SET	@GridClassification	= Null
		SET	@DOLStatus		= Null
		SET	@MBO_Eligible		= Null
		SET	@MBO_Percentage		= Null
	END

	INSERT INTO GPCustom.dbo.PayrollNotice
	       (BatchId, 
		Company, 
		EmployeeId, 
		NoticeType,
		EmploymentDate,
		EffectiveDate,
		Supervisor, 
		Location, 
		GridClassification, 
		DOLStatus, 
		MBO_Eligible, 
		MBO_Percentage, 
		Department, 
	        JobPosition, 
		Amount, 
		Anual,
		Increase,
		FTPT, 
		Comments, 
		RecommendedBy, 
		ApprovedBy1, 
		ApprovedBy2, 
		EnteredBy, 
		ChangedBy)
	VALUES (@BatchId, 
		@Company, 
		@EmployeeId, 
		@NoticeType,
		@EmploymentDate,
		@EffectiveDate,
		@Supervisor, 
		@Location, 
		ISNULL(@GridClassification, 0),
		@DOLStatus, 
		ISNULL(@MBO_Eligible, 0),
		ISNULL(@MBO_Percentage, 0.0),
		@Department, 
	        @JobPosition, 
		@Amount, 
		@Anual,
		@Percentage * 100,
		@FTPT, 
		@Comments, 
		@RecommendedBy, 
		@ApprovedBy1, 
		@ApprovedBy2, 
		@UserId, 
		@UserId)

	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END

	FETCH NEXT FROM curEmployees INTO @EmployeeId, @EmploymentDate, @Supervisor, @Location, @Department, @JobPosition, @FTPT, @Hourly, @CurrentSalary
END

CLOSE curEmployees
DEALLOCATE curEmployees

GO