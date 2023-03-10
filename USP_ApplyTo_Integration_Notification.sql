USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_ApplyTo_Integration_Notification]    Script Date: 5/19/2020 10:52:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ApplyTo_Integration_Notification 'LB051420120000'
*/
ALTER PROCEDURE [dbo].[USP_ApplyTo_Integration_Notification]
		@BatchId		Varchar(25)
AS
DECLARE	@strHTML		Varchar(Max) = '',
		@ApplyFrom		Varchar(30),
		@ApplyTo		Varchar(30),
		@ApplyAmount	Numeric(10,2),
		@WriteoffAmnt	Numeric(10,2),
		@LastFrom		Varchar(30) = 'NONE'

SET @strHTML = ''

DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	ApplyFrom,
		ApplyTo,
		ApplyAmount,
		WriteoffAmnt
FROM	Integrations_ApplyTo
WHERE	BatchId = @BatchId
ORDER BY ApplyFrom, ApplyTo

OPEN curTransactions 
FETCH FROM curTransactions INTO @ApplyFrom, @ApplyTo, @ApplyAmount, @WriteoffAmnt

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @strHTML = @strHTML + '<tr><td>' + RTRIM(@ApplyFrom) + '</td>'
	SET @strHTML = @strHTML + '<td>' + RTRIM(@ApplyTo) + '</td><td style="text-align:right;width:100px;">' + FORMAT(@ApplyAmount, 'C', 'en-us') + '</td>'
	SET @strHTML = @strHTML + '<td style="text-align:right;width:100px;">' + FORMAT(@WriteoffAmnt, 'C', 'en-us') + '</td></tr>'

	FETCH FROM curTransactions INTO @ApplyFrom, @ApplyTo, @ApplyAmount, @WriteoffAmnt
END

IF @strHTML <> ''
	SET @strHTML = '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;">' +
	'<thead><tr><th style="text-align:center;background-color:Yellow;width:100px;">Apply From</th>
	<th style="text-align:center;background-color:Yellow;">Apply To</th>
	<th style="text-align:center;background-color:Yellow;">Amount</th>
	<th style="text-align:center;background-color:Yellow;">Writeoff</th></tr></thead>' + 
	@strHTML + '</td></tr></table>'

SELECT @strHTML AS HTML

CLOSE curTransactions
DEALLOCATE curTransactions