USE [ABS]
GO

/****** Object:  Table [dbo].[RM00101]    Script Date: 6/13/2022 3:49:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RM00101](
	[CUSTNMBR] [char](15) NOT NULL,
	[CUSTNAME] [char](65) NOT NULL,
	[CUSTCLAS] [char](15) NOT NULL,
	[CPRCSTNM] [char](15) NOT NULL,
	[CNTCPRSN] [char](61) NOT NULL,
	[STMTNAME] [char](65) NOT NULL,
	[SHRTNAME] [char](15) NOT NULL,
	[ADRSCODE] [char](15) NOT NULL,
	[UPSZONE] [char](3) NOT NULL,
	[SHIPMTHD] [char](15) NOT NULL,
	[TAXSCHID] [char](15) NOT NULL,
	[ADDRESS1] [char](61) NOT NULL,
	[ADDRESS2] [char](61) NOT NULL,
	[ADDRESS3] [char](61) NOT NULL,
	[COUNTRY] [char](61) NOT NULL,
	[CITY] [char](35) NOT NULL,
	[STATE] [char](29) NOT NULL,
	[ZIP] [char](11) NOT NULL,
	[PHONE1] [char](21) NOT NULL,
	[PHONE2] [char](21) NOT NULL,
	[PHONE3] [char](21) NOT NULL,
	[FAX] [char](21) NOT NULL,
	[PRBTADCD] [char](15) NOT NULL,
	[PRSTADCD] [char](15) NOT NULL,
	[STADDRCD] [char](15) NOT NULL,
	[SLPRSNID] [char](15) NOT NULL,
	[CHEKBKID] [char](15) NOT NULL,
	[PYMTRMID] [char](21) NOT NULL,
	[CRLMTTYP] [smallint] NOT NULL,
	[CRLMTAMT] [numeric](19, 5) NOT NULL,
	[CRLMTPER] [smallint] NOT NULL,
	[CRLMTPAM] [numeric](19, 5) NOT NULL,
	[CURNCYID] [char](15) NOT NULL,
	[RATETPID] [char](15) NOT NULL,
	[CUSTDISC] [smallint] NOT NULL,
	[PRCLEVEL] [char](11) NOT NULL,
	[MINPYTYP] [smallint] NOT NULL,
	[MINPYDLR] [numeric](19, 5) NOT NULL,
	[MINPYPCT] [smallint] NOT NULL,
	[FNCHATYP] [smallint] NOT NULL,
	[FNCHPCNT] [smallint] NOT NULL,
	[FINCHDLR] [numeric](19, 5) NOT NULL,
	[MXWOFTYP] [smallint] NOT NULL,
	[MXWROFAM] [numeric](19, 5) NOT NULL,
	[COMMENT1] [char](31) NOT NULL,
	[COMMENT2] [char](31) NOT NULL,
	[USERDEF1] [char](21) NOT NULL,
	[USERDEF2] [char](21) NOT NULL,
	[TAXEXMT1] [char](25) NOT NULL,
	[TAXEXMT2] [char](25) NOT NULL,
	[TXRGNNUM] [char](25) NOT NULL,
	[BALNCTYP] [smallint] NOT NULL,
	[STMTCYCL] [smallint] NOT NULL,
	[BANKNAME] [char](31) NOT NULL,
	[BNKBRNCH] [char](21) NOT NULL,
	[SALSTERR] [char](15) NOT NULL,
	[DEFCACTY] [smallint] NOT NULL,
	[RMCSHACC] [int] NOT NULL,
	[RMARACC] [int] NOT NULL,
	[RMSLSACC] [int] NOT NULL,
	[RMIVACC] [int] NOT NULL,
	[RMCOSACC] [int] NOT NULL,
	[RMTAKACC] [int] NOT NULL,
	[RMAVACC] [int] NOT NULL,
	[RMFCGACC] [int] NOT NULL,
	[RMWRACC] [int] NOT NULL,
	[RMSORACC] [int] NOT NULL,
	[FRSTINDT] [datetime] NOT NULL,
	[INACTIVE] [tinyint] NOT NULL,
	[HOLD] [tinyint] NOT NULL,
	[CRCARDID] [char](15) NOT NULL,
	[CRCRDNUM] [char](21) NOT NULL,
	[CCRDXPDT] [datetime] NOT NULL,
	[KPDSTHST] [tinyint] NOT NULL,
	[KPCALHST] [tinyint] NOT NULL,
	[KPERHIST] [tinyint] NOT NULL,
	[KPTRXHST] [tinyint] NOT NULL,
	[NOTEINDX] [numeric](19, 5) NOT NULL,
	[CREATDDT] [datetime] NOT NULL,
	[MODIFDT] [datetime] NOT NULL,
	[Revalue_Customer] [tinyint] NOT NULL,
	[Post_Results_To] [smallint] NOT NULL,
	[FINCHID] [char](15) NOT NULL,
	[GOVCRPID] [char](31) NOT NULL,
	[GOVINDID] [char](31) NOT NULL,
	[DISGRPER] [smallint] NOT NULL,
	[DUEGRPER] [smallint] NOT NULL,
	[DOCFMTID] [char](15) NOT NULL,
	[Send_Email_Statements] [tinyint] NOT NULL,
	[USERLANG] [smallint] NOT NULL,
	[GPSFOINTEGRATIONID] [char](31) NOT NULL,
	[INTEGRATIONSOURCE] [smallint] NOT NULL,
	[INTEGRATIONID] [char](31) NOT NULL,
	[ORDERFULFILLDEFAULT] [smallint] NOT NULL,
	[CUSTPRIORITY] [smallint] NOT NULL,
	[CCode] [char](7) NOT NULL,
	[DECLID] [char](15) NOT NULL,
	[RMOvrpymtWrtoffAcctIdx] [int] NOT NULL,
	[SHIPCOMPLETE] [tinyint] NOT NULL,
	[CBVAT] [tinyint] NOT NULL,
	[INCLUDEINDP] [tinyint] NOT NULL,
	[DEX_ROW_TS] [datetime] NOT NULL,
	[DEX_ROW_ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PKRM00101] PRIMARY KEY NONCLUSTERED 
(
	[CUSTNMBR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RM00101] ADD  DEFAULT (getutcdate()) FOR [DEX_ROW_TS]
GO

ALTER TABLE [dbo].[RM00101]  WITH CHECK ADD CHECK  ((datepart(hour,[CCRDXPDT])=(0) AND datepart(minute,[CCRDXPDT])=(0) AND datepart(second,[CCRDXPDT])=(0) AND datepart(millisecond,[CCRDXPDT])=(0)))
GO

ALTER TABLE [dbo].[RM00101]  WITH CHECK ADD CHECK  ((datepart(hour,[CREATDDT])=(0) AND datepart(minute,[CREATDDT])=(0) AND datepart(second,[CREATDDT])=(0) AND datepart(millisecond,[CREATDDT])=(0)))
GO

ALTER TABLE [dbo].[RM00101]  WITH CHECK ADD CHECK  ((datepart(hour,[FRSTINDT])=(0) AND datepart(minute,[FRSTINDT])=(0) AND datepart(second,[FRSTINDT])=(0) AND datepart(millisecond,[FRSTINDT])=(0)))
GO

ALTER TABLE [dbo].[RM00101]  WITH CHECK ADD CHECK  ((datepart(hour,[MODIFDT])=(0) AND datepart(minute,[MODIFDT])=(0) AND datepart(second,[MODIFDT])=(0) AND datepart(millisecond,[MODIFDT])=(0)))
GO

ALTER TABLE [dbo].[RM00101]  WITH NOCHECK ADD  CONSTRAINT [RM_Customer_MSTR_NA] CHECK  (([CPRCSTNM]<>'' AND [BALNCTYP]=(0) OR [CPRCSTNM]='' AND [BALNCTYP]=(1) OR [CPRCSTNM]='' AND [BALNCTYP]=(0)))
GO

ALTER TABLE [dbo].[RM00101] CHECK CONSTRAINT [RM_Customer_MSTR_NA]
GO


