DECLARE	@InvoiceNumber	Varchar(25) = 'IGS-0010101-8',
		@Query			Varchar(MAX)

SET @Query = N'SELECT HDR.Vendor, HDR.BL_Number, HDR.Inv_total, HDR.Inv_balance, HDR.Inv_date, HDR.Due_Date, HDR.Terms, HDR.Actual_ap_date, HDR.Inh_invoice_id, HDR.Status FROM AP_Hdr HDR WHERE BL_number = ''' + @InvoiceNumber + ''''
SET @Query = N'SELECT HDR.Div_Code, CLN.External_Id FROM AP_Hdr HDR INNER JOIN Client CLN ON HDR.Vendor = CLN.AcctG_Id WHERE HDR.BL_number = ''' + @InvoiceNumber + ''''


EXECUTE USP_QueryPervasive @Query 
