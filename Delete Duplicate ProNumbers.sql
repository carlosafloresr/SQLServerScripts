SELECT * FROM EscrowTransactions where RIGHT(VoucherNumber, 4) = '7175'
select * from Purchasing_Vouchers where vouchernumber = '3824A'
delete Purchasing_Vouchers where voucherlineid in (415,417)
EXECUTE USP_Report_EscrowDetailTrialBalance 'AIS', 5, '0-00-1102', '07/01/2007', '11/03/2007', NULL, 'CFLORES', 2