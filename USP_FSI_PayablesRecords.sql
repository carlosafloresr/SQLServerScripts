CREATE PROCEDURE USP_FSI_PayablesRecords
	@RecordId	Int
AS
IF NOT EXISTS(SELECT RecordId FROM FSI_PayablesRecords WHERE RecordId = @RecordId)
	INSERT INTO FSI_PayablesRecords (RecordId) VALUES (@RecordId)