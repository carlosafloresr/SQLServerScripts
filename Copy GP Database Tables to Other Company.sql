SET NOCOUNT ON

DECLARE	@FromDB		Varchar(5) = 'IGSC',
		@ToDB		Varchar(5) = 'SUCON'

DECLARE	@Table		Varchar(50),
		@Column		Varchar(100),
		@Query		Varchar(MAX),
		@QueryD		Varchar(MAX),
		@QueryF		Varchar(MAX),
		@QueryS		Varchar(MAX),
		@Starter	Int

DECLARE @tblTables	Table (objTable Varchar(100))

INSERT INTO @tblTables (objTable) VALUES('GL00102')
INSERT INTO @tblTables (objTable) VALUES('CM00100')
INSERT INTO @tblTables (objTable) VALUES('CM40100')
INSERT INTO @tblTables (objTable) VALUES('CM40101')
INSERT INTO @tblTables (objTable) VALUES('GL40000')
INSERT INTO @tblTables (objTable) VALUES('GL40200')
INSERT INTO @tblTables (objTable) VALUES('MC40000')
INSERT INTO @tblTables (objTable) VALUES('MC40100')
INSERT INTO @tblTables (objTable) VALUES('ASILOC50')
INSERT INTO @tblTables (objTable) VALUES('ASILOC90')
INSERT INTO @tblTables (objTable) VALUES('SY00300')
INSERT INTO @tblTables (objTable) VALUES('SY02200')
INSERT INTO @tblTables (objTable) VALUES('SY02300')
INSERT INTO @tblTables (objTable) VALUES('SY03000')
INSERT INTO @tblTables (objTable) VALUES('SY03300')
INSERT INTO @tblTables (objTable) VALUES('SY04100')
INSERT INTO @tblTables (objTable) VALUES('SY40100')
INSERT INTO @tblTables (objTable) VALUES('SY40101')

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	objTable
FROM	@tblTables

OPEN curData 
FETCH FROM curData INTO @Table

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF EXISTS(SELECT Object_Id FROM SYS.Objects WHERE Name = @Table)
	BEGIN
		DECLARE curFields CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	Name
		FROM	SYS.Columns
		WHERE	Object_Id IN (SELECT Object_Id FROM SYS.Objects WHERE Name = @Table)
				AND is_identity = 0
		ORDER BY Column_Id

		OPEN curFields 
		FETCH FROM curFields INTO @Column

		SET @Starter = 0
		SET @QueryF = ''
		SET @QueryS = ''

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			IF @Starter = 0
			BEGIN
				SET @QueryD		= N'DELETE ' + @ToDB + '.dbo.' + RTRIM(@Table)
				SET @QueryF		= N'INSERT INTO ' + @ToDB + '.dbo.' + RTRIM(@Table) + '('
				SET @QueryS		= N'SELECT '
				SET @Starter	= 1
			END
			ELSE
				SET @Starter	= 2

			SET @QueryF = @QueryF + IIF(@Starter = 2, ',', '') + @Column
			SET @QueryS = @QueryS + IIF(@Starter = 2, ',', '') + @Column

			FETCH FROM curFields INTO @Column
		END

		CLOSE curFields
		DEALLOCATE curFields

		SET @QueryF = @QueryF + ')'
		SET @QueryS = @QueryS + ' FROM ' + @FromDB + '.dbo.' + @Table

		PRINT @QueryD
		PRINT @QueryF
		PRINT @QueryS
		PRINT ' '

		SET @Query = @QueryF + ' ' + @QueryS

		EXECUTE(@QueryD)
		EXECUTE(@Query)

	END
	ELSE
		PRINT 'Table ' + @Table + ' not found!'

	FETCH FROM curData INTO @Table
END

CLOSE curData
DEALLOCATE curData