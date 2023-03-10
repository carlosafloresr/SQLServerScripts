USE [DepotSystemsViews]
GO
/****** Object:  StoredProcedure [dbo].[USP_MRInvoices_AP]    Script Date: 5/14/2020 12:26:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[USP_MRInvoices_AP]
		@InvoiceNumber varchar(15),
		@Field1			varchar(100),
		@Field2			date,
		@Field3			varchar(15),
		@Field4			varchar(20),
		@Field5			numeric(10,2),
		@Field8			varchar(15),
		@Field9			varchar(25),
		@Field10		date,
		@Field11		varchar(15),
		@Field13		varchar(30),
		@Field14		varchar(15),
		@Field16		varchar(15),
		@Field17		varchar(15),
		@Field18		varchar(10),
		@Field20		numeric(10,2),
		@EIRI			varchar(12),
		@UserId			varchar(15)
AS
IF EXISTS(SELECT InvoiceNumber FROM MRInvoices_AP WHERE InvoiceNumber = @InvoiceNumber)
BEGIN
	UPDATE	MRInvoices_AP
	SET		Field1		= @Field1,
			Field2		= @Field2,
			Field3		= @Field3,
			Field4		= @Field4,
			Field5		= @Field5,
			Field8		= @Field8,
			Field9		= @Field9,
			Field10		= @Field10,
			Field11		= @Field11,
			Field13		= @Field13,
			Field14		= @Field14,
			Field16		= @Field16,
			Field17		= @Field17,
			Field18		= @Field18,
			Field20		= @Field20,
			EIRI		= @EIRI,
			UserId		= @UserId
	WHERE	InvoiceNumber = @InvoiceNumber
END
ELSE
BEGIN
	INSERT INTO [dbo].[MRInvoices_AP]
			   ([InvoiceNumber]
			   ,[Field1]
			   ,[Field2]
			   ,[Field3]
			   ,[Field4]
			   ,[Field5]
			   ,[Field8]
			   ,[Field9]
			   ,[Field10]
			   ,[Field11]
			   ,[Field13]
			   ,[Field14]
			   ,[Field16]
			   ,[Field17]
			   ,[Field18]
			   ,[Field20]
			   ,[EIRI]
			   ,[UserId])
		 VALUES
			   (@InvoiceNumber,
			   @Field1,
			   @Field2,
			   @Field3,
			   @Field4,
			   @Field5,
			   @Field8,
			   @Field9,
			   @Field10,
			   @Field11,
			   @Field13,
			   @Field14,
			   @Field16,
			   @Field17,
			   @Field18,
			   @Field20,
			   @EIRI,
			   @UserId)
END