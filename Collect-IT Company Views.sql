/*
Replace any [IMCMR] and 'IMCMR' reference for the new company code
*/
USE [IMCMR]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CollectITCustomerAddress]
AS
SELECT	'IMCMR' AS EnterpriseNumber
		,a.CUSTNMBR AS CustomerNumber
		,a.ADRSCODE AS ERPAddrID
		,CASE WHEN rtrim(isnull(a.CNTCPRSN, '')) = '' THEN c.CUSTNAME
			ELSE a.CNTCPRSN END AS ContactPerson
		,a.ADDRESS1
		,a.ADDRESS2
		,a.ADDRESS3
		,a.COUNTRY
		,a.CITY
		,a.STATE
		,a.ZIP AS ZipCode
		,a.PHONE1 AS CustomerPhone1
		,a.PHONE2 AS CustomerPhone2
		,a.PHONE3 AS CustomerPhone3
		,a.FAX AS CustomerFax
		,Cast(a.DEX_ROW_TS AS DATETIME) AS ModifiedAddress
		,CASE WHEN rtrim(isnull(CAST(b.EmailToAddress AS NVARCHAR(max)), '')) = '' THEN CAST(b.INET1 AS NVARCHAR(max))
			ELSE CAST(b.EmailToAddress AS NVARCHAR(max)) END AS CustomerEmail
FROM	dbo.RM00102 a
		JOIN dbo.RM00101 c ON a.CUSTNMBR = c.CUSTNMBR
		LEFT JOIN SY01200 b ON a.CUSTNMBR = b.Master_ID AND a.ADRSCODE = b.ADRSCODE
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CollectITCustomers]
AS
SELECT	'IMCMR' AS EnterpriseNumber
		,rtrim(a.CUSTNMBR) AS CustomerNumber
		,rtrim(a.CUSTNAME) AS CustomerName
		,rtrim(a.CUSTCLAS) AS CustomerClassID
		,rtrim(b.CLASDSCR) AS CustomerClassDescription
		,rtrim(a.CNTCPRSN) AS ContactPerson
		,rtrim(a.SLPRSNID) AS SalesPersonID
		,rtrim(c.SLPRSNFN) AS SalesPersonFirst
		,rtrim(c.SPRSNSLN) AS SalesPersonLast
		,NULL AS SalesPersonEmail
		,rtrim(a.PYMTRMID) AS PaymentTerm
		,CASE a.CRLMTTYP
			WHEN 0 THEN 0
			WHEN 1 THEN 2147483647
			ELSE a.CRLMTAMT
			END AS CreditLimit
		,rtrim(a.SALSTERR) AS SalesTerritoryID
		,rtrim(d.SLTERDSC) AS SalesTerritoryDescription
		,rtrim(a.CREATDDT) AS CreatedDate
		,a.DEX_ROW_TS AS DateUpdate
		,CASE a.HOLD
			WHEN 1 THEN 1
			ELSE '0' END AS AccountStatus
		,NULL AS CustomerPriority
		,NULL AS CustomerCreditRating
		,NULL AS CreditUpdate
		,NULL AS DunBradStreet
		,NULL AS OptOut
		,NULL AS CeaseDesist
		,e.INET2 AS URL
		,NULL AS CreditControl
		,3 AS ContactMethod
		,NULL AS TimeZone
		,NULL AS CreditManager
		,TXRGNNUM AS TaxId
FROM	dbo.RM00101 AS a
		LEFT OUTER JOIN dbo.RM00201 AS b ON a.CUSTCLAS = b.CLASSID
		LEFT OUTER JOIN dbo.RM00301 AS c ON a.SLPRSNID = c.SLPRSNID
		LEFT OUTER JOIN dbo.RM00303 AS d ON a.SALSTERR = d.SALSTERR
		LEFT OUTER JOIN dbo.SY01200 AS e ON a.CUSTNMBR = e.Master_ID and a.ADRSCODE = e.ADRSCODE  and Master_Type = 'CUS'
WHERE	a.INACTIVE = 0
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CollectITInvoiceHeaders]
AS
SELECT a.DOCNUMBR AS InvoiceNum
    ,a.DOCDATE AS DocDate
    ,a.ORTRXAMT AS Amount
    ,a.TRXDSCRN AS TransactionDescription
    ,a.DUEDATE AS DueDate
    ,2 AS PaymentStatus
    ,'' AS PaidDate
    ,a.CUSTNMBR AS CustNum
    ,CASE
        WHEN b.CSTPONBR is null OR b.CSTPONBR = ''
            THEN a.CSPORNBR
        ELSE b.CSTPONBR
        END AS PurchaseOrderNum
    ,CASE a.RMDTYPAL
        WHEN 1
            THEN 'Invoice'
        WHEN 2
            THEN 'Scheduled Payments'
        WHEN 3
            THEN 'Debit Memo'
        WHEN 4
            THEN 'Finance Charge'
        WHEN 5
            THEN 'Service Repair'
        WHEN 6
            THEN 'Warranty'
        WHEN 7
            THEN 'Credit Memo'
        WHEN 8
            THEN 'Return'
        WHEN 9
            THEN 'Payment'
        END AS DocumentType
    ,'IMCMR' AS EnterpriseNum
    ,'' AS EntityNum
    --,case a.RMDTYPAL when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
    ,a.DEX_ROW_TS AS UpdateDate
    ,CASE
        WHEN b.PYMTRMID is null OR b.PYMTRMID = ''
            THEN a.PYMTRMID
        ELSE b.PYMTRMID
        END AS PaymentTerm
    ,CASE
        WHEN b.PRBTADCD is null OR b.PRBTADCD = ''
            THEN a.ADRSCODE
        ELSE b.PRBTADCD
        END AS ERPAddrIdBillTo
    ,CASE
        WHEN b.PRSTADCD is null OR b.PRSTADCD = ''
            THEN a.ADRSCODE
        ELSE b.PRSTADCD
        END AS ERPAddrIdShipTo
    ,b.ADDRESS1 AS Address1
    ,b.ADDRESS2 AS Address2
    ,b.ADDRESS3 AS Address3
    ,b.STATE AS STATE
    ,b.CITY AS City
    ,b.ZIPCODE AS ZipCode
    ,b.COUNTRY AS Country
    ,CASE
        WHEN b.SHIPMTHD is null OR b.SHIPMTHD = ''
            THEN a.SHIPMTHD
        ELSE b.SHIPMTHD
        END AS ShipMethod
    ,CASE 
        WHEN b.SLPRSNID = ''
            THEN '-1'
        WHEN b.SLPRSNID is null
            THEN CASE a.SLPRSNID
                WHEN '' THEN '-1'
                ELSE a.SLPRSNID END
        ELSE b.SLPRSNID
        END AS SalesPersonId
    ,c.SLPRSNFN AS SalesPersonFirst
    ,c.SPRSNSLN AS SalesPersonLast
    ,'' AS SalesPersonEmail
    ,b.DOCID AS InvoiceType
    ,CASE a.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM RM20101 a
