SELECT      CHK.BACHNUMB
            ,CPY.CmpnyNam AS Company
            ,CAST(PER.Year1 AS Char(4)) + '-' + CAST(PER.PERIODID AS Char(2)) AS Period
            ,CHK.DOCNUMBR AS CheckNumber
            ,CHK.DOCDATE AS CheckDate
            ,CHK.POSTEDDT AS EffectiveDate
            ,CHK.DOCAMNT AS CheckAmount
            ,CHK.PTDUSRID AS UserId
            ,APL.VENDORID
            ,VND.VENDNAME
            ,PMH.PORDNMBR AS PONumber
            ,'' AS SystemSource
            ,APL.APTVCHNM
            ,APL.APTODCNM AS PaidInvoice 
            ,APL.APFRMAPLYAMT AS PaidAmount
            ,PMH.VCHRNMBR AS Voucher
            ,PMH.DOCNUMBR AS InvoiceNumber
            ,PMH.DOCDATE AS InvoiceDate
            ,PMH.DUEDATE AS InvoiceDueDate
            ,PMH.DOCAMNT AS InvoiceAmount
            ,PMH.POSTEDDT AS InvoiceEffectiveDate
            ,VOU.TrailerNumber AS Container
            ,VOU.ProNumber
            ,VOU.ChassisNumber
            ,GLA.ACTNUMST AS GLAccount
            ,GLB.ACTDESCR AS GLAcctName
            ,PMD.DEBITAMT AS DebitAmount
            ,PMD.DistRef AS Reference
FROM  PM30200 CHK
        INNER JOIN PM30300 APL ON CHK.DOCNUMBR = APL.APFRDCNM
        INNER JOIN PM00200 VND ON CHK.VENDORID = VND.VENDORID
        INNER JOIN SY40100 PER ON CHK.POSTEDDT BETWEEN PER.PERIODDT AND PER.PERDENDT AND PER.Series = 2 AND PER.ODESCTN = 'General Entry'
        INNER JOIN Dynamics..SY01500 CPY ON CPY.InterId = DB_NAME()
            LEFT JOIN PM30200 PMH ON APL.APTODCNM = PMH.DOCNUMBR
            INNER JOIN PM30600 PMD ON PMH.VCHRNMBR = PMD.VCHRNMBR AND PMH.TRXSORCE = PMD.TRXSORCE AND PMD.DEBITAMT > 0
            INNER JOIN GL00105 GLA ON PMD.DSTINDX = GLA.ACTINDX
            INNER JOIN GL00100 GLB ON GLA.ACTINDX = GLB.ACTINDX
            LEFT JOIN GPCustom.dbo.Purchasing_Vouchers VOU ON PMH.VCHRNMBR = VOU.VoucherNumber AND VOU.Source = 'AP'
WHERE CHK.DOCTYPE = 6 
        AND CHK.BACHNUMB = 'DSDR022312DD'
ORDER BY
            CHK.DOCNUMBR
