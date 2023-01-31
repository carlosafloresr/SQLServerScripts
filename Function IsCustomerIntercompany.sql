ALTER FUNCTION IsCustomerIntercompany (@Company Varchar(5), @Customer Varchar(12), @Intercompany Varchar(12))
RETURNS Bit
AS
BEGIN
	DECLARE	@ReturnValue Bit
	
	IF @Company = 'AIS'
	BEGIN
		IF EXISTS(SELECT CustNmbr FROM AIS.dbo.RM00101 WHERE CustNmbr = @Customer AND CprCstNm = @Intercompany)
			SET @ReturnValue = 1
		ELSE
			SET @ReturnValue = 0
	END
	
	IF @Company = 'FI'
	BEGIN
		IF EXISTS(SELECT CustNmbr FROM FI.dbo.RM00101 WHERE CustNmbr = @Customer AND CprCstNm = @Intercompany)
			SET @ReturnValue = 1
		ELSE
			SET @ReturnValue = 0
	END
	
	IF @Company = 'GIS'
	BEGIN
		IF EXISTS(SELECT CustNmbr FROM GIS.dbo.RM00101 WHERE CustNmbr = @Customer AND CprCstNm = @Intercompany)
			SET @ReturnValue = 1
		ELSE
			SET @ReturnValue = 0
	END
	
	IF @Company = 'IMC'
	BEGIN
		IF EXISTS(SELECT CustNmbr FROM IMC.dbo.RM00101 WHERE CustNmbr = @Customer AND CprCstNm = @Intercompany)
			SET @ReturnValue = 1
		ELSE
			SET @ReturnValue = 0
	END
	
	IF @Company = 'NDS'
	BEGIN
		IF EXISTS(SELECT CustNmbr FROM NDS.dbo.RM00101 WHERE CustNmbr = @Customer AND CprCstNm = @Intercompany)
			SET @ReturnValue = 1
		ELSE
			SET @ReturnValue = 0
	END
	
	IF @Company = 'RCCL'
	BEGIN
		IF EXISTS(SELECT CustNmbr FROM RCCL.dbo.RM00101 WHERE CustNmbr = @Customer AND CprCstNm = @Intercompany)
			SET @ReturnValue = 1
		ELSE
			SET @ReturnValue = 0
	END
	
	IF @Company = 'RCMR'
	BEGIN
		IF EXISTS(SELECT CustNmbr FROM RCMR.dbo.RM00101 WHERE CustNmbr = @Customer AND CprCstNm = @Intercompany)
			SET @ReturnValue = 1
		ELSE
			SET @ReturnValue = 0
	END
	
	RETURN @ReturnValue
END

/*
SELECT * FROM RCMR.dbo.RM00101 WHERE CprCstNm = '11000'

PRINT dbo.IsCustomerIntercompany('RCMR', '12005', '11000')
*/