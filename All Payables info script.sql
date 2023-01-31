                                                                                                                         /*********************************************************************************
** All Payables info script.  Includes all Payables tables as well as GL, including:	

**	Payables info:						
**	PM00400 -	PM Key Master						
**	PM10000 -	PM Transaction WORK					
**	PM10100 -	PM Distribution WORK OPEN	
**	PM10200 -	PM Apply To WORK OPEN
**	PM10201 -	PM Payment Apply To Work			
**	PM10300	-	PM Payment WORK				
**	PM10400 -	PM Manual Payment WORK	
**	PM10500 -	PM Tax Work	
**	PM20000 -	PM Transaction OPEN			
**	PM20100 -	PM Apply To OPEN OPEN Temporary		
**	PM20200 -	PM Distribution OPEN OPEN Temporary	
**	PM30200 -	PM Paid Transaction History		
**	PM30300 -	PM Apply to History			
**	PM30600 -	PM Distribution History			
**	PM30700 -	PM Tax History	
**	PM30800 -	PM Tax Invoices

**	Payables Void Temporary Tables:
**	PM10600 -	PM Distribution Void WORK Temporary		
**	PM10801 -	PM Payment Stub Duplicate	
**	PM10900 -	Void Payment WORK Temporary
**	PM10901 -	PM Void Transaction WORK Temporary
**	PM10902 -	PM Tax Void Work Temporary

** General Ledger:		
**	GL10000	-	Transaction Work
**	GL10001 -	Transaction Amounts Work
**	GL20000 -	Year-to-Date Transaction Open
**	GL30000 -	Account Transaction History

**Multicurrency:
**MC020103 -	Multicurrency Payables Transactions
**MC020105 -	Multicurrency RM Revaluation Activity

**Bank Reconcilation:
**CM20200 -		CM Transaction

Instructions:	
				
	Step 1. Replace 00000000000000447 with the document's Voucher/Payment Number for @VCHRNMBR. The Voucher/Payment Number can be seen from Inquiry> 
	Purchasing> Transaction by Vendor. Click the Show details button to view the Voucher/Payment Number. 


	Step 2. Enter the appropriate DOCTYPE Value for @DOCTYPE :
	1=Invoice
	2=Finance Charge
	3=Miscellaneous Charge
	4=Return
	5=Credit Memo
	6=Payment
 
	Step 3. Select the appropriate company database and click Execute.

GP VERSIONS: 10.0, 2010, 2013  

REVISION HISTORY:

Date          	Who             Comments
------------- 	--------------	------------------------------------------------
10/08/2014		amelroe			Modified select statement in relation to printing data for PM20100 table to pull from PM20100 instead of PM10201
								Modified select statement in relation to printing data for PM20200 table to pull from PM20200 instead of PM10100
								Modified select statement in relation to printing data for PM30700 table to pull from PM30700 instead of PM30200
06/09/2016		jnelson/amelroe Modified select statement in relation to printing data for PM10200 table to ensure correct doc type returned (added doc type to 'where clause')
06/09/2016		jnelson/amelroe Modified select statement in relation to printing data for PM30300 table to ensure correct doc type returned (added doc type to 'where clause')					
*********************************************************************************/

----------------------------------------------------------------------------------
declare @VCHRNMBR char(20)
declare @DOCTYPE smallint

select @VCHRNMBR = '00000000000102049'
select @DOCTYPE = '6'
----------------------------------------------------------------------------------

/*Payables info*/

print '=================================================================================='
print 'Payables info'
print '=================================================================================='
print ''
Begin

Begin
print 'PM00400 - PM Key Master'
	select * from PM00400 where CNTRLNUM = @VCHRNMBR and DOCTYPE=@DOCTYPE
End

Begin
print 'PM10000 - PM Transaction WORK'
	select * from PM10000 where VCHNUMWK = @VCHRNMBR and DOCTYPE=@DOCTYPE
End

Begin
	print 'PM10100 - PM Distribution WORK OPEN'
	
if @DOCTYPE <=5 (select * from PM10100 where VCHRNMBR = @VCHRNMBR and CNTRLTYP=0)
if @DOCTYPE	 =6 (select * from PM10100 where VCHRNMBR = @VCHRNMBR and CNTRLTYP=1)
	End 

Begin 
	print 'PM10200 - PM Apply To WORK OPEN'
if @DOCTYPE <=3 (Select * from PM10200 where APTVCHNM=@VCHRNMBR AND APTODCTY = @DOCTYPE) /*jnelson amelroe 06/20/2016*/
if @DOCTYPE >=4 (select * from PM10200 where VCHRNMBR=@VCHRNMBR AND DOCTYPE = @DOCTYPE) /*jnelson amelroe 06/9/2016*/
	End

Begin 
	print 'PM10201 - PM Payment Apply To Work'
if @DOCTYPE <=3 (Select * from PM10201 where APTVCHNM=@VCHRNMBR)
if @DOCTYPE  =6 (select * from PM10201 where PMNTNMBR = @VCHRNMBR)
	End

Begin 
if @DOCTYPE = 6 
	print 'PM10300 - PM Payment WORK'
if @DOCTYPE = 6 (Select * from PM10300 where PMNTNMBR=@VCHRNMBR)
	End

Begin 
if @DOCTYPE = 6 
	print 'PM10400 - PM Manual Payment WORK'
if @DOCTYPE = 6 (Select * from PM10400 where PMNTNMBR=@VCHRNMBR)
	End

Begin 
	print 'PM10500 - PM Tax Work'
	Select * from PM10500 where VCHRNMBR=@VCHRNMBR
	End

