DROP TABLE POP10100

CREATE TABLE [dbo].[POP10100](
	[PONUMBER] [char](17) NOT NULL,
	[POSTATUS] [smallint] NOT NULL,
	[STATGRP] [smallint] NOT NULL,
	[POTYPE] [smallint] NOT NULL,
	[USER2ENT] [char](15) NOT NULL,
	[CONFIRM1] [char](21) NOT NULL,
	[DOCDATE] [datetime] NOT NULL,
	[LSTEDTDT] [datetime] NOT NULL,
	[LSTPRTDT] [datetime] NOT NULL,
	[PRMDATE] [datetime] NOT NULL,
	[PRMSHPDTE] [datetime] NOT NULL,
	[REQDATE] [datetime] NOT NULL,
	[REQTNDT] [datetime] NOT NULL,
	[SHIPMTHD] [char](15) NOT NULL,
	[TXRGNNUM] [char](25) NOT NULL,
	[REMSUBTO] [numeric](19, 5) NOT NULL,
	[SUBTOTAL] [numeric](19, 5) NOT NULL,
	[TRDISAMT] [numeric](19, 5) NOT NULL,
	[FRTAMNT] [numeric](19, 5) NOT NULL,
	[MSCCHAMT] [numeric](19, 5) NOT NULL,
	[TAXAMNT] [numeric](19, 5) NOT NULL,
	[VENDORID] [char](15) NOT NULL,
	[VENDNAME] [char](65) NOT NULL,
	[MINORDER] [numeric](19, 5) NOT NULL,
	[VADCDPAD] [char](15) NOT NULL,
	[CMPANYID] [smallint] NOT NULL,
	[PRBTADCD] [char](15) NOT NULL,
	[PRSTADCD] [char](15) NOT NULL,
	[CMPNYNAM] [char](65) NOT NULL,
	[CONTACT] [char](61) NOT NULL,
	[ADDRESS1] [char](61) NOT NULL,
	[ADDRESS2] [char](61) NOT NULL,
	[ADDRESS3] [char](61) NOT NULL,
	[CITY] [char](35) NOT NULL,
	[STATE] [char](29) NOT NULL,
	[ZIPCODE] [char](11) NOT NULL,
	[CCode] [char](7) NOT NULL,
	[COUNTRY] [char](61) NOT NULL,
	[PHONE1] [char](21) NOT NULL,
	[PHONE2] [char](21) NOT NULL,
	[PHONE3] [char](21) NOT NULL,
	[FAX] [char](21) NOT NULL,
	[PYMTRMID] [char](21) NOT NULL,
	[DSCDLRAM] [numeric](19, 5) NOT NULL,
	[DSCPCTAM] [smallint] NOT NULL,
	[DISAMTAV] [numeric](19, 5) NOT NULL,
	[DISCDATE] [datetime] NOT NULL,
	[DUEDATE] [datetime] NOT NULL,
	[TRDPCTPR] [numeric](23, 0) NOT NULL,
	[CUSTNMBR] [char](15) NOT NULL,
	[TIMESPRT] [smallint] NOT NULL,
	[CREATDDT] [datetime] NOT NULL,
	[MODIFDT] [datetime] NOT NULL,
	[PONOTIDS_1] [numeric](19, 5) NOT NULL,
	[PONOTIDS_2] [numeric](19, 5) NOT NULL,
	[PONOTIDS_3] [numeric](19, 5) NOT NULL,
	[PONOTIDS_4] [numeric](19, 5) NOT NULL,
	[PONOTIDS_5] [numeric](19, 5) NOT NULL,
	[PONOTIDS_6] [numeric](19, 5) NOT NULL,
	[PONOTIDS_7] [numeric](19, 5) NOT NULL,
	[PONOTIDS_8] [numeric](19, 5) NOT NULL,
	[PONOTIDS_9] [numeric](19, 5) NOT NULL,
	[PONOTIDS_10] [numeric](19, 5) NOT NULL,
	[PONOTIDS_11] [numeric](19, 5) NOT NULL,
	[PONOTIDS_12] [numeric](19, 5) NOT NULL,
	[PONOTIDS_13] [numeric](19, 5) NOT NULL,
	[PONOTIDS_14] [numeric](19, 5) NOT NULL,
	[PONOTIDS_15] [numeric](19, 5) NOT NULL,
	[COMMNTID] [char](15) NOT NULL,
	[CANCSUB] [numeric](19, 5) NOT NULL,
	[CURNCYID] [char](15) NOT NULL,
	[CURRNIDX] [smallint] NOT NULL,
	[RATETPID] [char](15) NOT NULL,
	[EXGTBLID] [char](15) NOT NULL,
	[XCHGRATE] [numeric](19, 7) NOT NULL,
	[EXCHDATE] [datetime] NOT NULL,
	[TIME1] [datetime] NOT NULL,
	[RATECALC] [smallint] NOT NULL,
	[DENXRATE] [numeric](19, 7) NOT NULL,
	[MCTRXSTT] [smallint] NOT NULL,
	[OREMSUBT] [numeric](19, 5) NOT NULL,
	[ORSUBTOT] [numeric](19, 5) NOT NULL,
	[Originating_Canceled_Sub] [numeric](19, 5) NOT NULL,
	[ORTDISAM] [numeric](19, 5) NOT NULL,
	[ORFRTAMT] [numeric](19, 5) NOT NULL,
	[OMISCAMT] [numeric](19, 5) NOT NULL,
	[ORTAXAMT] [numeric](19, 5) NOT NULL,
	[ORDDLRAT] [numeric](19, 5) NOT NULL,
	[ODISAMTAV] [numeric](19, 5) NOT NULL,
	[BUYERID] [char](15) NOT NULL,
	[ONORDAMT] [numeric](19, 5) NOT NULL,
	[ORORDAMT] [numeric](19, 5) NOT NULL,
	[HOLD] [tinyint] NOT NULL,
	[ONHOLDDATE] [datetime] NOT NULL,
	[ONHOLDBY] [char](15) NOT NULL,
	[HOLDREMOVEDATE] [datetime] NOT NULL,
	[HOLDREMOVEBY] [char](15) NOT NULL,
	[ALLOWSOCMTS] [tinyint] NOT NULL,
	[DISGRPER] [smallint] NOT NULL,
	[DUEGRPER] [smallint] NOT NULL,
	[Revision_Number] [smallint] NOT NULL,
	[Change_Order_Flag] [smallint] NOT NULL,
	[PO_Field_Changes] [binary](4) NOT NULL,
	[PO_Status_Orig] [smallint] NOT NULL,
	[TAXSCHID] [char](15) NOT NULL,
	[TXSCHSRC] [smallint] NOT NULL,
	[TXENGCLD] [tinyint] NOT NULL,
	[BSIVCTTL] [tinyint] NOT NULL,
	[Purchase_Freight_Taxable] [smallint] NOT NULL,
	[Purchase_Misc_Taxable] [smallint] NOT NULL,
	[FRTSCHID] [char](15) NOT NULL,
	[MSCSCHID] [char](15) NOT NULL,
	[FRTTXAMT] [numeric](19, 5) NOT NULL,
	[ORFRTTAX] [numeric](19, 5) NOT NULL,
	[MSCTXAMT] [numeric](19, 5) NOT NULL,
	[ORMSCTAX] [numeric](19, 5) NOT NULL,
	[BCKTXAMT] [numeric](19, 5) NOT NULL,
	[OBTAXAMT] [numeric](19, 5) NOT NULL,
	[BackoutFreightTaxAmt] [numeric](19, 5) NOT NULL,
	[OrigBackoutFreightTaxAmt] [numeric](19, 5) NOT NULL,
	[BackoutMiscTaxAmt] [numeric](19, 5) NOT NULL,
	[OrigBackoutMiscTaxAmt] [numeric](19, 5) NOT NULL,
	[Flags] [smallint] NOT NULL,
	[BackoutTradeDiscTax] [numeric](19, 5) NOT NULL,
	[OrigBackoutTradeDiscTax] [numeric](19, 5) NOT NULL,
	[POPCONTNUM] [char](21) NOT NULL,
	[CONTENDDTE] [datetime] NOT NULL,
	[CNTRLBLKTBY] [smallint] NOT NULL,
	[PURCHCMPNYNAM] [char](65) NOT NULL,
	[PURCHCONTACT] [char](61) NOT NULL,
	[PURCHADDRESS1] [char](61) NOT NULL,
	[PURCHADDRESS2] [char](61) NOT NULL,
	[PURCHADDRESS3] [char](61) NOT NULL,
	[PURCHCITY] [char](35) NOT NULL,
	[PURCHSTATE] [char](29) NOT NULL,
	[PURCHZIPCODE] [char](11) NOT NULL,
	[PURCHCCode] [char](7) NOT NULL,
	[PURCHCOUNTRY] [char](61) NOT NULL,
	[PURCHPHONE1] [char](21) NOT NULL,
	[PURCHPHONE2] [char](21) NOT NULL,
	[PURCHPHONE3] [char](21) NOT NULL,
	[PURCHFAX] [char](21) NOT NULL,
	[BLNKTLINEEXTQTYSUM] [numeric](19, 5) NOT NULL,
	[CBVAT] [tinyint] NOT NULL,
	[Workflow_Approval_Status] [smallint] NOT NULL,
	[Workflow_Priority] [smallint] NOT NULL,
	[Print_Phone_NumberGB] [smallint] NOT NULL,
	[PrepaymentAmount] [numeric](19, 5) NOT NULL,
	[OriginatingPrepaymentAmt] [numeric](19, 5) NOT NULL,
	[DEX_ROW_TS] [datetime] NOT NULL,
	[DEX_ROW_ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PKPOP10100] PRIMARY KEY NONCLUSTERED 
(
	[PONUMBER] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[POP10100] ADD  DEFAULT (getutcdate()) FOR [DEX_ROW_TS]
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[CONTENDDTE])=(0) AND datepart(minute,[CONTENDDTE])=(0) AND datepart(second,[CONTENDDTE])=(0) AND datepart(millisecond,[CONTENDDTE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[CREATDDT])=(0) AND datepart(minute,[CREATDDT])=(0) AND datepart(second,[CREATDDT])=(0) AND datepart(millisecond,[CREATDDT])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[DISCDATE])=(0) AND datepart(minute,[DISCDATE])=(0) AND datepart(second,[DISCDATE])=(0) AND datepart(millisecond,[DISCDATE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[DOCDATE])=(0) AND datepart(minute,[DOCDATE])=(0) AND datepart(second,[DOCDATE])=(0) AND datepart(millisecond,[DOCDATE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[DUEDATE])=(0) AND datepart(minute,[DUEDATE])=(0) AND datepart(second,[DUEDATE])=(0) AND datepart(millisecond,[DUEDATE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[EXCHDATE])=(0) AND datepart(minute,[EXCHDATE])=(0) AND datepart(second,[EXCHDATE])=(0) AND datepart(millisecond,[EXCHDATE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[HOLDREMOVEDATE])=(0) AND datepart(minute,[HOLDREMOVEDATE])=(0) AND datepart(second,[HOLDREMOVEDATE])=(0) AND datepart(millisecond,[HOLDREMOVEDATE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[LSTEDTDT])=(0) AND datepart(minute,[LSTEDTDT])=(0) AND datepart(second,[LSTEDTDT])=(0) AND datepart(millisecond,[LSTEDTDT])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[LSTPRTDT])=(0) AND datepart(minute,[LSTPRTDT])=(0) AND datepart(second,[LSTPRTDT])=(0) AND datepart(millisecond,[LSTPRTDT])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[MODIFDT])=(0) AND datepart(minute,[MODIFDT])=(0) AND datepart(second,[MODIFDT])=(0) AND datepart(millisecond,[MODIFDT])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[ONHOLDDATE])=(0) AND datepart(minute,[ONHOLDDATE])=(0) AND datepart(second,[ONHOLDDATE])=(0) AND datepart(millisecond,[ONHOLDDATE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[PRMDATE])=(0) AND datepart(minute,[PRMDATE])=(0) AND datepart(second,[PRMDATE])=(0) AND datepart(millisecond,[PRMDATE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[PRMSHPDTE])=(0) AND datepart(minute,[PRMSHPDTE])=(0) AND datepart(second,[PRMSHPDTE])=(0) AND datepart(millisecond,[PRMSHPDTE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[REQDATE])=(0) AND datepart(minute,[REQDATE])=(0) AND datepart(second,[REQDATE])=(0) AND datepart(millisecond,[REQDATE])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(hour,[REQTNDT])=(0) AND datepart(minute,[REQTNDT])=(0) AND datepart(second,[REQTNDT])=(0) AND datepart(millisecond,[REQTNDT])=(0)))
GO

ALTER TABLE [dbo].[POP10100]  WITH CHECK ADD CHECK  ((datepart(day,[TIME1])=(1) AND datepart(month,[TIME1])=(1) AND datepart(year,[TIME1])=(1900)))
GO

