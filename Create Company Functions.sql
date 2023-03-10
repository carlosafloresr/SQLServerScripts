/*
***********************************************************************************
*                                  F U N C T I O N S                              *
***********************************************************************************
*/

IF EXISTS (SELECT * FROM Sys.Objects WHERE Object_Id = OBJECT_ID(N'[dbo].[ValidateCustomer]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[ValidateCustomer]
GO

CREATE FUNCTION [dbo].[ValidateCustomer] (@CustomerId Char(12))
RETURNS Bit
AS
BEGIN
	DECLARE	@Result		Int,
			@CustFound	Char(12)
		
	IF EXISTS(SELECT CustNmbr FROM dbo.RM00101 WHERE CustNmbr = @CustomerId)
		SET @Result = 1
	ELSE
		SET @Result = 0

	RETURN @Result
END
GO

IF EXISTS (SELECT * FROM Sys.Objects WHERE Object_Id = OBJECT_ID(N'[dbo].[ValidateVendor]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[ValidateVendor]
GO

CREATE FUNCTION [dbo].[ValidateVendor] (@VendorId Char(12))
RETURNS Bit
AS
BEGIN
	DECLARE	@Result		Int,
			@CustFound	Char(12)
		
	IF EXISTS(SELECT VendorId FROM dbo.PM00200 WHERE VendorId = @VendorId)
		SET @Result = 1
	ELSE
		SET @Result = 0

	RETURN @Result
END
GO

IF EXISTS (SELECT * FROM Sys.Objects WHERE Object_Id = OBJECT_ID(N'[dbo].[AR_DocumentBalance]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[AR_DocumentBalance]
GO

CREATE FUNCTION [dbo].[AR_DocumentBalance] (@CustNmbr Varchar(12), @DocNumbr Varchar(25))
RETURNS Money
BEGIN
	DECLARE	@ReturnValue Money
	
	SELECT	@ReturnValue = SUM(Amount)
	FROM   (SELECT	SlsAmnt AS Amount 
			FROM	dbo.RM20101 
			WHERE	CustNmbr = @CustNmbr 
					AND DocNumbr = @DocNumbr
			UNION
			SELECT	SlsAmnt AS Amount 
			FROM	dbo.RM30101 
			WHERE	CustNmbr = @CustNmbr 
					AND DocNumbr = @DocNumbr
			UNION
			SELECT	ISNULL(SUM(AppToAmt), 0.0) * -1 AS Amount 
			FROM	dbo.RM20201 
			WHERE	CustNmbr = @CustNmbr 
					AND ApToDcNm = @DocNumbr
			UNION
			SELECT	ISNULL(SUM(AppToAmt), 0.0) * -1 AS Amount 
			FROM	dbo.RM30201 
			WHERE	CustNmbr = @CustNmbr 
					AND ApToDcNm = @DocNumbr) DocBal
	
	RETURN @ReturnValue
END
GO

IF EXISTS (SELECT * FROM Sys.Objects WHERE Object_Id = OBJECT_ID(N'[dbo].[FindAPDocument]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FindAPDocument]
GO

CREATE FUNCTION [dbo].[FindAPDocument] (@VendorId Varchar(12), @DocNumber Varchar(25))
RETURNS Bit
BEGIN
	DECLARE	@ReturnValue	Bit,
			@DocFound		Varchar(25)
	
	SELECT	TOP 1 @DocFound = DocNumbr
	FROM   (SELECT	DocNumbr 
			FROM	dbo.PM00400 
			WHERE	VendorId = @VendorId 
					AND DocNumbr = @DocNumber
			UNION
			SELECT	DocNumbr 
			FROM	dbo.PM10000 
			WHERE	VendorId = @VendorId 
					AND DocNumbr = @DocNumber
			UNION
			SELECT	DocNumbr 
			FROM	dbo.PM20000 
			WHERE	VendorId = @VendorId 
					AND DocNumbr = @DocNumber
			UNION
			SELECT	DocNumbr 
			FROM	dbo.PM30200 
			WHERE	VendorId = @VendorId 
					AND DocNumbr = @DocNumber) DOCS
	
	IF @DocFound IS Null
		SET @ReturnValue = 0
	ELSE
		SET @ReturnValue = 1
		
	RETURN @ReturnValue
END
GO

IF EXISTS (SELECT * FROM Sys.Objects WHERE Object_Id = OBJECT_ID(N'[dbo].[FindARDocument]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FindARDocument]
GO

CREATE FUNCTION [dbo].[FindARDocument] (@DocNumber Varchar(25))
RETURNS Bit
BEGIN
	DECLARE	@ReturnValue	Bit,
			@DocFound		Varchar(25)
	
	SELECT	TOP 1 @DocFound = DocNumbr
	FROM   (SELECT	DocNumbr 
			FROM	dbo.RM20101 
			WHERE	DocNumbr = @DocNumber 
			UNION 
			SELECT	DocNumbr 
			FROM	dbo.RM00401 
			WHERE	DocNumbr = @DocNumber 
			UNION 
			SELECT	DocNumbr 
			FROM	dbo.RM10301 
			WHERE	DocNumbr = @DocNumber) DOCS
	
	IF @DocFound IS Null
		SET @ReturnValue = 0
	ELSE
		SET @ReturnValue = 1
		
	RETURN @ReturnValue
END
GO

IF EXISTS (SELECT * FROM Sys.Objects WHERE Object_Id = OBJECT_ID(N'[dbo].[ValidateDocument]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[ValidateDocument]
GO

CREATE FUNCTION [dbo].[ValidateDocument] (@Type Char(2), @DocNumber Varchar(25), @RecordId Varchar(12) = Null)
RETURNS Varchar(25)
BEGIN
	DECLARE	@Additions		Varchar(30),
			@ToEval			Varchar(25),
			@Counter		Int
			
	SET		@Additions	= 'ZYXWVTSRQPONMLKJIHGFEDCBA'
	SET		@Counter	= 0
	SET		@ToEval		= CASE WHEN @Type = 'AP' THEN dbo.FindAPDocument(@RecordId, @DocNumber) ELSE dbo.FindARDocument(@DocNumber) END

	WHILE @ToEval = 1
	BEGIN
		SET	@Counter	= @Counter + 1
		SET	@DocNumber	= RTRIM(@DocNumber) + SUBSTRING(@Additions, @Counter, 1)
		SET	@ToEval		= CASE WHEN @Type = 'AP' THEN dbo.FindAPDocument(@RecordId, @DocNumber) ELSE dbo.FindARDocument(@DocNumber) END
	END

	RETURN @DocNumber
END
GO

IF EXISTS (SELECT * FROM Sys.Objects WHERE Object_Id = OBJECT_ID(N'[dbo].[IsVendor1099]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[IsVendor1099]
GO

CREATE FUNCTION [dbo].[IsVendor1099] (@VendorId Varchar(12))
RETURNS Bit
BEGIN
	DECLARE @ReturnValue Bit
	
	SELECT	@ReturnValue = CASE WHEN Ten99Type > 1 THEN 1 ELSE 0 END
	FROM	dbo.PM00200 
	WHERE	VendorId = @VendorId
	
	RETURN @ReturnValue
END
GO

/*
***********************************************************************************
*                       S T O R E D   P R O C E D U R E S                         *
***********************************************************************************
*/

IF EXISTS(SELECT * FROM Sys.Objects WHERE Type = 'P' AND Name = 'USP_ActivateEmployee')
	DROP PROCEDURE [USP_ActivateEmployee]
GO

CREATE PROCEDURE [dbo].[USP_ActivateEmployee] (@EmployeeId Varchar(12))
AS
BEGIN
	DECLARE @ReturnValue Bit
	
	BEGIN TRANSACTION
		UPDATE dbo.UPR00100 SET Inactive = 0 WHERE EmployId = @EmployeeId
	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		SET @ReturnValue = 1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		SET @ReturnValue = 0
	END
	
	RETURN @ReturnValue
END
GO

IF EXISTS(SELECT * FROM Sys.Objects WHERE Type = 'P' AND Name = 'USP_ActivatePayCode')
	DROP PROCEDURE [USP_ActivatePayCode]
GO

CREATE PROCEDURE [dbo].[USP_ActivatePayCode] (@EmployeeId Varchar(12), @PayCode Varchar(10))
AS
BEGIN
	DECLARE @ReturnValue Bit
	
	BEGIN TRANSACTION
		UPDATE	dbo.UPR00400 
		SET		Inactive = 0 
		WHERE	EmployId = @EmployeeId 
				AND PayRcord = @PayCode
	
	IF @@ERROR = 0
	BEGIN
		COMMIT TRANSACTION
		SET @ReturnValue = 1
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		SET @ReturnValue = 0
	END
	
	RETURN @ReturnValue
END
GO