ALTER FUNCTION GenerateCodeText (@Parameter Varchar(25))
RETURNS Varchar(25)
AS
BEGIN
	DECLARE	@BaseText	Varchar(50) = '6785941320HREAKEUGBXNJZKVQWYPLCMIOD',
			@varI		Int = 1,
			@ReturnVal	Varchar(25) = ''

	SET @Parameter = RTRIM(@Parameter)

	WHILE @varI <= LEN(@Parameter)
	BEGIN
		IF SUBSTRING(@Parameter, @varI, 1) NOT IN (' ', '-', '/', '.', ',')
		BEGIN
			IF ISNUMERIC(SUBSTRING(@Parameter, @varI, 1)) = 1
				SET @ReturnVal = @ReturnVal + SUBSTRING(@BaseText, CAST(SUBSTRING(@Parameter, @varI, 1) AS Int) + 1, 1)
			ELSE
				SET @ReturnVal = @ReturnVal + SUBSTRING(@BaseText, GPCustom.dbo.AT(SUBSTRING(@Parameter, @varI, 1), @BaseText, 1) - 5, 1)
		END
		ELSE
			SET @ReturnVal = @ReturnVal + SUBSTRING(@Parameter, @varI, 1)

		SET @varI = @varI + 1
	END
	RETURN @ReturnVal
END