LEFT OUTER JOIN SOP30200 b ON b.SOPNUMBE = a.DOCNUMBR
    AND b.PSTGSTUS = 2
    AND b.VOIDSTTS = 0
    AND b.SOPTYPE = 3
LEFT OUTER JOIN RM00301 c ON c.SLPRSNID = isnull(b.SLPRSNID, a.SLPRSNID)
LEFT OUTER JOIN
(Select APTODCNM, APTODCTY, SUM(APPTOAMT + ORDISTKN + ORWROFAM) as amount FROM
	(SELECT APFRDCTY, APFRDCNM, APTODCNM, APTODCTY, APPTOAMT, ORDISTKN, ORWROFAM FROM RM20201 UNION SELECT APFRDCTY, APFRDCNM, APTODCNM, APTODCTY, APPTOAMT, ORDISTKN, ORWROFAM FROM RM30201) app
	JOIN (select DOCNUMBR, RMDTYPAL from RM20101 UNION SELECT DOCNUMBR, RMDTYPAL from RM30101) pay1 ON app.APFRDCNM = pay1.DOCNUMBR AND app.APFRDCTY = pay1.RMDTYPAL
	Group by APTODCNM, APTODCTY
	) pay ON a.DOCNUMBR = pay.APTODCNM AND a.RMDTYPAL = pay.APTODCTY
--left outer join B3930200 d on d.SOPTYPE = b.SOPTYPE and d.SOPNUMBE = b.SOPNUMBE
--left outer join B3950001 e on e.DOCNUMBR = a.DOCNUMBR and e.RMDTYPAL = a.RMDTYPAL
WHERE (
        a.RMDTYPAL in (1,3,4,5,6)
        )
    AND a.VOIDSTTS NOT IN (
        1
        ,2
        ,3
        )
    AND (CURTRXAM <> 0 OR (pay.APTODCNM IS NOT NULL AND CURTRXAM = a.ORTRXAMT - pay.amount))

UNION ALL

SELECT a.DOCNUMBR AS InvoiceNum
    ,a.DOCDATE AS DocDate
    ,a.ORTRXAMT AS Amount
    ,a.TRXDSCRN AS TransactionDescription
    ,a.DUEDATE AS DueDate
    ,2 AS PaymentStatus
    ,'' AS PaidDate
    ,a.CUSTNMBR AS CustNum
    ,CASE
        WHEN b.CSTPONBR is null OR b.CSTPONBR = ''
            THEN a.CSPORNBR
        ELSE b.CSTPONBR
        END AS PurchaseOrderNum
    ,CASE a.RMDTYPAL
        WHEN 1
            THEN 'Invoice'
        WHEN 2
            THEN 'Scheduled Payments'
        WHEN 3
            THEN 'Debit Memo'
        WHEN 4
            THEN 'Finance Charge'
        WHEN 5
            THEN 'Service Repair'
        WHEN 6
            THEN 'Warranty'
        WHEN 7
            THEN 'Credit Memo'
        WHEN 8
            THEN 'Return'
        WHEN 9
            THEN 'Payment'
        END AS DocumentType
    ,'IMCMR' AS EnterpriseNum
    ,'' AS EntityNum
    --,case a.RMDTYPAL when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
    ,a.DEX_ROW_TS AS UpdateDate
    ,CASE
        WHEN b.PYMTRMID is null OR b.PYMTRMID = ''
            THEN a.PYMTRMID
        ELSE b.PYMTRMID
        END AS PaymentTerm
    ,CASE
        WHEN b.PRBTADCD is null OR b.PRBTADCD = ''
            THEN a.ADRSCODE
        ELSE b.PRBTADCD
        END AS ERPAddrIdBillTo
    ,CASE
        WHEN b.PRSTADCD is null OR b.PRSTADCD = ''
            THEN a.ADRSCODE
        ELSE b.PRSTADCD
        END AS ERPAddrIdShipTo
    ,b.ADDRESS1 AS Address1
    ,b.ADDRESS2 AS Address2
    ,b.ADDRESS3 AS Address3
    ,b.STATE AS STATE
    ,b.CITY AS City
    ,b.ZIPCODE AS ZipCode
    ,b.COUNTRY AS Country
    ,CASE
        WHEN b.SHIPMTHD is null OR b.SHIPMTHD = ''
            THEN a.SHIPMTHD
        ELSE b.SHIPMTHD
        END AS ShipMethod
    ,CASE 
        WHEN b.SLPRSNID = ''
            THEN '-1'
        WHEN b.SLPRSNID is null
            THEN CASE a.SLPRSNID
                WHEN '' THEN '-1'
                ELSE a.SLPRSNID END
        ELSE b.SLPRSNID
        END AS SalesPersonId
    ,c.SLPRSNFN AS SalesPersonFirst
    ,c.SPRSNSLN AS SalesPersonLast
    ,'' AS SalesPersonEmail
    ,b.DOCID AS InvoiceType
    ,CASE a.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM RM30101 a
LEFT OUTER JOIN SOP30200 b ON b.SOPNUMBE = a.DOCNUMBR
    AND b.PSTGSTUS = 2
    AND b.VOIDSTTS = 0
    AND b.SOPTYPE = 3
LEFT OUTER JOIN RM00301 c ON c.SLPRSNID = isnull(b.SLPRSNID, a.SLPRSNID)
LEFT OUTER JOIN
(Select APTODCNM, APTODCTY, SUM(APPTOAMT + ORDISTKN + ORWROFAM) as amount FROM
	(SELECT APFRDCTY, APFRDCNM, APTODCNM, APTODCTY, APPTOAMT, ORDISTKN, ORWROFAM FROM RM20201 UNION SELECT APFRDCTY, APFRDCNM, APTODCNM, APTODCTY, APPTOAMT, ORDISTKN, ORWROFAM FROM RM30201) app
	JOIN (select DOCNUMBR, RMDTYPAL from RM20101 UNION SELECT DOCNUMBR, RMDTYPAL from RM30101) pay1 ON app.APFRDCNM = pay1.DOCNUMBR AND app.APFRDCTY = pay1.RMDTYPAL
	Group by APTODCNM, APTODCTY
	) pay ON a.DOCNUMBR = pay.APTODCNM AND a.RMDTYPAL = pay.APTODCTY
--left outer join B3930200 d on d.SOPTYPE = b.SOPTYPE and d.SOPNUMBE = b.SOPNUMBE
--left outer join B3950001 e on e.DOCNUMBR = a.DOCNUMBR and e.RMDTYPAL = a.RMDTYPAL
WHERE (
        a.RMDTYPAL in (1,3,4,5,6)
        )
    AND a.VOIDSTTS NOT IN (
        1
        ,2
        ,3
        )
    AND (CURTRXAM <> 0 OR (pay.APTODCNM IS NOT NULL AND CURTRXAM = a.ORTRXAMT - pay.amount))

