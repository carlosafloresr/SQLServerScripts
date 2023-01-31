DECLARE @tbldata Table (Invoice Varchar(15))

INSERT INTO @tbldata
EXECUTE USP_IntercompanyInvoices

DELETE Staging.MSR_Import where inv_no in (select 'I' + Invoice from @tbldata where Invoice < '1785756') AND import_date > '01/01/2020'