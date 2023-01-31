DECLARE	@Company		Varchar(5) = DB_NAME(),
		@CustomerNumber	Varchar(15),
		@DocumentNumber	Varchar(30),
		@NoteDate		Datetime = GETDATE(),
		@NoteText		Varchar(2000) = 'This account was automatically put on hold due to inactivity',
		@Action			Varchar(17) = 'CUSTOMER ON HOLD',
		@UserId			Varchar(15) = 'ADG AUTOMATION',
		@InactivityDays	Int = 365,
		@DocDate		Date

DECLARE curCustomers CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CUSTNMBR,
		CAST(LastDate AS Date) AS LastDate,
		Document = (SELECT MAX(DOCNUMBR) FROM (SELECT MAX(R2.DOCNUMBR) AS DOCNUMBR FROM RM20101 R2 WHERE R2.CUSTNMBR = DATA.CUSTNMBR AND R2.DOCDATE = DATA.LastDate UNION SELECT MAX(R3.DOCNUMBR) AS DOCNUMBR FROM RM30101 R3 WHERE R3.CUSTNMBR = DATA.CUSTNMBR AND R3.DOCDATE = DATA.LastDate) DATA)
FROM	(
		SELECT	R1.CUSTNMBR,
				R1.CUSTNAME,
				LastDate = (SELECT MAX(LastDate) FROM (SELECT MAX(R2.DOCDATE) AS LastDate FROM RM20101 R2 WHERE R1.CUSTNMBR = R2.CUSTNMBR UNION SELECT MAX(R3.DOCDATE) AS LastDate FROM RM30101 R3 WHERE R1.CUSTNMBR = R3.CUSTNMBR) DATA)
		FROM	RM00101 R1
		WHERE	Inactive = 0
				AND Hold = 0
		) DATA
WHERE	DATEDIFF(dd, LastDate, GETDATE()) > @InactivityDays
ORDER BY 3,1

OPEN curCustomers 
FETCH FROM curCustomers INTO @CustomerNumber, @DocDate, @DocumentNumber

WHILE @@FETCH_STATUS = 0 
BEGIN
	--EXECUTE GPCustom.dbo.USP_InsertCollectionsNote @Company, @CustomerNumber, @DocumentNumber, @NoteDate, @NoteText, @Action, @UserId

	FETCH FROM curCustomers INTO @CustomerNumber, @DocDate, @DocumentNumber
END

CLOSE curCustomers
DEALLOCATE curCustomers

--SELECT TOP 10 * FROM RM20101