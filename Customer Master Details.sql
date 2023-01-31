SELECT GPC.CUSTNMBR,
             GPC.CUSTNAME,
             GPC.BALNCTYP AS 'Balance Type',
             IIF(GPC.BALNCTYP = 0, 'Open Item', 'Balance Forward') AS 'Balance Type - Value',
             GPC.FNCHATYP AS 'Finance Type',
             CASE GPC.FNCHATYP WHEN 0 THEN 'None' WHEN 1 THEN 'Percent' ELSE 'Amount' END AS 'Finance Type - Value',
             GPC.MINPYTYP AS 'Minimum Payment',
             CASE GPC.MINPYTYP WHEN 0 THEN 'No Minimum' WHEN 1 THEN 'Percent' ELSE 'Amount' END AS 'Minimum Payment - Value',
             GPC.CRLMTTYP AS 'Credit Limit',
             CASE GPC.CRLMTTYP WHEN 0 THEN 'No Credit' WHEN 1 THEN 'Unlimited' ELSE 'Amount' END AS 'Credit Limit - Value',
             GPC.CRLMTAMT AS 'Credit Limit Amount',
             GPC.MXWOFTYP AS 'Maximum Writeoff',
             CASE GPC.CRLMTTYP WHEN 0 THEN 'Not Allowed' WHEN 1 THEN 'Unlimited' ELSE 'Maximum' END AS 'Maximum Writeoff - Value',
             GPC.MXWROFAM AS 'Maximum Writeoff Amount',
             GPC.Revalue_Customer,
             GPC.Post_Results_To,
             IIF(GPC.Post_Results_To = 0, 'Receivables/Discount Acct', 'Sales Offset Acct') AS 'Post_Results_To_Amount',
             GPC.TAXEXMT1 AS 'Tax Exempt 1',
             GPC.TAXEXMT2 AS 'Tax Exempt 2',
             GPC.TXRGNNUM AS 'Tax Registration',
             GPC.STMTCYCL AS 'Statement Cycle',
             CASE GPC.STMTCYCL WHEN 1 THEN 'No statement'
                                   WHEN 2 THEN 'Weekly'
                                   WHEN 3 THEN 'Biweekly'
                                   WHEN 4 THEN 'Semimonthly'
                                   WHEN 5 THEN 'Monthly'
                                   WHEN 6 THEN 'Bimonthly'
                                   ELSE 'Quarterly' END AS 'Statement Cycle -  Value',
             EML.StringValues,
             CMA.InvoiceEmailOption
FROM   RM00101 GPC CROSS APPLY (SELECT RTRIM(R6.Email_Recipient) + ';' 
              FROM RM00106 R6 WHERE R6.CUSTNMBR = GPC.CUSTNMBR ORDER BY R6.Email_Recipient FOR XML PATH('')) EML (StringValues)
             LEFT JOIN GPCustom.dbo.CustomerMaster CMA ON DB_NAME() = CMA.CompanyId AND GPC.CUSTNMBR = CMA.CUSTNMBR
