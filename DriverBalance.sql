CREATE FUNCTION DriverBalance(@Company Varchar(5), @VendorId Varchar(12), @PayDate Datetime)
RETURNS Numeric(12,2)
AS
BEGIN
	DECLARE	@Balance Numeric(12,2)

	IF @Company = 'AIS'
	BEGIN
		SELECT	@Balance = ISNULL(SUM(Amount - ApplyTo), 0)
		FROM	(
				SELECT	PM1.VendorId
						,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
						,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM AIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @PayDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
				FROM	AIS.dbo.PM20000 PM1
				WHERE	PM1.PostEddt <= @PayDate
						AND PM1.VendorId = @VendorId) TRN
	END

	IF @Company = 'GIS'
	BEGIN
		SELECT	@Balance = ISNULL(SUM(Amount - ApplyTo), 0)
		FROM	(
				SELECT	PM1.VendorId
						,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
						,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM GIS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @PayDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
				FROM	GIS.dbo.PM20000 PM1
				WHERE	PM1.PostEddt <= @PayDate
						AND PM1.VendorId = @VendorId) TRN
	END

	IF @Company = 'IMC'
	BEGIN
		SELECT	@Balance = ISNULL(SUM(Amount - ApplyTo), 0)
		FROM	(
				SELECT	PM1.VendorId
						,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
						,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM IMC.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @PayDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
				FROM	IMC.dbo.PM20000 PM1
				WHERE	PM1.PostEddt <= @PayDate
						AND PM1.VendorId = @VendorId) TRN
	END

	IF @Company = 'NDS'
	BEGIN
		SELECT	@Balance = ISNULL(SUM(Amount - ApplyTo), 0)
		FROM	(
				SELECT	PM1.VendorId
						,PM1.DocAmnt * CASE WHEN DocType = 1 THEN 1 ELSE -1 END AS Amount
						,ApplyTo = ISNULL((SELECT SUM(ActualApplyToAmount) FROM NDS.dbo.PM30300 PM2 WHERE PM2.GLPostDt <= @PayDate AND PM1.DocNumbr = PM2.ApToDcNm AND PM1.VendorId = PM2.VendorId), 0)
				FROM	NDS.dbo.PM20000 PM1
				WHERE	PM1.PostEddt <= @PayDate
						AND PM1.VendorId = @VendorId) TRN
	END

	RETURN @Balance
END
