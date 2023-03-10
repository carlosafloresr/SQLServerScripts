USE [Tributary]
GO
/****** Object:  StoredProcedure [dbo].[USP_EBEDeleteImage]    Script Date: 9/20/2019 12:14:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_EBEDeleteImage]
		@DocID			Int,
		@File_Name		Varchar(150)
AS 
SET NOCOUNT ON

DECLARE	@Division		Varchar(5),
		@CustomerId		Varchar(20),
		@InvoiceNumber	Varchar(30),
		@Counter		Smallint

SELECT	@Division		= Division,
		@CustomerId		= CustomerId,
		@InvoiceNumber	= InvoiceNumber
FROM	(
		SELECT	DISTINCT APP.Division,
				APP.CustomerId,
				APP.InvoiceNumber
		FROM	PacketIDX_ShortPay PCK
				INNER JOIN App_Billing APP ON APP.InvoiceNumber = PCK.InvoiceNumber AND APP.CustomerID = PCK.CustomerId AND APP.Division = PCK.Division
		WHERE  APP.Doc_ID = @DocID
		) DATA

DELETE	PacketIDX_ShortPay
WHERE	Division = @Division
		AND CustomerId = @CustomerID 
		AND InvoiceNumber = @InvoiceNumber

IF @@ERROR = 0
BEGIN
       DELETE [Page] WHERE Doc_Id = @DocID
       DELETE [App_Billing] WHERE Doc_Id = @DocID

	   --SET @File_Name = RTRIM(SUBSTRING(@File_Name, dbo.AT('\', @File_Name, @Counter) + 1, 50))

	   INSERT INTO FileDeletionLog (Company, Customer, InvoiceNumber, [FileName]) VALUES (@Division, @CustomerId, @InvoiceNumber, @File_Name)
END
