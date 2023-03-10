USE [RCMR_Data]
GO
/****** Object:  StoredProcedure [dbo].[USP_Find_FIDocuments]    Script Date: 04/30/2010 16:52:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Find_FIDocuments '454796'
EXECUTE USP_Find_FIDocuments 'ALLGCP','N','10/02/2009',Null,1
SELECT * FROM FI_Documents ORDER BY Par_Type, Par_Doc
*/
ALTER PROCEDURE [dbo].[USP_Find_FIDocuments]
	@DocumentId Varchar(20),
	@InvType	Char(1) = 'R',
	@DateStart	Datetime = Null,
	@DateEnd	Datetime = Null,
	@ForMerge	Bit = 0
AS
EXECUTE USP_FI_Data_DeleteDuplicateDocuments

DECLARE	@Path	Varchar(50)

SELECT	@Path = RTRIM(VarC)
FROM	ILSGP01.GPCustom.dbo.[Parameters]
WHERE	ParameterCode = 'DOCS_Target'
		AND Company = 'RCMR'

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
			,Par_Doc
			,FI_DocumentId
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'INV' + RTRIM(@DocumentId) AS Parent
					,FI_DocumentId
			FROM	RCMR_Documents
			WHERE	DocNumber = @DocumentId
					AND DocType = 'NWO'
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM RCMR_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
							,FI1.FI_DocumentId
					FROM	RCMR_Documents FI1
							LEFT JOIN RCMR_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
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
			,FI_DocumentId
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'BATCH' + RTRIM(@DocumentId) AS Parent
					,FI_DocumentId
			FROM	RCMR_Documents
			WHERE	Par_Type = 'BATCH'
					AND Par_Doc = @DocumentId
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM RCMR_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
							,FI1.FI_DocumentId
					FROM	RCMR_Documents FI1
							LEFT JOIN RCMR_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
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
			,FI_DocumentId
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'root' AS Parent
					,FI_DocumentId
			FROM	RCMR_Documents
			WHERE	Par_Type = 'INV'
					AND Par_Doc IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Container = @DocumentId)
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM RCMR_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
							,FI1.FI_DocumentId
					FROM	RCMR_Documents FI1
							LEFT JOIN RCMR_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
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
			,FI_DocumentId
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'root' AS Parent
					,FI_DocumentId
			FROM	RCMR_Documents
			WHERE	DocType = 'INV'
					AND DocNumber IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Chassis = @DocumentId)
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM RCMR_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
							,FI1.FI_DocumentId
					FROM	RCMR_Documents FI1
							LEFT JOIN RCMR_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
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
			,FI_DocumentId
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'root' AS Parent
					,FI_DocumentId
			FROM	RCMR_Documents
			WHERE	DocType = 'INV'
					AND DocNumber IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE GenSet_No = @DocumentId)
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,Parent = (CASE WHEN EXISTS(SELECT TOP 1 FI3.DocType FROM RCMR_Documents FI3 WHERE RTRIM(FI3.DocType) + RTRIM(FI3.DocNumber) = CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END) THEN CASE WHEN FI2.Par_Doc IS Null THEN 'INV' + RTRIM(@DocumentId) ELSE RTRIM(FI1.Par_Type) + FI1.Par_Doc END ELSE 'INV' + RTRIM(@DocumentId) END)
							,FI1.FI_DocumentId
					FROM	RCMR_Documents FI1
							LEFT JOIN RCMR_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
					WHERE	FI1.Par_Doc IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE GenSet_No = @DocumentId)
							AND FI1.Par_Type = 'INV') RECS
	ORDER BY
			Par_Doc
			,DocNumber
END

IF @InvType = 'N' -- Customer Number
BEGIN
	IF @DateEnd IS Null
		SET @DateEnd = CAST(CONVERT(Char(10), @DateStart, 101) + ' 11:59:59 PM' AS Datetime)
	ELSE
		SET @DateEnd = CAST(CONVERT(Char(10), @DateEnd, 101) + ' 11:59:59 PM' AS Datetime)
		
	SELECT	@Path + LTRIM(Document) AS Document
			,DocType
			,DocNumber
			,RTRIM(DocType) + RTRIM(DocNumber) AS Node
			,Parent
			,Par_Type
			,Par_Doc
			,FI_DocumentId
			,SortBy
	FROM	(
			SELECT	DISTINCT Document
					,DocType
					,DocNumber
					,Par_Type
					,Par_Doc
					,'root' AS Parent
					,FI_DocumentId
					,'1' AS SortBy
			FROM	RCMR_Documents
			WHERE	DocType = 'INV'
					AND Par_Type = ''
					AND DocNumber IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Acct_No = @DocumentId AND Inv_Date BETWEEN @DateStart AND @DateEnd)
			UNION
			SELECT	DISTINCT FI1.Document
							,FI1.DocType
							,FI1.DocNumber
							,FI1.Par_Type
							,FI1.Par_Doc
							,CASE WHEN dbo.ReferenceDocumentExists(FI1.Par_Type,FI1.Par_Doc) = 1 THEN RTRIM(FI1.Par_Type) + RTRIM(FI1.Par_Doc) ELSE CASE WHEN dbo.ReferenceDocumentExists('INV',FI1.Par_Doc) = 1 THEN 'INV' + RTRIM(FI1.Par_Doc) ELSE 'CUST' + RTRIM(@DocumentId) END END
							,FI1.FI_DocumentId
							,'2' AS SortBy
					FROM	RCMR_Documents FI1
							LEFT JOIN RCMR_Documents FI2 ON FI1.Par_Type = FI2.DocType AND FI1.Par_Doc = FI2.DocNumber
					WHERE	FI1.Par_Doc IN (SELECT CAST(Inv_No AS Varchar(20)) FROM Invoices WHERE Acct_No = @DocumentId AND Inv_Date BETWEEN @DateStart AND @DateEnd)) RECS
	ORDER BY
			CASE WHEN @ForMerge = 1 THEN CASE WHEN Parent = 'root' THEN RTRIM(DocType) + RTRIM(DocNumber) + SortBy ELSE Parent + SortBy END ELSE SortBy END
			,DocNumber
END

/*
EXECUTE USP_Find_FIDocuments 'HOUEMP','N','12/3/2008',nULL, 1
PRINT dbo.ReferenceDocumentExists('INV','346905')
*/