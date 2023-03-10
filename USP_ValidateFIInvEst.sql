USE [FI_Data]
GO
/****** Object:  StoredProcedure [dbo].[USP_ValidateFIInvEst]    Script Date: 1/29/2016 1:58:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ValidateFIInvEst 'R', '1360344'
*/
ALTER PROCEDURE [dbo].[USP_ValidateFIInvEst]
		@SearchType		Char(1),
		@SearchValue	Varchar(100)
AS
DECLARE	@Query			Varchar(2000),
		@Inv_No			Int,
		@DataSource		Char(1)

DECLARE	@tblInvoices	Table (Inv_No Int)

DELETE	Invoices
WHERE	inv_no = @SearchValue

DELETE	Sale 
WHERE	inv_no = @SearchValue

INSERT INTO @tblInvoices
SELECT	Inv_No 
FROM	Invoices
WHERE	(@SearchType = 'R' AND Inv_No = CAST(@SearchValue AS Int))
		OR (@SearchType = 'B' AND Inv_Batch = CAST(@SearchValue AS Int))
		OR (@SearchType = 'C' AND Container = RTRIM(@SearchValue))
		OR (@SearchType = 'H' AND Chassis = RTRIM(@SearchValue))
		OR (@SearchType = 'G' AND GenSet_No = RTRIM(@SearchValue))
		OR (@SearchType = 'W' AND Workorder = RTRIM(@SearchValue))

