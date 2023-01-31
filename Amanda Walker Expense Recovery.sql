select	*
from	EscrowTransactions
where	companyid = 'DNJ'
		and AccountNumber = '0-00-1104'
		--and TransactionDate between '01/01/2019' and '01/25/2019'
		and pronumber = '7200346003'
		--and (Amount in (3000, 3450, -3000, -3450)
		--or ProNumber = '754022240'
		--or InvoiceNumber = '754022240'
		--or sopdocumentnumber = '754022240')

update	EscrowTransactions
set		InvoiceNumber = '754022240'
where	companyid = 'DNJ'
		and AccountNumber = '0-00-1104'
		--and TransactionDate between '01/01/2019' and '01/25/2019'
		and pronumber = '7200346003'