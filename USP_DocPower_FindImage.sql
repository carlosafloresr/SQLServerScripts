/*
EXECUTE USP_DocPower_FindImage 22, '11-298215'
*/
ALTER PROCEDURE USP_DocPower_FindImage
		@CompanyNumber	Smallint,
		@ProNumber		Varchar(20)
AS
SET NOCOUNT ON

DECLARE @Query			Varchar(Max)
DECLARE @tblImages		Table (DocType Varchar(5), UploadDate Date)

SET @Query = N'SELECT img.code, prod_scandt FROM proimgd p, com.doctype img WHERE prod_imgcat = img.imgcat AND appid = ''pro'' AND prod_company_id = ' + CAST(@CompanyNumber AS Varchar) + ' AND prod_load_no = ''' + RTRIM(@ProNumber) + ''''
PRINT @Query
INSERT INTO @tblImages
EXECUTE USP_QuerySWS @Query

SELECT	*
FROM	@tblImages