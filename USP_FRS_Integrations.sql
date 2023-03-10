USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FRS_Integrations]    Script Date: 5/19/2015 4:15:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_FRS_Integrations]
			@IntegrationType	char(2),
			@BatchId			varchar(30),
			@FileName			varchar(30),
			@FileVersion		varchar(10),
			@AccountNumber		varchar(10),
			@InvoiceNumber		varchar(25),
			@InvoiceDate		varchar(20),
			@Chassis			varchar(11),
			@Container			varchar(11),
			@Currency			char(3),
			@Labor				numeric(10,2),
			@Parts				numeric(10,2),
			@Tax				numeric(10,2),
			@InvoiceTotal		numeric(10,2),
			@PrepaidAmount		numeric(10,2),
			@PaymentType		char(3),
			@ReferenceNumber	varchar(12),
			@EFSRequestType		char(1),
			@Workorder			varchar(10),
			@Documents			varchar(2500),
			@Address			varchar(50),
			@City				varchar(25),
			@State				varchar(10),
			@ZipCode			varchar(10)
AS
INSERT INTO dbo.FRS_Integrations
			(IntegrationType
			,BatchId
			,FileName
			,FileVersion
			,AccountNumber
			,InvoiceNumber
			,InvoiceDate
			,Chassis
			,Container
			,Currency
			,Labor
			,Parts
			,Tax
			,InvoiceTotal
			,PrepaidAmount
			,PaymentType
			,ReferenceNumber
			,EFSRequestType
			,Workorder
			,Documents
			,Address
			,City
			,State
			,ZipCode)
VALUES
			(@IntegrationType
			,@BatchId
			,@FileName
			,@FileVersion
			,@AccountNumber
			,@InvoiceNumber
			,@InvoiceDate
			,@Chassis
			,@Container
			,@Currency
			,@Labor
			,@Parts
			,@Tax
			,@InvoiceTotal
			,@PrepaidAmount
			,@PaymentType
			,@ReferenceNumber
			,@EFSRequestType
			,@Workorder
			,@Documents
			,@Address
			,@City
			,@State
			,@ZipCode)
