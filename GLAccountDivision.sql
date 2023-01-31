/*
PRINT dbo.GLAccountDivision('IMC','33','1-DD-5028')
*/
ALTER FUNCTION GLAccountDivision (@Company Varchar(5), @Division Varchar(3), @GLAccount Varchar(15))
RETURNS Varchar(15)
BEGIN
	DECLARE @ReturnValue	Varchar(15) = RTRIM(@GLAccount),
			@RplcDivision	Varchar(3)

	IF @GLAccount LIKE '%DD%'
	BEGIN
		IF EXISTS(SELECT Division_Replace
					FROM	PRISQL01P.GPCustom.dbo.RSA_Divisions_Mapping 
					WHERE	Company = @Company
							AND Division_Original = @Division
							AND MappingType = 'ALL'
							AND Inactive = 0)
		BEGIN
			SELECT	@RplcDivision = Division_Replace
			FROM	PRISQL01P.GPCustom.dbo.RSA_Divisions_Mapping 
			WHERE	Company = @Company
					AND Division_Original = @Division
					AND MappingType = 'ALL'
					AND Inactive = 0

			SET @ReturnValue = REPLACE(RTRIM(@GLAccount), 'DD', RTRIM(@RplcDivision))
		END
		ELSE
			SET @ReturnValue = REPLACE(@ReturnValue, 'DD', RTRIM(@Division))
	END

	RETURN @ReturnValue
END