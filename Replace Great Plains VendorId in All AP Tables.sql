SET NOCOUNT ON

DECLARE	@OldVendorId	Varchar(20) = '1000172',
		@NewVendorId	Varchar(20) = '1000172New'

DECLARE	@TableName		Varchar(50),
		@FieldName		Varchar(50),
		@Query			Varchar(MAX)

DECLARE	@tblData Table
		(TableName	Varchar(50),
		FieldName	Varchar(50))

INSERT INTO @tblData (TableName, FieldName) VALUES ('CM20502','CMLinkID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('GL30000','ORMSTRID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('CM20200','CMLinkID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('GL20000','ORMSTRID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM00200','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM00201','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM00202','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM00204','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM00300','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM00400','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM10100','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM10200','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM10300','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM20000','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM20100','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM30200','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM30300','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM30600','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM80500','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('PM80600','VENDORID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('SY01200','Master_ID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('SY04904','EmailCardID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('SY04905','EmailCardID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('SY04906','EmailCardID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('SY06000','CustomerVendor_ID')
INSERT INTO @tblData (TableName, FieldName) VALUES ('SY06000','VENDORID')

DECLARE curVendorTables CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	@tblData

OPEN curVendorTables 
FETCH FROM curVendorTables INTO @TableName, @FieldName

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = 'UPDATE ' + @TableName + ' SET ' + @FieldName + ' = ''' + @NewVendorId + ''' WHERE ' + @FieldName + ' = ''' + @OldVendorId + ''''

	PRINT @Query		
	EXECUTE(@Query)

	FETCH FROM curVendorTables INTO @TableName, @FieldName
END

CLOSE curVendorTables
DEALLOCATE curVendorTables