UNION ALL

SELECT a.DOCNUMBR AS InvoiceNum
    ,a.DOCDATE AS DocDate
    ,0 AS Amount
    ,a.TRXDSCRN AS TransactionDescription
    ,a.DUEDATE AS DueDate
    ,1 AS PaymentStatus
    ,'' AS PaidDate
    ,a.CUSTNMBR AS CustNum
    ,CASE
        WHEN b.CSTPONBR is null OR b.CSTPONBR = ''
            THEN a.CSPORNBR
        ELSE b.CSTPONBR
        END AS PurchaseOrderNum
    ,'Void' AS DocumentType
    ,'IMCMR' AS EnterpriseNum
    ,'' AS EntityNum
    --,case a.RMDTYPAL when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
    ,a.DEX_ROW_TS AS UpdateDate
    ,CASE
        WHEN b.PYMTRMID is null OR b.PYMTRMID = ''
            THEN a.PYMTRMID
        ELSE b.PYMTRMID
        END AS PaymentTerm
    ,CASE
        WHEN b.PRBTADCD is null OR b.PRBTADCD = ''
            THEN a.ADRSCODE
        ELSE b.PRBTADCD
        END AS ERPAddrIdBillTo
    ,CASE
        WHEN b.PRSTADCD is null OR b.PRSTADCD = ''
            THEN a.ADRSCODE
        ELSE b.PRSTADCD
        END AS ERPAddrIdShipTo
    ,b.ADDRESS1 AS Address1
    ,b.ADDRESS2 AS Address2
    ,b.ADDRESS3 AS Address3
    ,b.STATE AS STATE
    ,b.CITY AS City
    ,b.ZIPCODE AS ZipCode
    ,b.COUNTRY AS Country
    ,CASE
        WHEN b.SHIPMTHD is null OR b.SHIPMTHD = ''
            THEN a.SHIPMTHD
        ELSE b.SHIPMTHD
        END AS ShipMethod
    ,CASE 
        WHEN b.SLPRSNID = ''
            THEN '-1'
        WHEN b.SLPRSNID is null
            THEN CASE a.SLPRSNID
                WHEN '' THEN '-1'
                ELSE a.SLPRSNID END
        ELSE b.SLPRSNID
        END AS SalesPersonId
    ,c.SLPRSNFN AS SalesPersonFirst
    ,c.SPRSNSLN AS SalesPersonLast
    ,'' AS SalesPersonEmail
    ,b.DOCID AS InvoiceType
    ,CASE a.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM RM20101 a
LEFT OUTER JOIN SOP30200 b ON b.SOPNUMBE = a.DOCNUMBR
    AND b.PSTGSTUS = 2
LEFT OUTER JOIN RM00301 c ON c.SLPRSNID = isnull(b.SLPRSNID, a.SLPRSNID)
--left outer join B3930200 d on d.SOPTYPE = b.SOPTYPE and d.SOPNUMBE = b.SOPNUMBE
--left outer join B3950001 e on e.DOCNUMBR = a.DOCNUMBR and e.RMDTYPAL = a.RMDTYPAL
WHERE (
        a.RMDTYPAL in (1,3,4,5,6)
        )
    AND a.VOIDSTTS IN (
        1
        ,2
        ,3
        )

UNION ALL

SELECT a.DOCNUMBR AS InvoiceNum
    ,a.DOCDATE AS DocDate
    ,0 AS Amount
    ,a.TRXDSCRN AS TransactionDescription
    ,a.DUEDATE AS DueDate
    ,1 AS PaymentStatus
    ,'' AS PaidDate
    ,a.CUSTNMBR AS CustNum
    ,CASE
        WHEN b.CSTPONBR is null OR b.CSTPONBR = ''
            THEN a.CSPORNBR
        ELSE b.CSTPONBR
        END AS PurchaseOrderNum
    ,'Void' AS DocumentType
    ,'IMCMR' AS EnterpriseNum
    ,'' AS EntityNum
    --,case a.RMDTYPAL when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
    ,a.DEX_ROW_TS AS UpdateDate
    ,CASE
        WHEN b.PYMTRMID is null OR b.PYMTRMID = ''
            THEN a.PYMTRMID
        ELSE b.PYMTRMID
        END AS PaymentTerm
    ,CASE
        WHEN b.PRBTADCD is null OR b.PRBTADCD = ''
            THEN a.ADRSCODE
        ELSE b.PRBTADCD
        END AS ERPAddrIdBillTo
    ,CASE
        WHEN b.PRSTADCD is null OR b.PRSTADCD = ''
            THEN a.ADRSCODE
        ELSE b.PRSTADCD
        END AS ERPAddrIdShipTo
    ,b.ADDRESS1 AS Address1
    ,b.ADDRESS2 AS Address2
    ,b.ADDRESS3 AS Address3
    ,b.STATE AS STATE
    ,b.CITY AS City
    ,b.ZIPCODE AS ZipCode
    ,b.COUNTRY AS Country
    ,CASE
        WHEN b.SHIPMTHD is null OR b.SHIPMTHD = ''
            THEN a.SHIPMTHD
        ELSE b.SHIPMTHD
        END AS ShipMethod
    ,CASE 
        WHEN b.SLPRSNID = ''
            THEN '-1'
        WHEN b.SLPRSNID is null
            THEN CASE a.SLPRSNID
                WHEN '' THEN '-1'
                ELSE a.SLPRSNID END
        ELSE b.SLPRSNID
        END AS SalesPersonId
    ,c.SLPRSNFN AS SalesPersonFirst
    ,c.SPRSNSLN AS SalesPersonLast
    ,'' AS SalesPersonEmail
    ,b.DOCID AS InvoiceType
    ,CASE a.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM RM30101 a
LEFT OUTER JOIN SOP30200 b ON b.SOPNUMBE = a.DOCNUMBR
    AND b.PSTGSTUS = 2
LEFT OUTER JOIN RM00301 c ON c.SLPRSNID = isnull(b.SLPRSNID, a.SLPRSNID)
--left outer join B3930200 d on d.SOPTYPE = b.SOPTYPE and d.SOPNUMBE = b.SOPNUMBE
--left outer join B3950001 e on e.DOCNUMBR = a.DOCNUMBR and e.RMDTYPAL = a.RMDTYPAL
WHERE (
        a.RMDTYPAL in (1,3,4,5,6)
        )
    AND a.VOIDSTTS IN (
        1
        ,2
        ,3
        )
GO

