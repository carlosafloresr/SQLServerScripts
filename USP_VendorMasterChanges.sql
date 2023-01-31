CREATE PROCEDURE USP_VendorMasterChanges
	@Company	Varchar(5)
AS
IF EXISTS(SELECT Company FROM VendorMasterChanges WHERE Company = @Company)
BEGIN
	UPDATE	VendorMasterChanges
	SET		Changed = 1
	WHERE	Company = @Company
END
ELSE
BEGIN
	INSERT INTO VendorMasterChanges (Company, Changed) VALUES (@Company, 1)
END
GO