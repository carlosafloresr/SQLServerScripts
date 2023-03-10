ALTER PROCEDURE [dbo].[USP_Find_FIDocuments]
	@DocumentId Varchar(20),
	@InvType	Char(1) = 'R'
AS
DECLARE	@Path	Varchar(50)

SELECT	@Path = RTRIM(VarC)
FROM	ILSGP01.GPCustom.dbo.Parameters
WHERE	ParameterCode = 'DOCS_Target'
		AND Company = 'FI'

IF SUBSTRING(@Path, LEN(@Path), 1) <> '\'
	SET @Path = @Path + '\'

IF @InvType = 'R'
BEGIN
	SELECT	@Path + LTRIM(Document) AS Document
			,DocType
			,DocNumber
			,RTRIM(DocType) + RTRIM(DocNumber) AS Node
			,Parent
			,Par_Type
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'INV' + RTRIM(@DocumentId) AS Parent
			FROM	FI_Documents
			WHERE	DocNumber = @DocumentId
					AND DocType = 'NWO'
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM FI_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
					FROM	FI_Documents FI1
							LEFT JOIN FI_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
					WHERE	(FI1.DocNumber = @DocumentId
							OR FI1.Par_Doc = @DocumentId)
							AND FI1.DocType <> 'INV') RECS
	ORDER BY
			Par_Doc
			,DocNumber
END

IF @InvType = 'B' -- Batch
BEGIN
	DECLARE @InvNumber	Int
	SET		@InvNumber	= CAST(@DocumentId AS Int)

	SELECT	@Path + LTRIM(Document) AS Document
			,DocType
			,DocNumber
			,RTRIM(DocType) + RTRIM(DocNumber) AS Node
			,Parent
			,Par_Type
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'BATCH' + RTRIM(@DocumentId) AS Parent
			FROM	FI_Documents
			WHERE	Par_Type = 'BATCH'
					AND Par_Doc = @DocumentId
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM FI_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
					FROM	FI_Documents FI1
							LEFT JOIN FI_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
					WHERE	(FI1.DocNumber IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Inv_Batch = @InvNumber)
							OR FI1.Par_Doc IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Inv_Batch = @InvNumber))
							AND FI1.DocType <> 'INV') RECS
	ORDER BY
			Par_Doc
			,DocNumber
END

IF @InvType = 'C' -- Container
BEGIN
	SELECT	@Path + LTRIM(Document) AS Document
			,DocType
			,DocNumber
			,RTRIM(DocType) + RTRIM(DocNumber) AS Node
			,Parent
			,Par_Type
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'root' AS Parent
			FROM	FI_Documents
			WHERE	Par_Type = 'INV'
					AND Par_Doc IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Container = @DocumentId)
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM FI_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
					FROM	FI_Documents FI1
							LEFT JOIN FI_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
					WHERE	(FI1.DocNumber IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Container = @DocumentId)
							OR FI1.Par_Doc IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Container = @DocumentId))
							AND FI1.DocType <> 'INV') RECS
	ORDER BY
			Par_Doc
			,DocNumber
END


IF @InvType = 'H' -- Chassis
BEGIN
SELECT	@Path + LTRIM(Document) AS Document
			,DocType
			,DocNumber
			,RTRIM(DocType) + RTRIM(DocNumber) AS Node
			,Parent
			,Par_Type
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'root' AS Parent
			FROM	FI_Documents
			WHERE	DocType = 'INV'
					AND DocNumber IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Chassis = @DocumentId)
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM FI_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
					FROM	FI_Documents FI1
							LEFT JOIN FI_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
					WHERE	FI1.Par_Doc IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Chassis = @DocumentId)
							AND FI1.Par_Type = 'INV') RECS
	ORDER BY
			Par_Doc
			,DocNumber
END

IF @InvType = 'G' -- GenSet Number
BEGIN
SELECT	@Path + LTRIM(Document) AS Document
			,DocType
			,DocNumber
			,RTRIM(DocType) + RTRIM(DocNumber) AS Node
			,Parent
			,Par_Type
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'root' AS Parent
			FROM	FI_Documents
			WHERE	DocType = 'INV'
					AND DocNumber IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE GenSet_No = @DocumentId)
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM FI_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
					FROM	FI_Documents FI1
							LEFT JOIN FI_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
					WHERE	FI1.Par_Doc IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE GenSet_No = @DocumentId)
							AND FI1.Par_Type = 'INV') RECS
	ORDER BY
			Par_Doc
			,DocNumber
END