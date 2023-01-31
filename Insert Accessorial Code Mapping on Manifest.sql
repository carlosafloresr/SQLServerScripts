USE [Manifest]
GO

DECLARE	@Company	Varchar(5) = 'HMIS',
		@CompanyId	Varchar(5),
		@AccCode	Varchar(5) = '455',
		@AccDesc	Varchar(50) = 'Swing at Rail',
		@GLAccount	Varchar(15) = '1-00-5010'

SET @CompanyId = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE ParameterCode = 'PREPAY_COMPANY' AND Company = @Company)

IF NOT EXISTS(SELECT Company FROM GL_Mapping WHERE company = @CompanyId AND charge_code = @AccCode AND ap_code = @GLAccount)
BEGIN
	INSERT INTO GL_Mapping
			(company,
			charge_code,
			charge_description,
			ap_code,
			sws_accessorial_code,
			sws_accessorial_description)
	VALUES
			(@CompanyId,
			@AccCode,
			@AccDesc,
			@GLAccount,
			@AccCode,
			@AccDesc)
END

SELECT	*
FROM	GL_Mapping
WHERE	Company = @CompanyId