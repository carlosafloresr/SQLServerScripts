CREATE PROCEDURE USP_CreaRecibos
AS
DECLARE	@Factura			int,
		@Periodo			char(6),
		@FechaInicial		datetime,
		@FechaFinal			datetime,
		@Ruta				smallint,
		@Subtotal			numeric,
		@IVA				numeric,
		@Total				numeric,
		@FacturaDetalleId	int,
		@Fk_ConceptoId		int,
		@Concepto			varchar(50),
		@Importe			numeric,
		@NombreCompleto		varchar(83),
		@Balance			numeric,
		@Pagos				numeric,
		@NumeroDeCliente	varchar(12),
		@FechaEmision		datetime,
		@Recibo				varchar(5000),
		@FinalRecibo		varchar(5000),
		@ExtraText			varchar(100),
		@Counter			Int,
		@mRuta				smallint,
		@mSubtotal			numeric,
		@mIVA				numeric,
		@mTotal				numeric,
		@mFechaEmision		datetime,
		@mBalance			numeric,
		@mNumeroDeCliente	varchar(12)
 
SELECT	@Periodo = MAX(Periodo)
FROM	Facturas
 
DECLARE FacturasCliente CURSOR READ_ONLY FOR
SELECT	Factura
FROM	Facturas
WHERE	Periodo = @Periodo
 
OPEN FacturasCliente 
FETCH FROM FacturasCliente INTO @Factura
 
WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Counter = 0

	DECLARE Registros CURSOR READ_ONLY FOR
	SELECT	FechaInicial
			,FechaFinal
			,Ruta
			,Subtotal
			,IVA
			,Total
			,FacturaDetalleId
			,Fk_ConceptoId
			,Concepto
			,Importe
			,NombreCompleto
			,Balance
			,Pagos
			,NumeroDeCliente
			,FechaEmision
			,Recibo
	FROM	View_Facturas
	WHERE	Factura = @Factura
 
	OPEN Registros 
	FETCH FROM Registros INTO @FechaInicial, @FechaFinal, @Ruta, @Subtotal, @IVA, @Total, @FacturaDetalleId, @Fk_ConceptoId, @Concepto,
				@Importe, @NombreCompleto, @Balance, @Pagos, @NumeroDeCliente, @FechaEmision, @Recibo

	SET @FinalRecibo = @Recibo
 
	WHILE @@FETCH_STATUS = 0 AND @Counter < 8
	BEGIN
		SET @Counter		= @Counter + 1
		SET @ExtraText		= ''
 
		IF @Counter = 2
			SET @ExtraText = CAST(@Factura AS Char(20))

		IF @Counter = 3
			SET @ExtraText = @NumeroDeCliente

		IF @Counter = 4
			SET @ExtraText = @Ruta

		IF @Counter = 5
			SET @ExtraText = CONVERT(Char(10), @FechaEmision, 103)
		
		SET @FinalRecibo		= @FinalRecibo + dbo.PADL('1', 8, ' ') + '  ' + dbo.PADR(@Concepto, 28, ' ') + '  ' + dbo.PADL(CONVERT(Char(12), CAST(@Importe AS Money), 1), 12, ' ') + SPACE(5) + @ExtraText + CHAR(13) + CHAR(10)
		SET	@mRuta				= @Ruta
		SET	@mSubtotal			= @SubTotal
		SET	@mIVA				= @IVA
		SET	@mTotal				= @Total
		SET	@mFechaEmision		= @FechaEmision
		SET	@mBalance			= @Balance
		SET	@mNumeroDeCliente	= @NumeroDeCliente

		FETCH FROM Registros INTO @FechaInicial, @FechaFinal, @Ruta, @Subtotal, @IVA, @Total, @FacturaDetalleId, @Fk_ConceptoId, @Concepto,
					@Importe, @NombreCompleto, @Balance, @Pagos, @NumeroDeCliente, @FechaEmision, @Recibo
	END

	CLOSE Registros
	DEALLOCATE Registros
	
	IF @Counter < 8
	BEGIN
		WHILE @Counter < 8
		BEGIN
			SET @Counter	= @Counter + 1
			SET @ExtraText	= ''

			IF @Counter = 2
				SET @ExtraText = SPACE(57) + CAST(@Factura AS Char(20))
 
			IF @Counter = 3
				SET @ExtraText = SPACE(57) + @mNumeroDeCliente

			IF @Counter = 4
				SET @ExtraText = SPACE(57) + CAST(@mRuta AS Char(3))

			IF @Counter = 5
				SET @ExtraText = SPACE(57) + CONVERT(Char(10), @mFechaEmision, 103)

			SET @FinalRecibo	= @FinalRecibo + @ExtraText + CHAR(13) + CHAR(10)
		END
	END

	SET @FinalRecibo = @FinalRecibo + SPACE(40) + dbo.PADL(CONVERT(Char(12), CAST(@mSubtotal AS Money), 1), 12, ' ') + CHAR(13) + CHAR(10)

	SET @FinalRecibo = @FinalRecibo + SPACE(40) + dbo.PADL(CONVERT(Char(12), CAST(@mIVA AS Money), 1), 12, ' ')
	SET @FinalRecibo = @FinalRecibo + SPACE(3) + dbo.PADL(CONVERT(Char(12), CAST(@mBalance AS Money), 1), 12, ' ')
	SET @FinalRecibo = @FinalRecibo + dbo.PADL(CONVERT(Char(10), CAST(@mTotal + @mBalance AS Money), 1), 10, ' ') + CHAR(13) + CHAR(10)

	SET @FinalRecibo = @FinalRecibo + SPACE(40) + dbo.PADL(CONVERT(Char(12), CAST(@mBalance AS Money), 1), 12, ' ')
	SET @FinalRecibo = @FinalRecibo + SPACE(3) + dbo.PADL(CONVERT(Char(12), CAST(@mTotal + @mBalance AS Money), 1), 12, ' ') + SPACE(12)
	SET @FinalRecibo = @FinalRecibo + dbo.PADL(CONVERT(Char(10), CAST(@mTotal + @mBalance AS Money), 1), 10, ' ') + CHAR(13) + CHAR(10)

	UPDATE Facturas SET Recibo = @FinalRecibo WHERE Factura = @Factura

	FETCH FROM FacturasCliente INTO @Factura
END

CLOSE FacturasCliente
DEALLOCATE FacturasCliente