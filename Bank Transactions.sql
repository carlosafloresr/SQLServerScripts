SELECT  X.CHEKBKID 'Checkbook ID',
        CMRECNUM 'CM ReconNumber' ,
        CMTrxNum 'CM Transaction Number',
           TRXDATE AS 'CM Transactin Date',
           CASE X.VOIDED
              WHEN 1 THEN 'Yes'
              WHEN 0 THEN 'No'
           END AS 'Voided',
           CMTRXTPE 'CM Transaction Type',
           paidtorcvdfrom 'Paid To/Received From',
           DSCRIPTN 'Description',
           JRNENTRY 'Journal Entry',
           DEBITAMT 'Debit Amount',
           CRDTAMNT 'Credit Amount'
FROM
          ( SELECT A.CHEKBKID ,
                B.ACTINDX ,
                A.CMRECNUM ,
                            A.sRecNum ,
                            A.CMTrxNum ,
                            A.TRXDATE ,
                            CASE A.CMTrxType
                                   WHEN 1 THEN 'Deposit'
                                   WHEN 3 THEN 'Check'
                                   WHEN 4 THEN 'Withdrawal'
                                   WHEN 5 THEN 'Increase Adjustment'
                                   WHEN 6 THEN 'Decrease Adjustment'
                                   WHEN 7 THEN 'Transfer'
                                   ELSE ''
                            END AS CMTRXTPE ,
                            A.paidtorcvdfrom ,
                            CASE 
                                    WHEN A.DSCRIPTN = ' '
                                AND A.CMTrxType <> 7
                                     THEN 'Bank Transaction Entry'
                                    WHEN A.DSCRIPTN = ' '
                                    AND A.CMTrxType = 7 
                     THEN 'Bank Transfer Entry'
                                     ELSE A.DSCRIPTN
                            END AS DSCRIPTN ,
                            A.AUDITTRAIL ,
                            A.SRCDOCNUM ,
                            A.VOIDED
                            FROM   CM20200 AS A
                LEFT OUTER JOIN dbo.CM00100 AS B 
                ON A.CHEKBKID = B.CHEKBKID
                UNION ALL
                SELECT    A.CHEKBKID ,
                B.ACTINDX ,
                A.CMRECNUM ,
                A.sRecNum ,
                A.RCPTNMBR ,
                A.RECEIPTDATE ,
                CASE A.RcpType
                                    WHEN 1 THEN 'ReceiptCheck'
                                    WHEN 2 THEN 'ReceiptCash'
                                    WHEN 3 THEN 'ReceiptCreditCard'
                                    ELSE ''
                END AS ReceiptType ,
                A.RcvdFrom ,
                CASE A.DSCRIPTN
                                    WHEN ' ' THEN 'Bank Transaction Entry'
                                    ELSE A.DSCRIPTN
                END AS DSCRIPTN ,
                A.AUDITTRAIL ,
                A.SRCDOCNUM ,
                A.VOIDED
                FROM   dbo.CM20300 AS A
                LEFT OUTER JOIN dbo.CM00100 AS B 
                ON A.CHEKBKID = B.CHEKBKID
                ) AS X
                LEFT OUTER JOIN 
                ( SELECT  A.JRNENTRY ,
                          A.DEBITAMT ,
                          A.CRDTAMNT ,
                          A.ACTINDX ,
                          B.CHEKBKID ,
                          A.REFRENCE ,
                          A.SOURCDOC ,
                          A.ORGNTSRC ,
                          A.ORMSTRNM ,
                          A.ORMSTRID ,
                          A.ORDOCNUM ,
                          A.ORTRXSRC ,
                          A.VOIDED
                          FROM   
                          ( SELECT JRNENTRY ,
                                   DEBITAMT ,
                                   CRDTAMNT ,
                                   ACTINDX ,
                                   REFRENCE ,
                                   SOURCDOC ,
                                   ORGNTSRC ,
                                   ORMSTRNM ,
                                   ORMSTRID ,
                                   ORDOCNUM ,
                                   ORTRXSRC ,
                                   VOIDED
                                   FROM   dbo.GL20000
                                   UNION ALL
                                   SELECT JRNENTRY ,
                                   DEBITAMT ,
                                   CRDTAMNT ,
                                   ACTINDX ,
                                   REFRENCE ,
                                   SOURCDOC ,
                                   ORGNTSRC ,
                                   ORMSTRNM ,
                                   ORMSTRID ,
                                   ORDOCNUM ,
                                   ORTRXSRC ,
                                   VOIDED
                                   FROM   dbo.GL30000
                                   ) AS A
                                   LEFT OUTER JOIN dbo.CM00100 AS B 
                                   ON A.ACTINDX = B.ACTINDX
                                   ) AS Y 
                                   ON ( 
                                   X.ACTINDX = Y.ACTINDX
                                   AND X.DSCRIPTN = Y.REFRENCE
                                   AND X.CHEKBKID = Y.ORMSTRID
                                   AND X.AUDITTRAIL = Y.ORGNTSRC
                                   AND X.AUDITTRAIL = Y.ORTRXSRC
                                   AND X.CMTrxNum = Y.ORDOCNUM
                                   AND X.CMTRXTPE IN 
                                   ( 'Increase Adjustment',
                                                    'Decrease Adjustment',
                                                    'Check', 'Withdrawal',
                                                    'ReceiptCheck','ReceiptCash',
                                                    'ReceiptCreditCard' 
                                   )
                                   )
                                   OR     
                                   (   
                                       X.ACTINDX = Y.ACTINDX
                                                 AND X.DSCRIPTN = Y.REFRENCE
                                                 AND X.AUDITTRAIL = Y.ORTRXSRC
                                                 AND X.CMTrxNum = Y.ORDOCNUM
                                                 AND X.CMTRXTPE = 'Transfer'
                                                 )
WHERE   
ISNULL(X.AUDITTRAIL, 0) LIKE 'CMT%' OR
ISNULL(X.AUDITTRAIL, 0) LIKE 'CMX%'