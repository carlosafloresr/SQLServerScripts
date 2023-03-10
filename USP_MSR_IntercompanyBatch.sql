USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_MSR_IntercompanyBatch]    Script Date: 05/12/2010 11:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_MSR_IntercompanyBatch]
		@BatchId					Varchar(20),
		@PostingDate				Datetime = Null,
		@Processed					Int = -1
AS
DECLARE	@MSR_IntercompanyBatchId	Int

SET	@MSR_IntercompanyBatchId = (SELECT MSR_IntercompanyBatchId FROM MSR_IntercompanyBatch WHERE BatchId = @BatchId)

IF @MSR_IntercompanyBatchId IS Null
 BEGIN
	INSERT INTO MSR_IntercompanyBatch 
		(BatchId, PostingDate, Processed)
	VALUES
		(@BatchId, @PostingDate, @Processed)
 END
ELSE
 BEGIN
	UPDATE	MSR_IntercompanyBatch 
	SET		PostingDate				= @PostingDate,
			Processed				= @Processed
	WHERE	MSR_IntercompanyBatchId = @MSR_IntercompanyBatchId
 END