SET NOCOUNT ON

DECLARE	@TableName		Varchar(30),
		@ColumnName		Varchar(30),
		@OldValue		Varchar(10) = 'IMCGM',
		@NewValue		Varchar(10) = 'IMCMR',
		@Query			Varchar(1000)

DECLARE @tblData Table (
		TableName		Varchar(30),
		ColumnName		Varchar(30))
		 
INSERT INTO @tblData VALUES ('attachments','client')
INSERT INTO @tblData VALUES ('claim_detail','client')
INSERT INTO @tblData VALUES ('claim_detail_audit','client')
INSERT INTO @tblData VALUES ('claim_master','client')
INSERT INTO @tblData VALUES ('claim_master_audit','client')
INSERT INTO @tblData VALUES ('claim_notes','client')
INSERT INTO @tblData VALUES ('claim_payment_log','client')
INSERT INTO @tblData VALUES ('claim_payment_log_audit','client')
INSERT INTO @tblData VALUES ('claims_staged','client')
INSERT INTO @tblData VALUES ('claims_staged','company')
INSERT INTO @tblData VALUES ('companies','Code')

DECLARE curTables CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	@tblData

OPEN curTables 
FETCH FROM curTables INTO @TableName, @ColumnName

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'UPDATE ' + @TableName + ' SET ' + @ColumnName + ' = ' + CHAR(39) + @NewValue + CHAR(39) + ' WHERE ' + @ColumnName + ' = ' + CHAR(39) + @OldValue + CHAR(39)
	PRINT @Query
	EXECUTE(@Query)
	FETCH FROM curTables INTO @TableName, @ColumnName
END

CLOSE curTables
DEALLOCATE curTables