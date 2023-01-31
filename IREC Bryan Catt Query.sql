SELECT	b.pk_id AS "Batch_pk_id"
       ,b.batch_id AS "BatchId"
       ,b.batch_status AS "BatchStatus"
       ,CASE b.batch_status
              WHEN 1 THEN 'READY_TO_INTEGRATE'
              WHEN 2 THEN 'WAITING_POSTING'
              WHEN 3 THEN 'EXCEPTIONS_FOUND'
              WHEN 4 THEN 'COMPLETE'
              WHEN 5 THEN 'WAITING_IC_STAGE1'
              WHEN 6 THEN 'WAITING_IC_STAGE2'
              WHEN 7 THEN 'MISSING_PAYMENTS'
              WHEN 8 THEN 'READY_TO_APPLY'
              WHEN 9 THEN 'ERRORED'
              ELSE 'Unknown/Invalid'
              END AS "BatchStatusDescription"
       ,CONVERT(date,b.created_date) AS "BatchCreated"
       ,IIF(b.integrated=1,'Yes','No') AS "Integrated"
       ,IIF(b.posted=1,'Yes','No') AS "Posted"
       ,IIF(b.applied=1,'Yes','No') AS "Applied"
       ,IIF(b.errored=1,'Yes','No') AS "Errored"
       ,ISNULL(b.error_message,'') AS "BatchErrorMessage"
       ,ISNULL(b.apply_from,'') AS "ApplyFrom"
       ,CASE
              WHEN r.account_number IN ('745922','10330','010330','842826','412996','745926','745924','505574','743001') THEN 'LockBox' -- the various lock box identifiers... not in GP anywhere
              WHEN a.BnkActNm IS NOT NULL THEN 'BankAccount'
              ELSE ''
              END AS "HitType"
       ,ISNULL(a.Company,'') AS "BankCompany"
       ,ISNULL(a.ChekBkId,'') AS "BankCheckBook"
       ,ISNULL(a.BnkActNm,'') AS "BankAccount"
       ,ISNULL(a.ActNumSt,'') AS "GPAccount"
       ,CASE
              WHEN a.Inactive IS NULL THEN ''
              WHEN a.Inactive = 0 THEN 'Active'
              ELSE 'Inactive'
              END AS "AccountStatus"
       ,CASE r.account_number
              WHEN '745922' THEN 'AIS'
              WHEN '10330'  THEN 'DNJ'
			  WHEN '010330' THEN 'DNJ'
              WHEN '842826' THEN 'GIS'
              WHEN '412996' THEN 'HMIS'
              WHEN '745926' THEN 'IMNCA'
              WHEN '745924' THEN 'IMCG'
              WHEN '505574' THEN 'OIS'
              WHEN '743001' THEN 'PDS'
              ELSE ''
              END AS "LockBoxCompany"
       ,CASE
              WHEN LEN(LTRIM(RTRIM(r.account_number))) < 7 
              THEN r.account_number
              ELSE ''
              END AS "LockBox"
       ,CASE r.account_number
              WHEN '745922' THEN '000000745922'
              WHEN '10330'  THEN '000010330000'
			  WHEN '010330' THEN '000010330000'
              WHEN '842826' THEN '000842826000'
              WHEN '412996' THEN '000412996000'
              WHEN '745926' THEN '000000745926'
              WHEN '745924' THEN '000000745924'
              WHEN '505574' THEN '000505574000'
              WHEN '743001' THEN '000743001000'
              ELSE ''
              END AS "LockBoxBAIreference"
       ,r.pk_id AS "Detail_pk_id"
       ,CONVERT(date,r.payment_date) AS "PaymentDate"
       ,r.payment_number AS "PaymentNumber"
       ,r.payment_method AS "PaymentMethod"
       ,r.account_number AS "DetailAccount"
       ,r.currency AS "Currency"
       ,r.deposit_amount AS "DepositAmount"
       ,r.company AS "DetailCompany"
       ,r.customer AS "Customer"
       ,ISNULL(c.CustName,'') AS "CustomerName"
       ,ISNULL(c.CPRCSTNM,'') AS "Parent"
       ,IIF(c.CPRCSTNM<>'',p.CustName,'') AS "ParentName"
       ,r.reference_field AS "Reference"
       ,r.original_reference AS "OriginalReference"
       ,r.validation_status AS "DetailValidationStatus"
       ,CASE r.validation_status
              WHEN -1 THEN 'WAITING_VALIDATION'
              WHEN 1  THEN 'INVALID_CUSTOMER'
              WHEN 2  THEN 'INVALID_PAYMENT_NUMBER'
              WHEN 3  THEN 'INVALID_PAYMENT_AMT'
              WHEN 4  THEN 'INVALID_COMPANY'
              WHEN 5  THEN 'INVALID_INVOICE_NUM'
              WHEN 6  THEN 'INVALID_PAYMENT_DATE'
              WHEN 7  THEN 'VALID'
              WHEN 8  THEN 'INVALID_MULTIPLE'
              WHEN 9  THEN 'READY_TO_INTEGRATE'
              WHEN 10 THEN 'MISSING_OPEN_TRX'
              ELSE 'Unknown/Invalid'
              END AS "DetailValidationStatusDescription"
       ,ISNULL(r.payment_amount,'0') AS "PaymentAmount"
       ,ISNULL(r.open_balance,'0') AS "OpenBalance"
       ,ISNULL(r.difference,'0') AS "Difference"
       ,ISNULL(r.discount,'0') AS "Discount"
       ,IIF(r.integrated_gp=1,'Yes','No') AS "IntegratedToGP"
       ,IIF(r.cash_receipt=1,'Yes','No') AS "CashReceipt"
       ,IIF(r.unapplied_cash=1,'No','Yes') AS "UnappliedCash"
       ,r.exceptions AS "ExceptionCount"
       ,r.exception_text AS "ExceptionMessage"
       ,CONVERT(date,r.created_date) AS "DetailCreated"
       ,r.created_by AS "DetailCreatedBy"
FROM	IntelligentReceivablesRaw r WITH (NOLOCK)
		LEFT OUTER JOIN IntelligentReceivablesBatches b WITH (NOLOCK) ON r.batch_id = b.batch_id
		LEFT OUTER JOIN Companies CPY WITH (NOLOCK) ON r.Company = ISNULL(CPY.CompanyAlias, CPY.CompanyId) AND CPY.IsTest = 0
		LEFT OUTER JOIN GP_Bank_Accounts a WITH (NOLOCK) ON CPY.CompanyId = a.Company AND r.account_number = a.BnkActNm
		LEFT OUTER JOIN CustomerMaster c WITH (NOLOCK) ON CPY.CompanyId = c.CompanyId AND r.Customer = c.CustNmbr
		LEFT OUTER JOIN CustomerMaster p WITH (NOLOCK) ON CONCAT(p.CompanyId, p.CustNmbr) = CONCAT(c.CompanyId, c.CPRCSTNM) AND p.CustNmbr <> ''
--WHERE r.company = 'OIS' AND r.account_number LIKE '%505574%'
--WHERE b.batch_status <> '4'
--     AND b.created_date > '11/24/2022'
WHERE b.created_date IS NOT NULL
ORDER BY b.created_date DESC
