DECLARE	@Inv_No		Int,
		@Consum		Numeric(9, 2)
		
SET		@Inv_No	= 764775
SET		@Consum	= 1.98

UPDATE	Invoices
SET		Consum = @Consum
WHERE	inv_no = @Inv_No

UPDATE	Results
SET		Consumable = @Consum
WHERE	INV_NO = @Inv_No