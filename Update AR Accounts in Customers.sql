DECLARE	@ARACCOUNT	Int,
		@WOAccount	Int
		
SET		@ARACCOUNT = 5
SET		@WOAccount = 658

UPDATE	RM00101
SET		RMARACC = @ARACCOUNT,
		RMWRACC = @WOAccount,
		RMOvrpymtWrtoffAcctIdx = @WOAccount

/*

SELECT	CUSTNMBR
		,CUSTNAME
		,RMARACC
		,RMWRACC
		,RMOvrpymtWrtoffAcctIdx
FROM	RM00101

*/