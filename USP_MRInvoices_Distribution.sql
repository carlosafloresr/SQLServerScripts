USE [DepotSystemsViews]
GO

CREATE PROCEDURE USP_MRInvoices_Distribution
		@InvoiceNumber	varchar(15),
        @GLAccount		varchar(15),
        @Description	varchar(30),
        @Amount			numeric(10,2),
        @UserId			varchar(25)
AS
INSERT INTO [dbo].[MRInvoices_Distribution]
           ([InvoiceNumber]
           ,[GLAccount]
           ,[Description]
           ,[Amount]
           ,[UserId])
     VALUES
           (@InvoiceNumber,
           @GLAccount,
           @Description,
           @Amount,
           @UserId)
GO


