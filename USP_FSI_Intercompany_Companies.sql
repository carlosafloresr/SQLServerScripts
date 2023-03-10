ALTER PROCEDURE USP_FSI_Intercompany_Companies
	@FSI_IntercompanyId	Int,
	@ForCompany			Varchar(5),
	@LinkType			Char(1),
	@LinkedCompany		Varchar(5),
	@AccountIndex		Smallint,
	@AccountNumber		Varchar(15)
AS
IF @FSI_IntercompanyId > 0
BEGIN
	UPDATE	FSI_Intercompany_Companies
	SET		ForCompany			= @ForCompany,
			LinkType			= @LinkType,
			LinkedCompany		= @LinkedCompany,
			AccountIndex		= @AccountIndex,
			AccountNumber		= @AccountNumber
	WHERE	FSI_IntercompanyId	= @FSI_IntercompanyId

	IF @@ERROR = 0
		RETURN @FSI_IntercompanyId
	ELSE
		RETURN -1
END
ELSE
BEGIN
	INSERT INTO FSI_Intercompany_Companies
           (ForCompany
           ,LinkType
           ,LinkedCompany
           ,AccountIndex
           ,AccountNumber)
	VALUES
		  (@ForCompany,
           @LinkType,
           @LinkedCompany,
           @AccountIndex,
           @AccountNumber)

	IF @@ERROR = 0
		RETURN @@IDENTITY
	ELSE
		RETURN -1
END
	
