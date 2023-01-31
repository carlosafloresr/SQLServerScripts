SET NOCOUNT ON

DECLARE	@Company	Varchar(5), 
		@VendorId	Varchar(12),
		@Query		Varchar(1000)

DECLARE @tblData	Table (Company Varchar(5), VendorId Varchar(12), VendorName Varchar(50) Null)
DECLARE	@tblName	Table (VendorName Varchar(50))

INSERT INTO @tblData (Company, VendorId) VALUES ('DNJ','IMCNA')
INSERT INTO @tblData (Company, VendorId) VALUES ('GIS','GAIS')
INSERT INTO @tblData (Company, VendorId) VALUES ('GIS','IMCNA')
INSERT INTO @tblData (Company, VendorId) VALUES ('GIS','GPDS')
INSERT INTO @tblData (Company, VendorId) VALUES ('GLSO','661')
INSERT INTO @tblData (Company, VendorId) VALUES ('GLSO','662')
INSERT INTO @tblData (Company, VendorId) VALUES ('GLSO','663')
INSERT INTO @tblData (Company, VendorId) VALUES ('GLSO','658')
INSERT INTO @tblData (Company, VendorId) VALUES ('GLSO','659')
INSERT INTO @tblData (Company, VendorId) VALUES ('GLSO','660')
INSERT INTO @tblData (Company, VendorId) VALUES ('GLSO','686')
INSERT INTO @tblData (Company, VendorId) VALUES ('PDS','GIS')
INSERT INTO @tblData (Company, VendorId) VALUES ('PDS','IMCNA')
INSERT INTO @tblData (Company, VendorId) VALUES ('PDS','PDS')
INSERT INTO @tblData (Company, VendorId) VALUES ('PTS','GIS')
INSERT INTO @tblData (Company, VendorId) VALUES ('PTS','IMCNA')

DECLARE Transaction_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company, VendorId
FROM	@tblData

OPEN Transaction_Companies 
FETCH FROM Transaction_Companies INTO @Company, @VendorId

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblName

	SET @Query = 'SELECT VENDNAME FROM ' + @Company + '.dbo.PM00200 WHERE VENDORID = ''' + @VendorId + ''''
		
	INSERT INTO @tblName
	EXECUTE(@Query)

	UPDATE	@tblData
	SET		VendorName = (SELECT VendorName FROM @tblName)
	WHERE	Company = @Company AND VendorId = @VendorId

	FETCH FROM Transaction_Companies INTO @Company, @VendorId
END

CLOSE Transaction_Companies
DEALLOCATE Transaction_Companies

SELECT	*
FROM	@tblData