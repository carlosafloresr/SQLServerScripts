USE [DepotSystemsViews]
GO
/****** Object:  StoredProcedure [dbo].[USP_MRInvoices_GLCoding]    Script Date: 11/10/2022 1:20:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_MRInvoices_GLCoding '10/01/2022'
*/
ALTER PROCEDURE [dbo].[USP_MRInvoices_GLCoding]
		@RunDate	Date
AS
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
		ACTDESCR				Varchar(100),
		RecordId				Int)

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
		@FileID					Int,
		@RecordId				Int

DECLARE	@tblInvoiceNums Table (InvoiceNumber Varchar(20), Field8 Varchar(20), Field4 Varchar(20))
DECLARE @tblFileBound	Table (Field4 Varchar(20), FileID Bigint, PropertyValue Varchar(50))

INSERT INTO @tblInvoiceNums
SELECT	DISTINCT InvoiceNumber, Field8, Field4
FROM	MRInvoices_AP
WHERE	CreatedOn >= @RunDate
		AND Field20 < 300.01

INSERT INTO @tblFileBound
SELECT	DEXD.Field4, DEXD.FileID, DEXD.PropertyValue
FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments DEXD
		LEFT JOIN PRIFBSQL01P.FB.dbo.ExtendedProperties EXPR ON DEXD.FileID = EXPR.ObjectID AND EXPR.PropertyKey = 'GL_Code_Entry' AND EXPR.ObjectType = 5 AND EXPR.KeyGroup6 = 'GL'
WHERE	DEXD.ProjectID = 65
		AND DEXD.Field4 IN (SELECT Field4 FROM @tblInvoiceNums)
		AND EXPR.ObjectID IS Null

DECLARE curInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	MR.InvoiceNumber, FB.FileID
FROM	@tblInvoiceNums MR
		LEFT JOIN @tblFileBound FB ON MR.Field4 = FB.Field4
WHERE	FB.PropertyValue IS Null
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
		FETCH FROM curInvoiceData INTO @ACTNUMST, @PORDNMBR, @DEPARTMENT, @DEPTODESC, @AMOUNT, @DISTREF, @GL_Division, @PopUpId, @ACTDESCR, @RecordId
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

			BEGIN TRY
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
			END TRY
			BEGIN CATCH
				PRINT ERROR_MESSAGE()
			END CATCH

			FETCH FROM curInvoiceData INTO @ACTNUMST, @PORDNMBR, @DEPARTMENT, @DEPTODESC, @AMOUNT, @DISTREF, @GL_Division, @PopUpId, @ACTDESCR, @RecordId
		END

		CLOSE curInvoiceData
		DEALLOCATE curInvoiceData
	END

	FETCH FROM curInvoices INTO @InvoiceNumber, @FileID
END

CLOSE curInvoices
DEALLOCATE curInvoices

