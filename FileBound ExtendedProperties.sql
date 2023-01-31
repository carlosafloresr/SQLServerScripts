SET NOCOUNT ON

DECLARE @tblInvoiceData			Table (
		ACTNUMST				Varchar(10),
		PORDNMBR				Varchar(20),
		DEPARTMENT				Varchar(10),
		DEPTODESC				Varchar(10),
		AMOUNT					Numeric(10,2),
		DISTREF					Varchar(100),
		GL_Division				Varchar(10),
		PopUpId					Int,
		ACTDESCR				Varchar(100))

DECLARE	@ObjectType				int,
		@ObjectID				int,
		@PropertyKey			varchar(250),
		@PropertyValue			varchar(8000),
		@ReferenceObjectType	int,
		@ReferenceObjectID		int,
		@KeyGroup1				varchar(250),
		@KeyGroup2				varchar(250),
		@KeyGroup3				varchar(250),
		@KeyGroup4				varchar(250),
		@KeyGroup5				varchar(250),
		@KeyGroup6				varchar(250),
		@KeyGroup7				varchar(250),
		@KeyGroup8				varchar(250),
		@KeyGroup9				varchar(250),
		@KeyGroup10				varchar(250),
		@RemoteID				int,
		@ACTNUMST				Varchar(10),
		@PORDNMBR				Varchar(20),
		@DEPARTMENT				Varchar(10),
		@DEPTODESC				Varchar(10),
		@AMOUNT					Numeric(10,2),
		@DISTREF				Varchar(100),
		@GL_Division			Varchar(10),
		@PopUpId				Int,
		@ACTDESCR				Varchar(100),
		@InvoiceNumber			Varchar(20),
		@FileID					Int

DECLARE curInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	MR.InvoiceNumber, FB.FileID
FROM	MRInvoices_AP MR
		LEFT JOIN PRIFBSQL01P.FB.dbo.View_DEXDocuments FB ON MR.Field8 = FB.Field8 AND MR.Field4 = FB.Field4 AND FB.ProjectID = 65
WHERE	MR.CreatedOn >= '01/13/2021'
		AND MR.Field20 < 50.01
		--AND FB.KeyGroup1 IS Null
ORDER BY MR.InvoiceNumber

OPEN curInvoices 
FETCH FROM curInvoices INTO @InvoiceNumber, @FileID

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblInvoiceData

	PRINT 'Invoice # ' + @InvoiceNumber

	INSERT INTO @tblInvoiceData
	EXECUTE USP_MRInvoices_Distribution_Data @InvoiceNumber

	BEGIN
		DECLARE curInvoiceData CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	*
		FROM	@tblInvoiceData

		OPEN curInvoiceData 
		FETCH FROM curInvoiceData INTO @ACTNUMST, @PORDNMBR, @DEPARTMENT, @DEPTODESC, @AMOUNT, @DISTREF, @GL_Division, @PopUpId, @ACTDESCR
		BEGIN
			SET @ObjectType				= 5
			SET @ObjectID				= @FileID
			SET @PropertyKey			= 'GL_Code_Entry'
			SET @PropertyValue			= @ACTNUMST
			SET @ReferenceObjectType	= 0
			SET @ReferenceObjectID		= 0
			SET @KeyGroup1				= @ACTDESCR
			SET @KeyGroup2				= ''
			SET @KeyGroup3				= @DEPARTMENT
			SET @KeyGroup4				= CAST(@AMOUNT AS Varchar)
			SET @KeyGroup5				= @DISTREF
			SET @KeyGroup6				= 'GL'
			SET @KeyGroup7				= @DEPTODESC
			SET @KeyGroup8				= @DEPARTMENT
			SET @KeyGroup9				= @DEPTODESC
			SET @KeyGroup10				= @PopUpId
			SET @RemoteID				= 0

			INSERT INTO PRIFBSQL01P.FB.dbo.ExtendedProperties
				   ([ObjectType]
				   ,[ObjectID]
				   ,[PropertyKey]
				   ,[PropertyValue]
				   ,[ReferenceObjectType]
				   ,[ReferenceObjectID]
				   ,[KeyGroup1]
				   ,[KeyGroup2]
				   ,[KeyGroup3]
				   ,[KeyGroup4]
				   ,[KeyGroup5]
				   ,[KeyGroup6]
				   ,[KeyGroup7]
				   ,[KeyGroup8]
				   ,[KeyGroup9]
				   ,[KeyGroup10]
				   ,[RemoteID])
			 VALUES
				   (@ObjectType
				   ,@ObjectID
				   ,@PropertyKey
				   ,@PropertyValue
				   ,@ReferenceObjectType
				   ,@ReferenceObjectID
				   ,@KeyGroup1
				   ,@KeyGroup2
				   ,@KeyGroup3
				   ,@KeyGroup4
				   ,@KeyGroup5
				   ,@KeyGroup6
				   ,@KeyGroup7
				   ,@KeyGroup8
				   ,@KeyGroup9
				   ,@KeyGroup10
				   ,@RemoteID)

			FETCH FROM curInvoiceData INTO @ACTNUMST, @PORDNMBR, @DEPARTMENT, @DEPTODESC, @AMOUNT, @DISTREF, @GL_Division, @PopUpId, @ACTDESCR
		END

		CLOSE curInvoiceData
		DEALLOCATE curInvoiceData
	END

	FETCH FROM curInvoices INTO @InvoiceNumber, @FileID
END

CLOSE curInvoices
DEALLOCATE curInvoices

