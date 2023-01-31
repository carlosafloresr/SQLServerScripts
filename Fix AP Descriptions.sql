-- select * from EscrowTransactions where AccountNumber = '0-00-1102' AND PostingDate = '08/30/2008'

select * from PM30200 where vendorid = '11084' and vchrnmbr = '00000000000009220'
select * from PM30600 where vchrnmbr = '00000000000009220'

select * from PM20000 where vendorid = '11084' and vchrnmbr = '00000000000010599'
select * from PM10100 where vchrnmbr = '00000000000010599'

update PM30600 set distref = '9523|RPL-RRI|SEP               ' where vchrnmbr = '00000000000009220' and dstsqnum = 16384
update PM10100 set distref = '9530|RPL - RRI|BLN             ' where vchrnmbr = '00000000000010599' and dstsqnum = 49152