Begin
print 'PM20000 - PM Transaction Open'
	select * from PM20000 where VCHRNMBR = @VCHRNMBR and DOCTYPE=@DOCTYPE
End

Begin
print 'PM20100 - PM Apply To OPEN OPEN Temporary'
	if @DOCTYPE <=3 (Select * from PM20100 where APTVCHNM=@VCHRNMBR)      /*amelroe 10/08/2014*/
	if @DOCTYPE >=4 (select * from PM20100 where VCHRNMBR = @VCHRNMBR)    /*amelroe 10/08/2014*/
End

Begin
	print 'PM20200 - PM Distribution OPEN OPEN Temporary'
	
if @DOCTYPE <=5 (select * from PM20200 where APTVCHNM = @VCHRNMBR)     /*amelroe 10/08/2014*/
if @DOCTYPE = 6 (select * from PM20200 where VCHRNMBR = @VCHRNMBR)     /*amelroe 10/08/2014*/
	End 

	Begin
print 'PM30200 - PM Paid Transaction History'
	select * from PM30200 where VCHRNMBR = @VCHRNMBR and DOCTYPE=@DOCTYPE
End

Begin
print 'PM30300 - PM Apply To History'
	if @DOCTYPE <=3 (Select * from PM30300 where APTVCHNM=@VCHRNMBR AND APTODCTY = @DOCTYPE)	/*jnelson amelroe 06/20/2016*/
	if @DOCTYPE >=4 (select * from PM30300 where VCHRNMBR = @VCHRNMBR AND DOCTYPE = @DOCTYPE) /*jnelson amelroe 06/9/2016*/
End


Begin
	print 'PM30600 - PM Distribution History'
	
if @DOCTYPE <=5 (select * from PM30600 where VCHRNMBR = @VCHRNMBR and CNTRLTYP=0)
if @DOCTYPE = 6 (select * from PM30600 where VCHRNMBR = @VCHRNMBR and CNTRLTYP=1)
End 

Begin
print 'PM30700 - PM Tax History'
	select * from PM30700 where VCHRNMBR = @VCHRNMBR and DOCTYPE=@DOCTYPE     /*amelroe 10/08/2014*/
End

Begin
print 'PM30800 - PM Tax Invoices'
	select * from PM30800 where VCHRNMBR = @VCHRNMBR and DOCTYPE=@DOCTYPE
End

/*Payables Void Temporary Tables*/

print '=================================================================================='
print 'Payables Void Temporary Tables'
print '=================================================================================='
print ''

Begin 
	print 'PM10600 - PM Distribution Void WORK Temporary'
if @DOCTYPE <=5 (select * from PM10600 where VCHRNMBR = @VCHRNMBR and CNTRLTYP=0)
if @DOCTYPE = 6 (select * from PM10600 where VCHRNMBR = @VCHRNMBR and CNTRLTYP=1)
	End 

Begin 
if @DOCTYPE = 6
	print 'PM10801 - PM Payment Stub Duplicate'
if @DOCTYPE = 6 (select * from PM10801 where PMNTNMBR = @VCHRNMBR)
	End 

Begin 
	print 'PM10900 - Void Payment WORK Temporary'
		select * from PM10900 where VCHRNMBR = @VCHRNMBR and DOCTYPE=@DOCTYPE
	End 

Begin 
	print 'PM10901 - PM Void Transaction WORK Temporary'
		select * from PM10901 where VCHRNMBR = @VCHRNMBR and DOCTYPE=@DOCTYPE
	End 

Begin 
	print 'PM10902 - PM Tax Void Work Temporary'
		select * from PM10902 where VCHRNMBR = @VCHRNMBR 
	End 

/*General Ledger*/
print '=================================================================================='
print 'GL info'
print '=================================================================================='
print ''

Begin
print 'GL10000 - Transaction Work'
/*print '========'*/
select * from GL10000  where  DTAControlNum= @VCHRNMBR AND DTATRXType=@DOCTYPE
End

Begin
print 'GL10001 - Transaction Amounts Work'
/*print '========'*/
select * from GL10001 WHERE JRNENTRY IN (SELECT JRNENTRY FROM GL10000 WHERE DTAControlNum= @VCHRNMBR AND DTATRXType=@DOCTYPE)
End
Begin
print 'GL20000 - Year-to-Date Transaction Open'
/*print '========'*/
select * from GL20000 where ORCTRNUM = @VCHRNMBR AND ORTRXTYP=@DOCTYPE
End
Begin
print 'GL30000 - Account Transaction History'
/*print '========'*/
select * from GL30000 where ORCTRNUM = @VCHRNMBR AND ORTRXTYP=@DOCTYPE
End
End

/*Multicurrency Info*/
print '=================================================================================='
print 'Multicurrency Info'
print '=================================================================================='
print ''

Begin
print 'MC020103 - Multicurrency Payables Transactions'
/*print '========'*/

select  * from MC020103 where VCHRNMBR=@VCHRNMBR and DOCTYPE=@DOCTYPE
End

Begin
print 'MC020105 - Multicurrency RM Revaluation Activity'
/*print '========'*/
select * from MC020105 where VCHRNMBR=@VCHRNMBR and DOCTYPE=@DOCTYPE
End

/*Bank Reconcilation*/
print '=================================================================================='
print 'Bank Reconcilation'
print '=================================================================================='
print ''

Begin
print 'CM20200 - CM Transaction'
/*print '========'*/
select * from CM20200 where SRCDOCNUM=@VCHRNMBR and SRCDOCTYP=@DOCTYPE
End