/****** Object:  View [dbo].[CollectItInvoiceLines]    Script Date: 12/7/2016 9:36:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CollectItInvoiceLines]
AS
SELECT	A.SOPTYPE
		,A.InvoiceNum
		,A.LineNum
		,A.ItemNum
		,A.ItemDescription
		,A.UnitOfMeasure
		,A.UnitPrice
		,A.Tax
		,A.Quantity
		,A.PostingStatus
		,A.VoidStatus
		,A.EnterpriseNum
		,A.EntityNum
		,A.UpdateDate
FROM	(SELECT	b.SOPTYPE
				,b.SOPNUMBE AS InvoiceNum
				,LNITMSEQ AS LineNum
				,ITEMNMBR AS ItemNum
				,ITEMDESC AS ItemDescription
				,UOFM AS UnitOfMeasure
				,UNITPRCE AS UnitPrice
				,TAXAMNT AS Tax
				,QUANTITY AS Quantity
				,(SELECT	PSTGSTUS
				  FROM		dbo.SOP30200
				  WHERE		SOPNUMBE = b.SOPNUMBE
				 ) AS PostingStatus
				,(SELECT	VOIDSTTS
				  FROM		dbo.SOP30200 AS SOP30200_4
				  WHERE		SOPNUMBE = b.SOPNUMBE
				 ) AS VoidStatus
				,'IMCMR' AS EnterpriseNum
				,'' AS EntityNum
				,DEX_ROW_TS AS UpdateDate
		FROM	dbo.SOP30300 b
		UNION
		SELECT	b.SOPTYPE
				,b.SOPNUMBE AS InvoiceNum
				,(SELECT	MAX(LNITMSEQ) + 1 AS Expr1
				  FROM		dbo.SOP30300 AS SOP30300_3
				  WHERE		b.SOPNUMBE = SOPNUMBE
				 ) AS LineNum
				,'Freight' AS ItemNum
				,'' AS ItemDescription
				,'' AS UnitOfMeasure
				,FRTAMNT AS UnitPrice
				,FRTTXAMT AS Tax
				,1 AS Quantity
				,PSTGSTUS AS 'PostingStatus'
				,VOIDSTTS AS 'VoidStatus'
				,'IMCMR' AS EnterpriseNum
				,'' AS EntityNum
				,DEX_ROW_TS AS UpdateDate
		FROM	dbo.SOP30200 AS b
		WHERE	FRTAMNT > 0
		UNION
		SELECT	b.SOPTYPE
				,b.SOPNUMBE AS InvoiceNum
				,(SELECT	MAX(LNITMSEQ) + 2 AS Expr1
				  FROM		dbo.SOP30300 AS SOP30300_2
				  WHERE		b.SOPNUMBE = SOPNUMBE
				 ) AS LineNum
				,'Misc Charge' AS ItemNum
				,'' AS ItemDescription
				,'' AS UnitOfMeasure
				,MISCAMNT AS UnitPrice
				,MSCTXAMT AS Tax
				,1 AS Quantity
				,PSTGSTUS AS 'PostingStatus'
				,VOIDSTTS AS 'VoidStatus'
				,'IMCMR' AS EnterpriseNum
				,'' AS EntityNum
				,DEX_ROW_TS AS UpdateDate
		FROM	dbo.SOP30200 AS b
		WHERE	MISCAMNT > 0
		UNION
	    SELECT	b.SOPTYPE
				,b.SOPNUMBE AS InvoiceNum
				,(SELECT	MAX(LNITMSEQ) + 3 AS Expr1
				  FROM		dbo.SOP30300 AS SOP30300_1
				  WHERE		b.SOPNUMBE = SOPNUMBE
				 ) AS LineNum
				,'Discount' AS ItemNum
				,'' AS ItemDescription
				,'' AS UnitOfMeasure
				,TRDISAMT * - 1 AS UnitPrice
				,0 AS Tax
				,1 AS Quantity
				,PSTGSTUS AS 'PostingStatus'
				,VOIDSTTS AS 'VoidStatus'
				,'IMCMR' AS EnterpriseNum
				,'' AS EntityNum
				,DEX_ROW_TS AS UpdateDate
		FROM	dbo.SOP30200 AS b
		WHERE	TRDISAMT > 0
		) AS A
		LEFT OUTER JOIN dbo.RM20101 AS b ON b.DOCNUMBR = A.InvoiceNum
WHERE	A.VoidStatus = 0
		AND A.PostingStatus = 2
		AND b.CURTRXAM <> 0
		AND A.SOPTYPE = 3
UNION ALL
SELECT	rmdoc.RMDTYPAL
		,rmdoc.DOCNUMBR AS InvoiceNum
		,1 AS LineNum
		,'Freight' AS ItemNum
		,'' AS ItemDescription
		,'' AS UnitOfMeasure
		,rmdoc.FRTAMNT AS UnitPrice
		,rmdoc.TAXAMNT AS Tax
		,1 AS Quantity
		,PSTGSTUS AS 'PostingStatus'
		,rmdoc.VOIDSTTS AS 'VoidStatus'
		,'IMCMR' AS EnterpriseNum
		,'' AS EntityNum
		,CASE WHEN rmdoc.DEX_ROW_TS > lines.DEX_ROW_TS THEN rmdoc.DEX_ROW_TS
		      ELSE lines.DEX_ROW_TS
		 END AS UpdateDate
FROM	rm20101 rmdoc
		LEFT JOIN SOP30200 lines ON rmdoc.DOCNUMBR = lines.SOPNUMBE
WHERE	lines.SOPNUMBE IS NULL
		AND rmdoc.RMDTYPAL in (1,3,4,5,6)
		AND rmdoc.CURTRXAM <> 0
		AND rmdoc.VOIDSTTS NOT IN (1,2,3)
UNION
SELECT	rmdoc.RMDTYPAL
		,rmdoc.DOCNUMBR AS InvoiceNum
		,2 AS LineNum
		,'Misc Charge' AS ItemNum
		,'' AS ItemDescription
		,'' AS UnitOfMeasure
		,rmdoc.MISCAMNT AS UnitPrice
		,0 AS Tax
		,1 AS Quantity
		,PSTGSTUS AS 'PostingStatus'
		,rmdoc.VOIDSTTS AS 'VoidStatus'
		,'IMCMR' AS EnterpriseNum
		,'' AS EntityNum
		,CASE WHEN rmdoc.DEX_ROW_TS > lines.DEX_ROW_TS
			THEN rmdoc.DEX_ROW_TS
			ELSE lines.DEX_ROW_TS
		END AS UpdateDate
FROM	rm20101 rmdoc
		LEFT JOIN SOP30200 lines ON rmdoc.DOCNUMBR = lines.SOPNUMBE
WHERE	lines.SOPNUMBE IS NULL
		AND rmdoc.RMDTYPAL in (1,3,4,5,6)
		AND rmdoc.CURTRXAM <> 0
		AND rmdoc.VOIDSTTS NOT IN (1,2,3)
		AND rmdoc.MISCAMNT <> 0
UNION
SELECT	rmdoc.RMDTYPAL
		,rmdoc.DOCNUMBR AS InvoiceNum
		,3 AS LineNum
		,'Discount' AS ItemNum
		,'' AS ItemDescription
		,'' AS UnitOfMeasure
		,rmdoc.TRDISAMT * - 1 AS UnitPrice
		,0 AS Tax
		,1 AS Quantity
		,PSTGSTUS AS 'PostingStatus'
		,rmdoc.VOIDSTTS AS 'VoidStatus'
		,'IMCMR' AS EnterpriseNum
		,'' AS EntityNum
		,CASE WHEN rmdoc.DEX_ROW_TS > lines.DEX_ROW_TS THEN rmdoc.DEX_ROW_TS
			  ELSE lines.DEX_ROW_TS
		 END AS UpdateDate
FROM	rm20101 rmdoc
		LEFT JOIN SOP30200 lines ON rmdoc.DOCNUMBR = lines.SOPNUMBE
WHERE	lines.SOPNUMBE IS NULL
		AND rmdoc.RMDTYPAL in (1,3,4,5,6)
		AND rmdoc.CURTRXAM <> 0
		AND rmdoc.VOIDSTTS NOT IN (1,2,3)
		AND rmdoc.TRDISAMT <> 0
GO

USE [IMCMR]
GO

/****** Object:  View [dbo].[CollectitPayments]    Script Date: 3/5/2018 2:02:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CollectitPayments]
AS
SELECT TransactionNum
    ,InvoiceNum
    ,InvoiceDocumentType
    ,CustomerNum
    ,EnterpriseNum
    ,DocumentNum
    ,DocumentType
    ,PaymentMethod
    ,Amount
    ,PayDate
    ,editDate AS editDate
    ,EntityNum
    ,Currency
FROM (
    SELECT a.DOCNUMBR AS TransactionNum
        ,'' AS InvoiceNum
        ,'' AS InvoiceDocumentType
        ,a.CUSTNMBR AS CustomerNum
        ,'IMCMR' AS EnterpriseNum
        ,CASE CHEKNMBR
            WHEN ''
                THEN ''
            ELSE CHEKNMBR
            END AS DocumentNum
        ,CASE a.RMDTYPAL
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS DocumentType
        ,CASE CSHRCTYP
            WHEN 0
                THEN '2'
            WHEN 1
                THEN '4'
            WHEN 2
                THEN '1'
            ELSE '4'
            END AS PaymentMethod
        ,CURTRXAM AS Amount
        ,DOCDATE AS PayDate
        ,DEX_ROW_TS AS EditDate
        --, rtrim(d.BSSI_Facility_ID) AS EntityNum
        ,'' AS EntityNum
        ,CASE a.CURNCYID
            WHEN 'Z-US$'
                THEN 1
            WHEN 'Z-EURO'
                THEN 2
            WHEN 'Z-UK'
                THEN 3
            ELSE 1
            END Currency
    FROM rm20101 a
    --left outer join B3950001 d on d.docnumbr = a.docnumbr and d.RMDTYPAL = a.RMDTYPAL
    WHERE VOIDSTTS = '0'
        AND a.RMDTYPAL > 6
        AND curtrxam <> 0
    
    UNION ALL
    (
    SELECT rmdoc.DOCNUMBR AS TransactionNum
        ,rmapply.APTODCNM AS InvoiceNum
        ,CASE rmapply.APTODCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS InvoiceDocumentType
        ,rmdoc.CUSTNMBR AS CustomerNum
        ,'IMCMR' AS EnterpriseNum
        ,CASE rmdoc.CHEKNMBR
            WHEN ''
                THEN ''
            ELSE rmdoc.CHEKNMBR
            END AS DocumentNum
        ,CASE APFRDCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS DocumentType
        ,CASE rmdoc.CSHRCTYP
            WHEN 0
                THEN '2'
            WHEN 1
                THEN '4'
            WHEN 2
                THEN '1'
            ELSE '4'
            END AS PaymentMethod
        ,rmapply.APPTOAMT AS Amount
        ,rmdoc.DOCDATE AS PayDate
        ,rmdoc.DEX_ROW_TS AS EditDate
        ,'' AS EntityNum
        --,case rmapply.APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
        ,CASE rmdoc.CURNCYID
            WHEN 'Z-US$'
                THEN 1
            WHEN 'Z-EURO'
                THEN 2
            WHEN 'Z-UK'
                THEN 3
            ELSE 1
            END Currency
    FROM RM20101 rmdoc
    JOIN RM20201 rmapply ON rmdoc.DOCNUMBR = rmapply.APFRDCNM
        AND rmdoc.RMDTYPAL = rmapply.APFRDCTY
  --  JOIN RM20101 rminv ON rminv.DOCNUMBR = rmapply.APFRDCNM
		--AND rminv.RMDTYPAL = rmapply.APTODCTY
    --left outer join B3930200 d on d.SOPTYPE =b.SOPTYPE and d.SOPNUMBE = rmapply.APTODCNM
    --left outer join B3950001 e on e.DOCNUMBR = rmapply.APTODCNM and e.RMDTYPAL = rmapply.APTODCTY
    WHERE rmdoc.VOIDSTTS = '0'
		--AND rminv.CURTRXAM = 0
    --ttalley include HX start
    
    UNION
    
    SELECT rmapply.APFRDCNM AS TransactionNum
        ,rmapply.APTODCNM AS InvoiceNum
        ,CASE rmapply.APTODCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS InvoiceDocumentType
        ,rmdoc.CUSTNMBR AS CustomerNum
        ,'IMCMR' AS EnterpriseNum
        ,CASE rmdoc.CHEKNMBR
            WHEN ''
                THEN ''
            ELSE CHEKNMBR
            END AS DocumentNum
        ,CASE APFRDCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS DocumentType
        ,CASE rmdoc.CSHRCTYP
            WHEN 0
                THEN '2'
            WHEN 1
                THEN '4'
            WHEN 2
                THEN '1'
            ELSE '4'
            END AS PaymentMethod
        ,rmapply.APPTOAMT AS Amount
        ,rmdoc.DOCDATE AS PayDate
        ,rmdoc.DEX_ROW_TS AS EditDate
        ,'' AS EntityNum
        --,case rmapply.APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
        ,CASE rmdoc.CURNCYID
            WHEN 'Z-US$'
                THEN 1
            WHEN 'Z-EURO'
                THEN 2
            WHEN 'Z-UK'
                THEN 3
            ELSE 1
            END Currency
    FROM RM20101 rmdoc
    JOIN RM30201 rmapply ON rmdoc.DOCNUMBR = rmapply.APFRDCNM
        AND rmdoc.RMDTYPAL = rmapply.APFRDCTY
    --left outer join B3950001 d on d.docnumbr = rmdoc.docnumbr and d.RMDTYPAL = rmdoc.RMDTYPAL
    --left outer join B3930200 d on d.SOPTYPE =rmapply.APTODCTY and d.SOPNUMBE = rmapply.APTODCNM
    --left outer join B3950001 e on e.DOCNUMBR = rmapply.APTODCNM and e.RMDTYPAL = rmapply.APTODCTY
    WHERE CURTRXAM > 0
        AND VOIDSTTS = '0'
    
    UNION
    
    SELECT rmapply.APFRDCNM AS TransactionNum
        ,rmapply.APTODCNM AS InvoiceNum
        ,CASE rmapply.APTODCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS InvoiceDocumentType
        ,rmdoc.CUSTNMBR AS CustomerNum
        ,'IMCMR' AS EnterpriseNum
        ,CASE rmdoc.CHEKNMBR
            WHEN ''
                THEN ''
            ELSE rmdoc.CHEKNMBR
            END AS DocumentNum
        ,CASE APFRDCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS DocumentType
        ,CASE rmdoc.CSHRCTYP
            WHEN 0
                THEN '2'
            WHEN 1
                THEN '4'
            WHEN 2
                THEN '1'
            ELSE '4'
            END AS PaymentMethod
        ,rmapply.APPTOAMT AS Amount
        ,rmdoc.DOCDATE AS PayDate
        ,rmdoc.DEX_ROW_TS AS EditDate
        ,'' AS EntityNum
        --,case rmapply.APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
        ,CASE rmdoc.CURNCYID
            WHEN 'Z-US$'
                THEN 1
            WHEN 'Z-EURO'
                THEN 2
            WHEN 'Z-UK'
                THEN 3
            ELSE 1
            END Currency
    FROM RM30101 rmdoc
    JOIN RM20201 rmapply ON rmdoc.DOCNUMBR = rmapply.APFRDCNM
        AND rmdoc.RMDTYPAL = rmapply.APFRDCTY
  --  JOIN RM20101 rminv ON rminv.DOCNUMBR = rmapply.APFRDCNM
		--AND rminv.RMDTYPAL = rmapply.APTODCTY
    --left outer join B3930200 d on d.SOPTYPE =rmapply.APTODCTY and d.SOPNUMBE = rmapply.APTODCNM
    --left outer join B3950001 e on e.DOCNUMBR = rmapply.APTODCNM and e.RMDTYPAL = rmapply.APTODCTY
    WHERE rmdoc.VOIDSTTS = '0'
		--AND rminv.CURTRXAM = 0
    --ttalley include HX end
    
    UNION
    
    SELECT rmapply.APFRDCNM AS TransactionNum
        ,rmapply.APTODCNM AS InvoiceNum
        ,CASE rmapply.APTODCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS InvoiceDocumentType
        ,rmdoc.CUSTNMBR AS CustomerNum
        ,'IMCMR' AS EnterpriseNum
        ,CASE rmdoc.CHEKNMBR
            WHEN ''
                THEN ''
            ELSE CHEKNMBR
            END AS DocumentNum
        ,CASE APFRDCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS DocumentType
        ,CASE rmdoc.CSHRCTYP
            WHEN 0
                THEN '2'
            WHEN 1
                THEN '4'
            WHEN 2
                THEN '1'
            ELSE '4'
            END AS PaymentMethod
        ,rmapply.APPTOAMT AS Amount
        ,rmdoc.DOCDATE AS PayDate
        ,rmdoc.DEX_ROW_TS AS EditDate
        ,'' AS EntityNum
        --,case rmapply.APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
        ,CASE rmdoc.CURNCYID
            WHEN 'Z-US$'
                THEN 1
            WHEN 'Z-EURO'
                THEN 2
            WHEN 'Z-UK'
                THEN 3
            ELSE 1
            END Currency
    FROM RM30101 rmdoc
    JOIN RM30201 rmapply ON rmdoc.DOCNUMBR = rmapply.APFRDCNM
        AND rmdoc.RMDTYPAL = rmapply.APFRDCTY
    --left outer join B3930200 d on d.SOPTYPE =rmapply.APTODCTY and d.SOPNUMBE = rmapply.APTODCNM
    --left outer join B3950001 e on e.DOCNUMBR = rmapply.APTODCNM and e.RMDTYPAL = rmapply.APTODCTY
    WHERE VOIDSTTS = '0' 
    )
    UNION ALL
    
    SELECT APFRDCNM AS TransactionNum
        ,APTODCNM AS InvoiceNum
        ,CASE a.APTODCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS InvoiceDocumentType
        ,b.CUSTNMBR AS CustomerNum
        ,'IMCMR' AS EnterpriseNum
        ,CASE CHEKNMBR
            WHEN ''
                THEN ''
            ELSE CHEKNMBR
            END AS DocumentNum
        ,'Writeoff' AS DocumentType
        ,'5' AS PaymentMethod
        ,a.WROFAMNT AS Amount
        ,DOCDATE AS PayDate
        ,b.DEX_ROW_TS AS EditDate
        ,'' AS EntityNum
        --,case APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
        ,CASE a.CURNCYID
            WHEN 'Z-US$'
                THEN 1
            WHEN 'Z-EURO'
                THEN 2
            WHEN 'Z-UK'
                THEN 3
            ELSE 1
            END Currency
    FROM rm20201 a
    LEFT OUTER JOIN dbo.RM20101 AS b ON b.DOCNUMBR = a.APFRDCNM
        AND b.RMDTYPAL = a.APFRDCTY
    --left outer join B3930200 d on d.SOPTYPE =APTODCTY and d.SOPNUMBE = APTODCNM
    --left outer join B3950001 e on e.DOCNUMBR = APTODCNM and e.RMDTYPAL = APTODCTY
    WHERE b.WROFAMNT > 0

    UNION ALL
    
    SELECT APFRDCNM AS TransactionNum
        ,APTODCNM AS InvoiceNum
        ,CASE a.APTODCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS InvoiceDocumentType
        ,b.CUSTNMBR AS CustomerNum
        ,'IMCMR' AS EnterpriseNum
        ,CASE CHEKNMBR
            WHEN ''
                THEN ''
            ELSE CHEKNMBR
            END AS DocumentNum
        ,'Writeoff' AS DocumentType
        ,'5' AS PaymentMethod
        ,a.WROFAMNT AS Amount
        ,DOCDATE AS PayDate
        ,b.DEX_ROW_TS AS EditDate
        ,'' AS EntityNum
        --,case APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
        ,CASE a.CURNCYID
            WHEN 'Z-US$'
                THEN 1
            WHEN 'Z-EURO'
                THEN 2
            WHEN 'Z-UK'
                THEN 3
            ELSE 1
            END Currency
    FROM rm20201 a
    LEFT OUTER JOIN dbo.RM30101 AS b ON b.DOCNUMBR = a.APFRDCNM
        AND b.RMDTYPAL = a.APFRDCTY
    --left outer join B3930200 d on d.SOPTYPE =APTODCTY and d.SOPNUMBE = APTODCNM
    --left outer join B3950001 e on e.DOCNUMBR = APTODCNM and e.RMDTYPAL = APTODCTY
    WHERE b.WROFAMNT > 0

    UNION ALL
    
    SELECT APFRDCNM AS TransactionNum
        ,APTODCNM AS InvoiceNum
        ,CASE a.APTODCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS InvoiceDocumentType
        ,b.CUSTNMBR AS CustomerNum
        ,'IMCMR' AS EnterpriseNum
        ,CASE CHEKNMBR
            WHEN ''
                THEN ''
            ELSE CHEKNMBR
            END AS DocumentNum
        ,'Writeoff' AS DocumentType
        ,'5' AS PaymentMethod
        ,a.WROFAMNT AS Amount
        ,DOCDATE AS PayDate
        ,b.DEX_ROW_TS AS EditDate
        ,'' AS EntityNum
        --,case APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
        ,CASE a.CURNCYID
            WHEN 'Z-US$'
                THEN 1
            WHEN 'Z-EURO'
                THEN 2
            WHEN 'Z-UK'
                THEN 3
            ELSE 1
            END Currency
    FROM rm30201 a
    LEFT OUTER JOIN dbo.RM20101 AS b ON b.DOCNUMBR = a.APFRDCNM
        AND b.RMDTYPAL = a.APFRDCTY
    --left outer join B3930200 d on d.SOPTYPE =APTODCTY and d.SOPNUMBE = APTODCNM
    --left outer join B3950001 e on e.DOCNUMBR = APTODCNM and e.RMDTYPAL = APTODCTY
    WHERE b.WROFAMNT > 0

    UNION ALL
    
    SELECT APFRDCNM AS TransactionNum
        ,APTODCNM AS InvoiceNum
        ,CASE a.APTODCTY
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS InvoiceDocumentType
        ,b.CUSTNMBR AS CustomerNum
        ,'IMCMR' AS EnterpriseNum
        ,CASE CHEKNMBR
            WHEN ''
                THEN ''
            ELSE CHEKNMBR
            END AS DocumentNum
        ,'Writeoff' AS DocumentType
        ,'5' AS PaymentMethod
        ,a.WROFAMNT AS Amount
        ,DOCDATE AS PayDate
        ,b.DEX_ROW_TS AS EditDate
        ,'' AS EntityNum
        --,case APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
        ,CASE a.CURNCYID
            WHEN 'Z-US$'
                THEN 1
            WHEN 'Z-EURO'
                THEN 2
            WHEN 'Z-UK'
                THEN 3
            ELSE 1
            END Currency
    FROM rm30201 a
    LEFT OUTER JOIN dbo.RM30101 AS b ON b.DOCNUMBR = a.APFRDCNM
        AND b.RMDTYPAL = a.APFRDCTY
    --left outer join B3930200 d on d.SOPTYPE =APTODCTY and d.SOPNUMBE = APTODCNM
    --left outer join B3950001 e on e.DOCNUMBR = APTODCNM and e.RMDTYPAL = APTODCTY
    WHERE b.WROFAMNT > 0
    ) AS bb
WHERE (
        DocumentType = 'Payment'
        OR DocumentType = 'Credit Memo'
        OR DocumentType = 'Return'
        OR DocumentType = 'Writeoff'
        OR DocumentType = 'Scheduled Payments'
        )

UNION ALL

SELECT rmdoc.DOCNUMBR AS TransactionNum
    ,'' AS InvoiceNum
    ,'' AS InvoiceDocumentType
    ,rmdoc.CUSTNMBR AS CustomerNum
    ,'IMCMR' AS EnterpriseNum --TTCO
    ,CASE rmdoc.CHEKNMBR
        WHEN ''
            THEN ''
        ELSE CHEKNMBR
        END AS DocumentNum
    ,'Void ' + CASE rmdoc.RMDTYPAL
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS DocumentType
    ,CASE rmdoc.RMDTYPAL
        WHEN 0
            THEN '2'
        WHEN 1
            THEN '4'
        WHEN 2
            THEN '1'
        ELSE '5'
        END AS PaymentMethod
    ,'0.00' AS Amount
    ,VOIDDATE AS PayDate
    ,rmdoc.DEX_ROW_TS AS EditDate
    ,'' AS EntityNum --, rtrim(d.BSSI_Facility_ID) AS EntityNum
    ,CASE rmdoc.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM RM30101 rmdoc
--left outer join B3950001 d on d.docnumbr = rmdoc.docnumbr and d.RMDTYPAL = rmdoc.RMDTYPAL
WHERE VOIDSTTS IN (
        1
        ,2
        ,3
        )
    AND (
        rmdoc.RMDTYPAL > 6
        OR rmdoc.RMDTYPAL = 2
        )

UNION ALL

SELECT a.DOCNUMBR AS TransactionNum
    ,'' AS InvoiceNum
    ,'' AS InvoiceDocumentType
    ,a.CUSTNMBR AS CustomerNum
    ,'IMCMR' AS EnterpriseNum --TTCO
    ,'' AS DocumentNum
    ,'Void ' + CASE a.RMDTYPAL
            WHEN 1
                THEN 'Invoice'
            WHEN 2
                THEN 'Scheduled Payments'
            WHEN 3
                THEN 'Debit Memo'
            WHEN 4
                THEN 'Finance Charge'
            WHEN 5
                THEN 'Service Repair'
            WHEN 6
                THEN 'Warranty'
            WHEN 7
                THEN 'Credit Memo'
            WHEN 8
                THEN 'Return'
            WHEN 9
                THEN 'Payment'
            END AS DocumentType
    ,5 AS PaymentMethod
    ,0.00 AS Amount
    ,a.VOIDDATE AS PayDate
    ,a.DEX_ROW_TS AS EditDate
    ,'' AS EntityNum
    --, rtrim(d.BSSI_Facility_ID) AS EntityNum
    ,CASE a.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM RM20101 a
--LEFT OUTER JOIN SOP30200 b ON b.SOPNUMBE = a.DOCNUMBR
--    AND b.PSTGSTUS = 2
--left outer join B3930200 d on d.SOPTYPE = b.SOPTYPE and d.SOPNUMBE = b.SOPNUMBE
WHERE a.VOIDSTTS IN (
        1
        ,2
        ,3
        )
    AND (
        a.RMDTYPAL > 6
        OR a.RMDTYPAL = 2
        )
UNION ALL
SELECT APFRDCNM AS TransactionNum
    ,APTODCNM AS InvoiceNum
    ,CASE a.APTODCTY
        WHEN 1
            THEN 'Invoice'
        WHEN 2
            THEN 'Scheduled Payments'
        WHEN 3
            THEN 'Debit Memo'
        WHEN 4
            THEN 'Finance Charge'
        WHEN 5
            THEN 'Service Repair'
        WHEN 6
            THEN 'Warranty'
        WHEN 7
            THEN 'Credit Memo'
        WHEN 8
            THEN 'Return'
        WHEN 9
            THEN 'Payment'
        END AS InvoiceDocumentType
    ,b.CUSTNMBR AS CustomerNum
    ,'IMCMR' AS EnterpriseNum
    ,CASE CHEKNMBR
        WHEN ''
            THEN ''
        ELSE CHEKNMBR
        END AS DocumentNum
    ,'Discount' AS DocumentType
    ,'5' AS PaymentMethod
    ,a.DISTKNAM AS Amount
    ,DOCDATE AS PayDate
    ,b.DEX_ROW_TS AS EditDate
    ,'' AS EntityNum
    --,case APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
    ,CASE a.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM rm20201 a
LEFT OUTER JOIN dbo.RM20101 AS b ON b.DOCNUMBR = a.APFRDCNM
    AND b.RMDTYPAL = a.APFRDCTY
--left outer join B3930200 d on d.SOPTYPE =APTODCTY and d.SOPNUMBE = APTODCNM
--left outer join B3950001 e on e.DOCNUMBR = APTODCNM and e.RMDTYPAL = APTODCTY
WHERE a.DISTKNAM <> 0
    AND b.CUSTNMBR IS NOT NULL
UNION ALL
SELECT APFRDCNM AS TransactionNum
    ,APTODCNM AS InvoiceNum
    ,CASE a.APTODCTY
        WHEN 1
            THEN 'Invoice'
        WHEN 2
            THEN 'Scheduled Payments'
        WHEN 3
            THEN 'Debit Memo'
        WHEN 4
            THEN 'Finance Charge'
        WHEN 5
            THEN 'Service Repair'
        WHEN 6
            THEN 'Warranty'
        WHEN 7
            THEN 'Credit Memo'
        WHEN 8
            THEN 'Return'
        WHEN 9
            THEN 'Payment'
        END AS InvoiceDocumentType
    ,b.CUSTNMBR AS CustomerNum
    ,'IMCMR' AS EnterpriseNum
    ,CASE CHEKNMBR
        WHEN ''
            THEN ''
        ELSE CHEKNMBR
        END AS DocumentNum
    ,'Discount' AS DocumentType
    ,'5' AS PaymentMethod
    ,a.DISTKNAM AS Amount
    ,DOCDATE AS PayDate
    ,b.DEX_ROW_TS AS EditDate
    ,'' AS EntityNum
    --,case APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
    ,CASE a.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM rm20201 a
LEFT OUTER JOIN dbo.RM30101 AS b ON b.DOCNUMBR = a.APFRDCNM
    AND b.RMDTYPAL = a.APFRDCTY
--left outer join B3930200 d on d.SOPTYPE =APTODCTY and d.SOPNUMBE = APTODCNM
--left outer join B3950001 e on e.DOCNUMBR = APTODCNM and e.RMDTYPAL = APTODCTY
WHERE a.DISTKNAM <> 0
    AND b.CUSTNMBR IS NOT NULL
UNION ALL
SELECT APFRDCNM AS TransactionNum
    ,APTODCNM AS InvoiceNum
    ,CASE a.APTODCTY
        WHEN 1
            THEN 'Invoice'
        WHEN 2
            THEN 'Scheduled Payments'
        WHEN 3
            THEN 'Debit Memo'
        WHEN 4
            THEN 'Finance Charge'
        WHEN 5
            THEN 'Service Repair'
        WHEN 6
            THEN 'Warranty'
        WHEN 7
            THEN 'Credit Memo'
        WHEN 8
            THEN 'Return'
        WHEN 9
            THEN 'Payment'
        END AS InvoiceDocumentType
    ,b.CUSTNMBR AS CustomerNum
    ,'IMCMR' AS EnterpriseNum
    ,CASE CHEKNMBR
        WHEN ''
            THEN ''
        ELSE CHEKNMBR
        END AS DocumentNum
    ,'Discount' AS DocumentType
    ,'5' AS PaymentMethod
    ,a.DISTKNAM AS Amount
    ,DOCDATE AS PayDate
    ,b.DEX_ROW_TS AS EditDate
    ,'' AS EntityNum
    --,case APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
    ,CASE a.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM rm30201 a
LEFT OUTER JOIN dbo.RM30101 AS b ON b.DOCNUMBR = a.APFRDCNM
    AND b.RMDTYPAL = a.APFRDCTY
--left outer join B3930200 d on d.SOPTYPE =APTODCTY and d.SOPNUMBE = APTODCNM
--left outer join B3950001 e on e.DOCNUMBR = APTODCNM and e.RMDTYPAL = APTODCTY
WHERE a.DISTKNAM <> 0
    AND b.CUSTNMBR IS NOT NULL
UNION ALL
SELECT APFRDCNM AS TransactionNum
    ,APTODCNM AS InvoiceNum
    ,CASE a.APTODCTY
        WHEN 1
            THEN 'Invoice'
        WHEN 2
            THEN 'Scheduled Payments'
        WHEN 3
            THEN 'Debit Memo'
        WHEN 4
            THEN 'Finance Charge'
        WHEN 5
            THEN 'Service Repair'
        WHEN 6
            THEN 'Warranty'
        WHEN 7
            THEN 'Credit Memo'
        WHEN 8
            THEN 'Return'
        WHEN 9
            THEN 'Payment'
        END AS InvoiceDocumentType
    ,b.CUSTNMBR AS CustomerNum
    ,'IMCMR' AS EnterpriseNum
    ,CASE CHEKNMBR
        WHEN ''
            THEN ''
        ELSE CHEKNMBR
        END AS DocumentNum
    ,'Discount' AS DocumentType
    ,'5' AS PaymentMethod
    ,a.DISTKNAM AS Amount
    ,DOCDATE AS PayDate
    ,b.DEX_ROW_TS AS EditDate
    ,'' AS EntityNum
    --,case APTODCTY when 4 then rtrim(e.BSSI_Facility_ID) else rtrim(d.BSSI_Facility_ID) end AS EntityNum
    ,CASE a.CURNCYID
        WHEN 'Z-US$'
            THEN 1
        WHEN 'Z-EURO'
            THEN 2
        WHEN 'Z-UK'
            THEN 3
        ELSE 1
        END Currency
FROM rm30201 a
LEFT OUTER JOIN dbo.RM20101 AS b ON b.DOCNUMBR = a.APFRDCNM
    AND b.RMDTYPAL = a.APFRDCTY
--left outer join B3930200 d on d.SOPTYPE =APTODCTY and d.SOPNUMBE = APTODCNM
--left outer join B3950001 e on e.DOCNUMBR = APTODCNM and e.RMDTYPAL = APTODCTY
WHERE a.DISTKNAM <> 0
    AND b.CUSTNMBR IS NOT NULL
GO

