DECLARE	@DocumentFrom	Varchar(30) = 'DD000002879',
		@DocumentTo		Varchar(30)

DECLARE	@tblData		Table (
		VendorId		Varchar(15),
		VendorName		Varchar(50),
		Address1		Varchar(75),
		Address2		Varchar(75),
		CityStateZip	Varchar(50),
		Voucher			Varchar(30),
		DocumentNumber	Varchar(30),
		DocumentDate	Date,
		ApplyDocument	Varchar(30),
		ApplyDocDate	Date,
		ApplyVoucher	Varchar(30),
		ApplyAmount		Numeric(10,2),
		ApplyPaid		Numeric(10,2))

SET NOCOUNT ON

SELECT	@DocumentTo = APTODCNM
FROM	PM30300
WHERE	APFRDCNM  = @DocumentFrom

INSERT INTO @tblData
SELECT	PMT.VENDORID,
		VND.VENDNAME,
		VND.ADDRESS1,
		VND.ADDRESS2,
		RTRIM(VND.CITY) + ', ' + RTRIM(VND.STATE) + ', ' + RTRIM(VND.ZIPCODE) AS CSZIP,
		PMT.VCHRNMBR,
		PMT.DOCNUMBR,
		PMT.DOCDATE,
		PMA.APTODCNM,
		PMA.DOCDATE AS APTODOCDATE,
		PMA.VCHRNMBR AS APTOVOUCHER,
		PMA.APFRMAPLYAMT * IIF(PMA.DOCTYPE = 5, -1, 1) AS APPLYAMOUNT,
		PMA.APFRMAPLYAMT * IIF(PMA.DOCTYPE = 5, 0, 1) AS APPLYPAID
FROM	PM30200 PMT
		INNER JOIN PM00200 VND ON PMT.VENDORID = VND.VENDORID
		INNER JOIN PM30300 PMA ON PMT.VENDORID = PMA.VENDORID AND PMA.APTODCNM = @DocumentTo --AND PMA.DOCTYPE <> 6
WHERE	PMT.DOCNUMBR = @DocumentFrom
		
UPDATE	@tblData
SET		ApplyAmount = (SELECT SUM(ABS(ApplyAmount)) FROM @tblData)
WHERE	ApplyAmount > 0

SELECT	*
FROM	@tblData

/*
SELECT	*
FROM	PM30300
WHERE	VENDORID = '1060'
		AND (APFRDCNM IN ('DD000002879','DPY1060_0382804','DPY1060_0381643')
		OR APTODCNM IN ('DD000002879','DPY1060_0382804'))
ORDER BY APFRDCNM
*/