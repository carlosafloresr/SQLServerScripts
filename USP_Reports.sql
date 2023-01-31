ALTER PROCEDURE USP_Reports
	@ReportId	Int = Null,
	@ReportFolder	Varchar(75),
	@ReportName	Varchar(50),
	@ReportType	Char(1),
	@FullPath	Varchar(75),
	@Company	VarChar(6) = Null,
	@Inactive	Bit = 0
AS
DECLARE @RepId		Int

IF @ReportId IS NULL OR @ReportId = 0
BEGIN
	IF EXISTS (	SELECT 	ReportId 
			FROM 	Reports 
			WHERE 	Reports.FullPath = @FullPath AND 
				Reports.ReportName = @ReportName AND 
				Reports.ReportType = @ReportType)
	BEGIN
		SET	@RepId = (	SELECT 	ReportId 
					FROM 	Reports 
					WHERE 	Reports.FullPath = @FullPath AND 
						Reports.ReportName = @ReportName AND 
						Reports.ReportType = @ReportType)
	END
	ELSE
		SET 	@RepId = 0
END
ELSE
	SET 	@RepId = @ReportId

BEGIN TRANSACTION
IF @RepId = 0
BEGIN
	INSERT INTO Reports (
		ReportName, 
		ReportFolder, 
		ReportType,
		FullPath,
		Company, 
		Inactive)
	VALUES (@ReportName, 
		@ReportFolder, 
		@ReportType, 
		@FullPath,
		@Company, 
		@Inactive)
END
ELSE
BEGIN
	UPDATE Reports
	SET	ReportName	= @ReportName, 
		ReportFolder	= @ReportFolder, 
		ReportType	= @ReportType, 
		FullPath	= @FullPath,
		Company		= @Company, 
		Inactive	= @Inactive
	WHERE	ReportId = @RepId
END

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	IF @RepId = 0
	   RETURN @@IDENTITY
	ELSE
	   RETURN @RepId
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	RETURN @@ERROR * -1
END

GO