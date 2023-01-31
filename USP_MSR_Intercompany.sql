CREATE PROCEDURE USP_MSR_Intercompany
		@MSR_IntercompanyId	Int,
		@CO_MAR				Numeric(18,2),
		@CO_REP				Numeric(18,2),
		@CO_RPL				Numeric(18,2),
		@OO_MAR				Numeric(18,2),
		@OO_REP				Numeric(18,2),
		@OO_RPL				Numeric(18,2),
		@Account1			Varchar(15),
		@Account2			Varchar(15),
		@Account3			Varchar(15),
		@Description1		Varchar(30),
		@Description2		Varchar(30),
		@Description3		Varchar(30),
		@PostingDate		Datetime,
		@ProNumber			Varchar(25)
AS
DECLARE	@Amount1			Numeric(18,2),
		@Amount2			Numeric(18,2),
		@Amount3			Numeric(18,2),
		@InvTotal			Numeric(18,2)
		
SET		@Amount1	= 0
SET		@Amount2	= 0
SET		@Amount3	= 0
SET		@InvTotal	= (SELECT InvoiceTotal FROM MSR_Intercompany WHERE MSR_IntercompanyId = @MSR_IntercompanyId)

IF @CO_MAR > 0
BEGIN
	SET	@Amount1 = @CO_MAR
END

IF @CO_REP > 0
BEGIN
	IF @Amount1 = 0
	BEGIN
		SET	@Amount1 = @CO_REP
	END
	ELSE
	BEGIN
		SET	@Amount2 = @CO_REP
	END
END

IF @CO_RPL > 0
BEGIN
	IF @Amount1 = 0
	BEGIN
		SET	@Amount1 = @CO_RPL
	END
	ELSE
	BEGIN
		IF @Amount2 = 0
		BEGIN
			SET	@Amount2 = @CO_RPL
		END
		ELSE
		BEGIN
			SET	@Amount3 = @InvTotal - (@Amount1 + @Amount2)
		END
	END
END

IF @OO_MAR > 0
BEGIN
	IF @Amount1 = 0
	BEGIN
		SET	@Amount1 = @OO_MAR
	END
	ELSE
	BEGIN
		IF @Amount2 = 0
		BEGIN
			SET	@Amount2 = @OO_MAR
		END
		ELSE
		BEGIN
			SET	@Amount3 = @InvTotal - (@Amount1 + @Amount2)
		END
	END
END

IF @OO_REP > 0
BEGIN
	IF @Amount1 = 0
	BEGIN
		SET	@Amount1 = @OO_REP
	END
	ELSE
	BEGIN
		IF @Amount2 = 0
		BEGIN
			SET	@Amount2 = @OO_REP
		END
		ELSE
		BEGIN
			SET	@Amount3 = @InvTotal - (@Amount1 + @Amount2)
		END
	END
END

IF @OO_RPL > 0
BEGIN
	IF @Amount1 = 0
	BEGIN
		SET	@Amount1 = @OO_RPL
	END
	ELSE
	BEGIN
		IF @Amount2 = 0
		BEGIN
			SET	@Amount2 = @OO_RPL
		END
		ELSE
		BEGIN
			SET	@Amount3 = @InvTotal - (@Amount1 + @Amount2)
		END
	END
END

UPDATE	MSR_Intercompany
SET		CO_MAR				= @CO_MAR,
		CO_REP				= @CO_REP,
		CO_RPL				= @CO_RPL,
		OO_MAR				= @OO_MAR,
		OO_REP				= @OO_REP,
		OO_RPL				= @OO_RPL,
		Account1			= @Account1,
		Account2			= @Account2,
		Account3			= @Account3,
		Amount1				= @Amount1,
		Amount2				= @Amount2,
		Amount3				= @Amount3,
		Description1		= @Description1,
		Description2		= @Description2,
		Description3		= @Description3,
		PostingDate			= @PostingDate,
		ProNumber			= @ProNumber
WHERE	MSR_IntercompanyId	= @MSR_IntercompanyId