IF @@ROWCOUNT = 0
BEGIN
	SET @Query = N'SELECT Inv_No FROM Invoices WHERE ' + 
		CASE	WHEN @SearchType = 'R' THEN 'Inv_No = ' + @SearchValue
				WHEN @SearchType = 'B' THEN 'Inv_Batch = ' + @SearchValue
				WHEN @SearchType = 'C' THEN 'Container = ' + @SearchValue
				WHEN @SearchType = 'H' THEN 'Chassis = ' + @SearchValue
				WHEN @SearchType = 'G' THEN 'Gen_SetNo = ' + @SearchValue
				WHEN @SearchType = 'W' THEN 'Workorder = ' + @SearchValue
		END

	INSERT INTO @tblInvoices
	EXECUTE USP_QueryFIDepot @Query

	IF @@ROWCOUNT = 0
	BEGIN
		SET @DataSource = 'H' -- Historical Tables

		INSERT INTO @tblInvoices
		SELECT	Inv_No
		FROM	LENSASQL003.DepotSystemsFrederickHist.dbo.Invoices
		WHERE	(@SearchType = 'R' AND Inv_No = CAST(@SearchValue AS Int))
				OR (@SearchType = 'B' AND Inv_Batch = CAST(@SearchValue AS Int))
				OR (@SearchType = 'C' AND Container = RTRIM(@SearchValue))
				OR (@SearchType = 'H' AND Chassis = RTRIM(@SearchValue))
				OR (@SearchType = 'G' AND GenSet_No = RTRIM(@SearchValue))
				OR (@SearchType = 'W' AND Workorder = RTRIM(@SearchValue))
	END
	ELSE
	BEGIN
		SET @DataSource = 'C' -- Current Tables
	END

	DECLARE curFI_DepotData CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT Inv_No FROM @tblInvoices

	OPEN curFI_DepotData 
	FETCH FROM curFI_DepotData INTO @Inv_No

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @DataSource = 'C'
			EXECUTE USP_Import_FIDepot_Estimate @Inv_No
		ELSE
		BEGIN
			BEGIN TRANSACTION

			INSERT INTO Invoices (inv_no, sbt_no, acct_no, inv_date, inv_total, inv_type, inv_est, inv_bal, inv_mech, inv_time, unit_type, chassis, container, genset_no, due_date, labor_hour, labor, mech_hours, parts, tirerpl, gallons, fueltax_nh, fueltax_h, tirerpr, size, sale_tax, sale_tax1, sale_tax2, pur_price, unit_f, tir_no, storage, inspec, lifts, inv_batch, est_batch, fhwa, cedex_size, cedex_cond, inv_format, edi_sent, edi_time, edi_trans, cdex_revis, tax_cust, tax_owner, tot_cust, labor_ownr, parts_cust, labor_cust, parts_ownr, est_date, depot_loc, stk_upd, cdxlrate, eq_datein, exp_date, lab_stand, week_end, estatus, mrsk_cause, rep_date, workorder, inv_remk, stor_com, rep_code, vin_no, rep_time,entry_usr, wo_ctr, unique_rec)
				SELECT	inv_no, sbt_no, acct_no, inv_date, inv_total, inv_type, inv_est, inv_bal, inv_mech, inv_time, unit_type, chassis, container, genset_no, due_date, labor_hour, labor, mech_hours, parts, tirerpl, gallons, fueltax_nh, fueltax_h, tirerpr, size, sale_tax, sale_tax1, sale_tax2, pur_price, unit_f, tir_no, storage, inspec, lifts, inv_batch, est_batch, fhwa, cedex_size, cedex_cond, inv_format, edi_sent, edi_time, edi_trans, cdex_revis, tax_cust, tax_owner, tot_cust, labor_ownr, parts_cust, labor_cust, parts_ownr, est_date, depot_loc, stk_upd, cdxlrate, eq_datein, exp_date, lab_stand, week_end, estatus, mrsk_cause, rep_date, workorder, inv_remk, stor_com, rep_code, vin_no, rep_time,entry_usr, wo_ctr, unique_rec 
				FROM	LENSASQL003.DepotSystemsFrederickHist.dbo.Invoices 
				WHERE	Inv_No = @Inv_No

			INSERT INTO Sale (inv_no, part_no, descript, qty_orderd, qty_shiped, optinos, unit_price, part_total, taxable, pur_price, itemtot, date, list_price, inv_est, cdex_party, cdex_damag, cdex_mater, cdex_repai, cdex_compo, cdex_locat, cdex_lengt, cdex_width, rlabor, rlabor_qty, lab_price, taxlabor, newdoton, newdotoff, lpart_no, tlabor, pur_item, inv_mech, alabor, depot_loc, max_labor, rate_code, cdex_meas, idcs_job, idcs_ym, idcs_loc, idcs_cond, epart_no, newlabdft, mrskrepc, ptqty1, unique_rec, bin, unique_id, mechlabtm)
				SELECT	inv_no, part_no, descript, qty_orderd, qty_shiped, optinos, unit_price, part_total, taxable, pur_price, itemtot, date, list_price, inv_est, cdex_party, cdex_damag, cdex_mater, cdex_repai, cdex_compo, cdex_locat, cdex_lengt, cdex_width, rlabor, rlabor_qty, lab_price, taxlabor, newdoton, newdotoff, lpart_no, tlabor, pur_item, inv_mech, alabor, depot_loc, max_labor, rate_code, cdex_meas, idcs_job, idcs_ym, idcs_loc, idcs_cond, epart_no, newlabdft, mrskrepc, ptqty1, unique_rec, bin, unique_id, mechlabtm 
				FROM	LENSASQL003.DepotSystemsFrederickHist.dbo.Sale 
				WHERE	Inv_No = @Inv_No

			IF @@ERROR = 0
				COMMIT TRANSACTION
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				PRINT 'Failure'
			END
		END

		FETCH FROM curFI_DepotData INTO @Inv_No
	END

	CLOSE curFI_DepotData
	DEALLOCATE curFI_DepotData
END
PRINT @DataSource
SELECT	* 
FROM	Invoices
WHERE	(@SearchType = 'R' AND Inv_No = CAST(@SearchValue AS Int))
		OR (@SearchType = 'B' AND Inv_Batch = CAST(@SearchValue AS Int))
		OR (@SearchType = 'C' AND Container = RTRIM(@SearchValue))
		OR (@SearchType = 'H' AND Chassis = RTRIM(@SearchValue))
		OR (@SearchType = 'G' AND GenSet_No = RTRIM(@SearchValue))
		OR (@SearchType = 'W' AND Workorder = RTRIM(@SearchValue))