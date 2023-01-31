select	*
from	EscrowTransactions
where	companyid = 'OIS'
		and AccountNumber = '0-00-1105'
		and abs(Amount) = 370.50

update	EscrowTransactions
set		DriverId = '',
		ProNumber = 'NMCOMOM035249'
where	companyid = 'OIS'
		and AccountNumber = '0-00-1105'
		and abs(Amount) = 370.50

update	EscrowTransactions
set		PostingDate = TransactionDate
where	companyid = 'OIS'
		and AccountNumber = '0-00-1105'
		and abs(Amount) = 370.50
		and PostingDate is null
		