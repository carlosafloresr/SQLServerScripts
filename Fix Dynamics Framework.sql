/*Script 1*/
DROP TABLE GL10110bkp
DROP TABLE Gl10111bkp
DROP TABLE GL70500bkp
DROP TABLE GL70501bkp
GO

select * into GL10110bkp from GL10110
select * into Gl10111bkp from GL10111
select * into GL70500bkp from GL70500
select * into GL70501bkp from GL70501
GO
/*Script 2*/
/*Begin_GL10110*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GL10110]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[GL10110]
GO

CREATE TABLE [dbo].[GL10110] (
 [ACTINDX] [int] NOT NULL ,
 [YEAR1] [smallint] NOT NULL ,
 [PERIODID] [smallint] NOT NULL ,
 [PERDBLNC] [numeric](19, 5) NOT NULL ,
 [ACTNUMBR_1] [char] (3) NOT NULL ,
 [ACTNUMBR_2] [char] (3) NOT NULL ,
 [ACTNUMBR_3] [char] (5) NOT NULL ,
 [ACCATNUM] [smallint] NOT NULL ,
 [CRDTAMNT] [numeric](19, 5) NOT NULL ,
 [DEBITAMT] [numeric](19, 5) NOT NULL ,
 [DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL ,
 CONSTRAINT [PKGL10110] PRIMARY KEY  NONCLUSTERED 
 (
 [ACTINDX],
 [YEAR1],
 [PERIODID]
 )  ON [PRIMARY] 
) ON [PRIMARY]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL10110].[ACCATNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL10110].[ACTINDX]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL10110].[ACTNUMBR_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL10110].[ACTNUMBR_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL10110].[ACTNUMBR_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL10110].[CRDTAMNT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL10110].[DEBITAMT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL10110].[PERDBLNC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL10110].[PERIODID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL10110].[YEAR1]'
GO

setuser
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[GL10110]  TO [DYNGRP]
GO

/*End_GL10110*/
/*Begin_GL10111*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GL10111]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[GL10111]
GO

CREATE TABLE [dbo].[GL10111] (
 [ACTINDX] [int] NOT NULL ,
 [YEAR1] [smallint] NOT NULL ,
 [PERIODID] [smallint] NOT NULL ,
 [ACTNUMBR_1] [char] (3) NOT NULL ,
 [ACTNUMBR_2] [char] (3) NOT NULL ,
 [ACTNUMBR_3] [char] (5) NOT NULL ,
 [ACCATNUM] [smallint] NOT NULL ,
 [PERDBLNC] [numeric](19, 5) NOT NULL ,
 [CRDTAMNT] [numeric](19, 5) NOT NULL ,
 [DEBITAMT] [numeric](19, 5) NOT NULL ,
 [DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL ,
 CONSTRAINT [PKGL10111] PRIMARY KEY  NONCLUSTERED 
 (
 [ACTINDX],
 [YEAR1],
 [PERIODID]
 )  ON [PRIMARY] 
) ON [PRIMARY]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL10111].[ACCATNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL10111].[ACTINDX]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL10111].[ACTNUMBR_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL10111].[ACTNUMBR_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL10111].[ACTNUMBR_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL10111].[CRDTAMNT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL10111].[DEBITAMT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL10111].[PERDBLNC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL10111].[PERIODID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL10111].[YEAR1]'
GO

setuser
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[GL10111]  TO [DYNGRP]
GO

/*End_GL10111*/
/*Begin_GL70500*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GL70500]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[GL70500]
GO

CREATE TABLE [dbo].[GL70500] (
 [IFFILXST] [smallint] NOT NULL ,
 [FILEXPNM] [char] (255) NOT NULL ,
 [EXPTTYPE] [smallint] NOT NULL ,
 [ASKECHTM] [tinyint] NOT NULL ,
 [PRNTOFIL] [tinyint] NOT NULL ,
 [PRTOPRTR] [tinyint] NOT NULL ,
 [PRTOSCRN] [tinyint] NOT NULL ,
 [PRNTTYPE] [smallint] NOT NULL ,
 [RPTGRIND] [smallint] NOT NULL ,
 [RTPACHIN] [smallint] NOT NULL ,
 [RTGRSBIN] [numeric](19, 5) NOT NULL ,
 [REPORTID] [smallint] NOT NULL ,
 [FINRPTNM] [char] (31) NOT NULL ,
 [STGENINT1] [smallint] NOT NULL ,
 [ENDGENINT1] [smallint] NOT NULL ,
 [STGENINT2] [smallint] NOT NULL ,
 [ENDGENINT2] [smallint] NOT NULL ,
 [STRTNGDT] [datetime] NOT NULL ,
 [ENDINGDT] [datetime] NOT NULL ,
 [STTCATEG] [smallint] NOT NULL ,
 [STTUDEF1] [char] (21) NOT NULL ,
 [ENUSRDF1] [char] (21) NOT NULL ,
 [ENDCATEG] [smallint] NOT NULL ,
 [STTCATNM] [char] (41) NOT NULL ,
 [ENDCATNM] [char] (41) NOT NULL ,
 [STRTJRNL] [int] NOT NULL ,
 [ENDJRNAL] [int] NOT NULL ,
 [STRXSRC] [char] (13) NOT NULL ,
 [ENTRXSRC] [char] (13) NOT NULL ,
 [STRTCMTRXNUM] [char] (21) NOT NULL ,
 [ENDCMTRXNUM] [char] (21) NOT NULL ,
 [SSRCEDOC] [char] (11) NOT NULL ,
 [ENDSRCDC] [char] (11) NOT NULL ,
 [STTACDSC] [char] (51) NOT NULL ,
 [ENDACDSC] [char] (51) NOT NULL ,
 [STBDBSID] [char] (15) NOT NULL ,
 [ENBDBSID] [char] (15) NOT NULL ,
 [STBDBSDS] [char] (31) NOT NULL ,
 [ENBDBSDS] [char] (31) NOT NULL ,
 [STCHBKID] [char] (15) NOT NULL ,
 [ENCHBKID] [char] (15) NOT NULL ,
 [STRTDSCR] [char] (51) NOT NULL ,
 [ENDDESCR] [char] (51) NOT NULL ,
 [STTSEGID] [char] (11) NOT NULL ,
 [ENDSEGID] [char] (11) NOT NULL ,
 [STCTRNUM] [char] (21) NOT NULL ,
 [ENCNTNUM] [char] (21) NOT NULL ,
 [STDOCNUM] [char] (21) NOT NULL ,
 [ENDOCNUM] [char] (21) NOT NULL ,
 [STMASTID] [char] (21) NOT NULL ,
 [ENMASTID] [char] (21) NOT NULL ,
 [STMASTNM] [char] (31) NOT NULL ,
 [ENMASTNM] [char] (31) NOT NULL ,
 [SORTBY] [smallint] NOT NULL ,
 [CBINACTS] [tinyint] NOT NULL ,
 [PSTNGACT] [smallint] NOT NULL ,
 [UNITACCT] [smallint] NOT NULL ,
 [RPRTSHOW] [smallint] NOT NULL ,
 [PRRPTFOR] [smallint] NOT NULL ,
 [PRVYRCMB] [char] (5) NOT NULL ,
 [RPTDETAL] [smallint] NOT NULL ,
 [INDIVDUL_1] [tinyint] NOT NULL ,
 [INDIVDUL_2] [tinyint] NOT NULL ,
 [INDIVDUL_3] [tinyint] NOT NULL ,
 [INDIVDUL_4] [tinyint] NOT NULL ,
 [INDIVDUL_5] [tinyint] NOT NULL ,
 [INDIVDUL_6] [tinyint] NOT NULL ,
 [INDIVDUL_7] [tinyint] NOT NULL ,
 [INDIVDUL_8] [tinyint] NOT NULL ,
 [INDIVDUL_9] [tinyint] NOT NULL ,
 [INDIVDUL_10] [tinyint] NOT NULL ,
 [INDIVDUL_11] [tinyint] NOT NULL ,
 [INDIVDUL_12] [tinyint] NOT NULL ,
 [INDIVDUL_13] [tinyint] NOT NULL ,
 [INDIVDUL_14] [tinyint] NOT NULL ,
 [INDIVDUL_15] [tinyint] NOT NULL ,
 [INDIVDUL_16] [tinyint] NOT NULL ,
 [INDIVDUL_17] [tinyint] NOT NULL ,
 [INDIVDUL_18] [tinyint] NOT NULL ,
 [INDIVDUL_19] [tinyint] NOT NULL ,
 [INDIVDUL_20] [tinyint] NOT NULL ,
 [INDIVDUL_21] [tinyint] NOT NULL ,
 [INDIVDUL_22] [tinyint] NOT NULL ,
 [INDIVDUL_23] [tinyint] NOT NULL ,
 [INDIVDUL_24] [tinyint] NOT NULL ,
 [INDIVDUL_25] [tinyint] NOT NULL ,
 [INDIVDUL_26] [tinyint] NOT NULL ,
 [INDIVDUL_27] [tinyint] NOT NULL ,
 [INDIVDUL_28] [tinyint] NOT NULL ,
 [INDIVDUL_29] [tinyint] NOT NULL ,
 [INDIVDUL_30] [tinyint] NOT NULL ,
 [INDIVDUL_31] [tinyint] NOT NULL ,
 [INDIVDUL_32] [tinyint] NOT NULL ,
 [INDIVDUL_33] [tinyint] NOT NULL ,
 [INDIVDUL_34] [tinyint] NOT NULL ,
 [INDIVDUL_35] [tinyint] NOT NULL ,
 [INDIVDUL_36] [tinyint] NOT NULL ,
 [INDIVDUL_37] [tinyint] NOT NULL ,
 [INDIVDUL_38] [tinyint] NOT NULL ,
 [INDIVDUL_39] [tinyint] NOT NULL ,
 [INDIVDUL_40] [tinyint] NOT NULL ,
 [INDIVDUL_41] [tinyint] NOT NULL ,
 [PRNTDSCR] [smallint] NOT NULL ,
 [PRZROBAL] [tinyint] NOT NULL ,
 [CLCRATIO] [smallint] NOT NULL ,
 [INCLGNDS] [tinyint] NOT NULL ,
 [GLSTTKDT] [smallint] NOT NULL ,
 [GLENTKDT] [smallint] NOT NULL ,
 [PRUNTACT] [tinyint] NOT NULL ,
 [STACCNUM_1] [char] (3) NOT NULL ,
 [STACCNUM_2] [char] (3) NOT NULL ,
 [STACCNUM_3] [char] (5) NOT NULL ,
 [EDGACNUM_1] [char] (3) NOT NULL ,
 [EDGACNUM_2] [char] (3) NOT NULL ,
 [EDGACNUM_3] [char] (5) NOT NULL ,
 [SEGSRTBY] [smallint] NOT NULL ,
 [RANGEBY] [smallint] NOT NULL ,
 [ACCLSTAT] [smallint] NOT NULL ,
 [USEACCEL] [tinyint] NOT NULL ,
 [CBZBNA] [tinyint] NOT NULL ,
 [Accounts_Included] [smallint] NOT NULL ,
 [Start_Position_String] [char] (89) NOT NULL ,
 [End_Position_String] [char] (89) NOT NULL ,
 [RPTXRATE] [numeric](19, 7) NOT NULL ,
 [RPRTCLMD] [smallint] NOT NULL ,
 [PRTCURIN] [smallint] NOT NULL ,
 [Checkbook_Date] [datetime] NOT NULL ,
 [End_Month] [smallint] NOT NULL ,
 [Start_Month] [smallint] NOT NULL ,
 [YEAR1] [smallint] NOT NULL ,
 [INCMCINF] [tinyint] NOT NULL ,
 [STCURRID] [char] (15) NOT NULL ,
 [ENDCURID] [char] (15) NOT NULL ,
 [Include_Voided_Trx] [tinyint] NOT NULL ,
 [DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL ,
 CONSTRAINT [PKGL70500] PRIMARY KEY  NONCLUSTERED 
 (
 [RPTGRIND],
 [RTPACHIN],
 [RTGRSBIN]
 )  ON [PRIMARY] ,
 CHECK (datepart(hour,[Checkbook_Date]) = 0 and datepart(minute,[Checkbook_Date]) = 0 and datepart(second,[Checkbook_Date]) = 0 and datepart(millisecond,[Checkbook_Date]) = 0),
 CHECK (datepart(hour,[ENDINGDT]) = 0 and datepart(minute,[ENDINGDT]) = 0 and datepart(second,[ENDINGDT]) = 0 and datepart(millisecond,[ENDINGDT]) = 0),
 CHECK (datepart(hour,[STRTNGDT]) = 0 and datepart(minute,[STRTNGDT]) = 0 and datepart(second,[STRTNGDT]) = 0 and datepart(millisecond,[STRTNGDT]) = 0)
) ON [PRIMARY]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[ACCLSTAT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[ASKECHTM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[Accounts_Included]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[CBINACTS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[CBZBNA]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[CLCRATIO]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[GL70500].[Checkbook_Date]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[EDGACNUM_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[EDGACNUM_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[EDGACNUM_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENBDBSDS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENBDBSID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENCHBKID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENCNTNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENDACDSC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[ENDCATEG]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENDCATNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENDCMTRXNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENDCURID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENDDESCR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[ENDGENINT1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[ENDGENINT2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[GL70500].[ENDINGDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[ENDJRNAL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENDOCNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENDSEGID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENDSRCDC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENMASTID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENMASTNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENTRXSRC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[ENUSRDF1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[EXPTTYPE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[End_Month]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[End_Position_String]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[FILEXPNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[FINRPTNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[GLENTKDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[GLSTTKDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[IFFILXST]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INCLGNDS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INCMCINF]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_14]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_15]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_16]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_17]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_18]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_19]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_20]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_21]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_22]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_23]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_24]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_25]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_26]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_27]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_28]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_29]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_30]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_31]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_32]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_33]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_34]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_35]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_36]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_37]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_38]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_39]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_40]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_41]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[INDIVDUL_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[Include_Voided_Trx]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PRNTDSCR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PRNTOFIL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PRNTTYPE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PRRPTFOR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PRTCURIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PRTOPRTR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PRTOSCRN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PRUNTACT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[PRVYRCMB]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PRZROBAL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[PSTNGACT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[RANGEBY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[REPORTID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[RPRTCLMD]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[RPRTSHOW]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[RPTDETAL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[RPTGRIND]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL70500].[RPTXRATE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL70500].[RTGRSBIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[RTPACHIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[SEGSRTBY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[SORTBY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[SSRCEDOC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STACCNUM_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STACCNUM_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STACCNUM_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STBDBSDS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STBDBSID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STCHBKID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STCTRNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STCURRID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STDOCNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[STGENINT1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[STGENINT2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STMASTID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STMASTNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STRTCMTRXNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STRTDSCR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[STRTJRNL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[GL70500].[STRTNGDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STRXSRC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STTACDSC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[STTCATEG]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STTCATNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STTSEGID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[STTUDEF1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[Start_Month]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70500].[Start_Position_String]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[UNITACCT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[USEACCEL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70500].[YEAR1]'
GO

setuser
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[GL70500]  TO [DYNGRP]
GO

/*End_GL70500*/
/*Begin_GL70501*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GL70501]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[GL70501]
GO

CREATE TABLE [dbo].[GL70501] (
 [USERID] [char] (15) NOT NULL ,
 [IFFILXST] [smallint] NOT NULL ,
 [FILEXPNM] [char] (255) NOT NULL ,
 [EXPTTYPE] [smallint] NOT NULL ,
 [ASKECHTM] [tinyint] NOT NULL ,
 [PRNTOFIL] [tinyint] NOT NULL ,
 [PRTOPRTR] [tinyint] NOT NULL ,
 [PRTOSCRN] [tinyint] NOT NULL ,
 [PRNTTYPE] [smallint] NOT NULL ,
 [RPTGRIND] [smallint] NOT NULL ,
 [RTPACHIN] [smallint] NOT NULL ,
 [RTGRSBIN] [numeric](19, 5) NOT NULL ,
 [SEQNUMBR] [int] NOT NULL ,
 [REPORTID] [smallint] NOT NULL ,
 [FINRPTNM] [char] (31) NOT NULL ,
 [STTUDEF1] [char] (21) NOT NULL ,
 [ENUSRDF1] [char] (21) NOT NULL ,
 [STGENINT1] [smallint] NOT NULL ,
 [ENDGENINT1] [smallint] NOT NULL ,
 [STGENINT2] [smallint] NOT NULL ,
 [ENDGENINT2] [smallint] NOT NULL ,
 [STRTNGDT] [datetime] NOT NULL ,
 [ENDINGDT] [datetime] NOT NULL ,
 [STTCATEG] [smallint] NOT NULL ,
 [ENDCATEG] [smallint] NOT NULL ,
 [STTCATNM] [char] (41) NOT NULL ,
 [ENDCATNM] [char] (41) NOT NULL ,
 [STRTJRNL] [int] NOT NULL ,
 [ENDJRNAL] [int] NOT NULL ,
 [STRXSRC] [char] (13) NOT NULL ,
 [ENTRXSRC] [char] (13) NOT NULL ,
 [STRTCMTRXNUM] [char] (21) NOT NULL ,
 [ENDCMTRXNUM] [char] (21) NOT NULL ,
 [SSRCEDOC] [char] (11) NOT NULL ,
 [ENDSRCDC] [char] (11) NOT NULL ,
 [STTACDSC] [char] (51) NOT NULL ,
 [ENDACDSC] [char] (51) NOT NULL ,
 [STBDBSID] [char] (15) NOT NULL ,
 [ENBDBSID] [char] (15) NOT NULL ,
 [STBDBSDS] [char] (31) NOT NULL ,
 [ENBDBSDS] [char] (31) NOT NULL ,
 [STCHBKID] [char] (15) NOT NULL ,
 [ENCHBKID] [char] (15) NOT NULL ,
 [STRTDSCR] [char] (51) NOT NULL ,
 [ENDDESCR] [char] (51) NOT NULL ,
 [STTSEGID] [char] (11) NOT NULL ,
 [ENDSEGID] [char] (11) NOT NULL ,
 [STCTRNUM] [char] (21) NOT NULL ,
 [ENCNTNUM] [char] (21) NOT NULL ,
 [STDOCNUM] [char] (21) NOT NULL ,
 [ENDOCNUM] [char] (21) NOT NULL ,
 [STMASTID] [char] (21) NOT NULL ,
 [ENMASTID] [char] (21) NOT NULL ,
 [STMASTNM] [char] (31) NOT NULL ,
 [ENMASTNM] [char] (31) NOT NULL ,
 [SORTBY] [smallint] NOT NULL ,
 [CBINACTS] [tinyint] NOT NULL ,
 [PSTNGACT] [smallint] NOT NULL ,
 [UNITACCT] [smallint] NOT NULL ,
 [RPRTSHOW] [smallint] NOT NULL ,
 [PRRPTFOR] [smallint] NOT NULL ,
 [PRVYRCMB] [char] (5) NOT NULL ,
 [RPTDETAL] [smallint] NOT NULL ,
 [INDIVDUL_1] [tinyint] NOT NULL ,
 [INDIVDUL_2] [tinyint] NOT NULL ,
 [INDIVDUL_3] [tinyint] NOT NULL ,
 [INDIVDUL_4] [tinyint] NOT NULL ,
 [INDIVDUL_5] [tinyint] NOT NULL ,
 [INDIVDUL_6] [tinyint] NOT NULL ,
 [INDIVDUL_7] [tinyint] NOT NULL ,
 [INDIVDUL_8] [tinyint] NOT NULL ,
 [INDIVDUL_9] [tinyint] NOT NULL ,
 [INDIVDUL_10] [tinyint] NOT NULL ,
 [INDIVDUL_11] [tinyint] NOT NULL ,
 [INDIVDUL_12] [tinyint] NOT NULL ,
 [INDIVDUL_13] [tinyint] NOT NULL ,
 [INDIVDUL_14] [tinyint] NOT NULL ,
 [INDIVDUL_15] [tinyint] NOT NULL ,
 [INDIVDUL_16] [tinyint] NOT NULL ,
 [INDIVDUL_17] [tinyint] NOT NULL ,
 [INDIVDUL_18] [tinyint] NOT NULL ,
 [INDIVDUL_19] [tinyint] NOT NULL ,
 [INDIVDUL_20] [tinyint] NOT NULL ,
 [INDIVDUL_21] [tinyint] NOT NULL ,
 [INDIVDUL_22] [tinyint] NOT NULL ,
 [INDIVDUL_23] [tinyint] NOT NULL ,
 [INDIVDUL_24] [tinyint] NOT NULL ,
 [INDIVDUL_25] [tinyint] NOT NULL ,
 [INDIVDUL_26] [tinyint] NOT NULL ,
 [INDIVDUL_27] [tinyint] NOT NULL ,
 [INDIVDUL_28] [tinyint] NOT NULL ,
 [INDIVDUL_29] [tinyint] NOT NULL ,
 [INDIVDUL_30] [tinyint] NOT NULL ,
 [INDIVDUL_31] [tinyint] NOT NULL ,
 [INDIVDUL_32] [tinyint] NOT NULL ,
 [INDIVDUL_33] [tinyint] NOT NULL ,
 [INDIVDUL_34] [tinyint] NOT NULL ,
 [INDIVDUL_35] [tinyint] NOT NULL ,
 [INDIVDUL_36] [tinyint] NOT NULL ,
 [INDIVDUL_37] [tinyint] NOT NULL ,
 [INDIVDUL_38] [tinyint] NOT NULL ,
 [INDIVDUL_39] [tinyint] NOT NULL ,
 [INDIVDUL_40] [tinyint] NOT NULL ,
 [INDIVDUL_41] [tinyint] NOT NULL ,
 [PRNTDSCR] [smallint] NOT NULL ,
 [PRZROBAL] [tinyint] NOT NULL ,
 [CLCRATIO] [smallint] NOT NULL ,
 [INCLGNDS] [tinyint] NOT NULL ,
 [GLSTTKDT] [smallint] NOT NULL ,
 [GLENTKDT] [smallint] NOT NULL ,
 [PRUNTACT] [tinyint] NOT NULL ,
 [STACCNUM_1] [char] (3) NOT NULL ,
 [STACCNUM_2] [char] (3) NOT NULL ,
 [STACCNUM_3] [char] (5) NOT NULL ,
 [EDGACNUM_1] [char] (3) NOT NULL ,
 [EDGACNUM_2] [char] (3) NOT NULL ,
 [EDGACNUM_3] [char] (5) NOT NULL ,
 [SEGSRTBY] [smallint] NOT NULL ,
 [RANGEBY] [smallint] NOT NULL ,
 [CBZBNA] [tinyint] NOT NULL ,
 [Accounts_Included] [smallint] NOT NULL ,
 [Start_Position_String] [char] (89) NOT NULL ,
 [End_Position_String] [char] (89) NOT NULL ,
 [RPTXRATE] [numeric](19, 7) NOT NULL ,
 [RPRTCLMD] [smallint] NOT NULL ,
 [PRTCURIN] [smallint] NOT NULL ,
 [INCMCINF] [tinyint] NOT NULL ,
 [STCURRID] [char] (15) NOT NULL ,
 [ENDCURID] [char] (15) NOT NULL ,
 [DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL ,
 CONSTRAINT [PKGL70501] PRIMARY KEY  NONCLUSTERED 
 (
 [USERID],
 [RPTGRIND],
 [RTPACHIN],
 [RTGRSBIN],
 [SEQNUMBR]
 )  ON [PRIMARY] ,
 CHECK (datepart(hour,[ENDINGDT]) = 0 and datepart(minute,[ENDINGDT]) = 0 and datepart(second,[ENDINGDT]) = 0 and datepart(millisecond,[ENDINGDT]) = 0),
 CHECK (datepart(hour,[STRTNGDT]) = 0 and datepart(minute,[STRTNGDT]) = 0 and datepart(second,[STRTNGDT]) = 0 and datepart(millisecond,[STRTNGDT]) = 0)
) ON [PRIMARY]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[ASKECHTM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[Accounts_Included]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[CBINACTS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[CBZBNA]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[CLCRATIO]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[EDGACNUM_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[EDGACNUM_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[EDGACNUM_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENBDBSDS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENBDBSID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENCHBKID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENCNTNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENDACDSC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[ENDCATEG]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENDCATNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENDCMTRXNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENDCURID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENDDESCR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[ENDGENINT1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[ENDGENINT2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[GL70501].[ENDINGDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[ENDJRNAL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENDOCNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENDSEGID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENDSRCDC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENMASTID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENMASTNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENTRXSRC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[ENUSRDF1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[EXPTTYPE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[End_Position_String]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[FILEXPNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[FINRPTNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[GLENTKDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[GLSTTKDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[IFFILXST]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INCLGNDS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INCMCINF]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_10]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_11]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_12]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_13]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_14]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_15]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_16]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_17]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_18]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_19]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_20]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_21]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_22]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_23]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_24]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_25]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_26]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_27]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_28]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_29]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_30]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_31]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_32]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_33]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_34]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_35]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_36]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_37]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_38]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_39]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_40]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_41]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_7]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_8]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[INDIVDUL_9]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PRNTDSCR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PRNTOFIL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PRNTTYPE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PRRPTFOR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PRTCURIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PRTOPRTR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PRTOSCRN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PRUNTACT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[PRVYRCMB]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PRZROBAL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[PSTNGACT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[RANGEBY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[REPORTID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[RPRTCLMD]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[RPRTSHOW]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[RPTDETAL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[RPTGRIND]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL70501].[RPTXRATE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[GL70501].[RTGRSBIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[RTPACHIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[SEGSRTBY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[SEQNUMBR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[SORTBY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[SSRCEDOC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STACCNUM_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STACCNUM_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STACCNUM_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STBDBSDS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STBDBSID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STCHBKID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STCTRNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STCURRID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STDOCNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[STGENINT1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[STGENINT2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STMASTID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STMASTNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STRTCMTRXNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STRTDSCR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[STRTJRNL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[GL70501].[STRTNGDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STRXSRC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STTACDSC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[STTCATEG]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STTCATNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STTSEGID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[STTUDEF1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[Start_Position_String]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[GL70501].[UNITACCT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[GL70501].[USERID]'
GO

setuser
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[GL70501]  TO [DYNGRP]
GO

/*End_GL70501*/


/*Script 3*/
insert into GL10110
( 
ACTINDX,YEAR1,PERIODID,PERDBLNC,ACTNUMBR_1,ACTNUMBR_2,                                                                                                                                                                                                         
ACTNUMBR_3,ACCATNUM,CRDTAMNT,DEBITAMT)

select
 
ACTINDX,YEAR1,PERIODID,PERDBLNC,ACTNUMBR_1,ACTNUMBR_2,                                                                                                                                                                                                         
ACTNUMBR_3,ACCATNUM,CRDTAMNT,DEBITAMT   
from GL10110bkp


go

insert into GL10111
(ACTINDX,YEAR1,PERIODID,ACTNUMBR_1,ACTNUMBR_2,ACTNUMBR_3,                                                                                                                                                                                                       
ACCATNUM,PERDBLNC,CRDTAMNT,DEBITAMT)
select
ACTINDX,YEAR1,PERIODID,ACTNUMBR_1,ACTNUMBR_2,ACTNUMBR_3,                                                                                                                                                                                                       
ACCATNUM,PERDBLNC,CRDTAMNT,DEBITAMT 
from GL10111bkp

go


insert into GL70500 (
 
 
IFFILXST,FILEXPNM,EXPTTYPE,ASKECHTM,PRNTOFIL,PRTOPRTR,                                                                                                                                                                                                         
PRTOSCRN,PRNTTYPE,RPTGRIND,RTPACHIN,RTGRSBIN,REPORTID,                                                                                                                                                                                                         
FINRPTNM,STGENINT1,ENDGENINT1,STGENINT2,ENDGENINT2,STRTNGDT,                                                                                                                                                                                                   
ENDINGDT,STTCATEG,STTUDEF1,ENUSRDF1,ENDCATEG,STTCATNM,                                                                                                                                                                                                         
ENDCATNM,STRTJRNL,ENDJRNAL,STRXSRC,ENTRXSRC,STRTCMTRXNUM,                                                                                                                                                                                                      
ENDCMTRXNUM,SSRCEDOC,ENDSRCDC,STTACDSC,ENDACDSC,STBDBSID,                                                                                                                                                                                                      
ENBDBSID,STBDBSDS,ENBDBSDS,STCHBKID,ENCHBKID,STRTDSCR,                                                                                                                                                                                                         
ENDDESCR,STTSEGID,ENDSEGID,STCTRNUM,ENCNTNUM,STDOCNUM,                                                                                                                                                                                                         
ENDOCNUM,STMASTID,ENMASTID,STMASTNM,ENMASTNM,SORTBY,                                                                                                                                                                                                           
CBINACTS,PSTNGACT,UNITACCT,RPRTSHOW,PRRPTFOR,PRVYRCMB,                                                                                                                                                                                                         
RPTDETAL,INDIVDUL_1,INDIVDUL_2,INDIVDUL_3,INDIVDUL_4,INDIVDUL_5,                                                                                                                                                                                               
INDIVDUL_6,INDIVDUL_7,INDIVDUL_8,INDIVDUL_9,INDIVDUL_10,INDIVDUL_11,                                                                                                                                                                                           
INDIVDUL_12,INDIVDUL_13,INDIVDUL_14,INDIVDUL_15,INDIVDUL_16,INDIVDUL_17,                                                                                                                                                                                       
INDIVDUL_18,INDIVDUL_19,INDIVDUL_20,INDIVDUL_21,INDIVDUL_22,INDIVDUL_23,                                                                                                                                                                                       
INDIVDUL_24,INDIVDUL_25,INDIVDUL_26,INDIVDUL_27,INDIVDUL_28,INDIVDUL_29,                                                                                                                                                                                       
INDIVDUL_30,INDIVDUL_31,INDIVDUL_32,INDIVDUL_33,INDIVDUL_34,INDIVDUL_35,                                                                                                                                                                                       
INDIVDUL_36,INDIVDUL_37,INDIVDUL_38,INDIVDUL_39,INDIVDUL_40,INDIVDUL_41,                                                                                                                                                                                       
PRNTDSCR,PRZROBAL,CLCRATIO,INCLGNDS,GLSTTKDT,GLENTKDT,                                                                                                                                                                                                         
PRUNTACT,STACCNUM_1,STACCNUM_2,STACCNUM_3,                                                                                                                                                                                               
EDGACNUM_1,EDGACNUM_2,EDGACNUM_3,SEGSRTBY,                                                                                                                                                                                               
RANGEBY,ACCLSTAT,USEACCEL,CBZBNA,Accounts_Included,Start_Position_String,                                                                                                                                                                                      
End_Position_String,RPTXRATE,RPRTCLMD,PRTCURIN,Checkbook_Date,End_Month,                                                                                                                                                                                       
Start_Month,YEAR1,INCMCINF,STCURRID,ENDCURID,Include_Voided_Trx                                                                                                                                                                                                

)

select
 
 
IFFILXST,FILEXPNM,EXPTTYPE,ASKECHTM,PRNTOFIL,PRTOPRTR,                                                                                                                                                                                                         
PRTOSCRN,PRNTTYPE,RPTGRIND,RTPACHIN,RTGRSBIN,REPORTID,                                                                                                                                                                                                         
FINRPTNM,STGENINT1,ENDGENINT1,STGENINT2,ENDGENINT2,STRTNGDT,                                                                                                                                                                                                   
ENDINGDT,STTCATEG,STTUDEF1,ENUSRDF1,ENDCATEG,STTCATNM,                                                                                                                                                                                                         
ENDCATNM,STRTJRNL,ENDJRNAL,STRXSRC,ENTRXSRC,STRTCMTRXNUM,                                                                                                                                                                                                      
ENDCMTRXNUM,SSRCEDOC,ENDSRCDC,STTACDSC,ENDACDSC,STBDBSID,                                                                                                                                                                                                      
ENBDBSID,STBDBSDS,ENBDBSDS,STCHBKID,ENCHBKID,STRTDSCR,                                                                                                                                                                                                         
ENDDESCR,STTSEGID,ENDSEGID,STCTRNUM,ENCNTNUM,STDOCNUM,                                                                                                                                                                                                         
ENDOCNUM,STMASTID,ENMASTID,STMASTNM,ENMASTNM,SORTBY,                                                                                                                                                                                                           
CBINACTS,PSTNGACT,UNITACCT,RPRTSHOW,PRRPTFOR,PRVYRCMB,                                                                                                                                                                                                         
RPTDETAL,INDIVDUL_1,INDIVDUL_2,INDIVDUL_3,INDIVDUL_4,INDIVDUL_5,                                                                                                                                                                                               
INDIVDUL_6,INDIVDUL_7,INDIVDUL_8,INDIVDUL_9,INDIVDUL_10,INDIVDUL_11,                                                                                                                                                                                           
INDIVDUL_12,INDIVDUL_13,INDIVDUL_14,INDIVDUL_15,INDIVDUL_16,INDIVDUL_17,                                                                                                                                                                                       
INDIVDUL_18,INDIVDUL_19,INDIVDUL_20,INDIVDUL_21,INDIVDUL_22,INDIVDUL_23,                                                                                                                                                                                       
INDIVDUL_24,INDIVDUL_25,INDIVDUL_26,INDIVDUL_27,INDIVDUL_28,INDIVDUL_29,                                                                                                                                                                                       
INDIVDUL_30,INDIVDUL_31,INDIVDUL_32,INDIVDUL_33,INDIVDUL_34,INDIVDUL_35,                                                                                                                                                                                       
INDIVDUL_36,INDIVDUL_37,INDIVDUL_38,INDIVDUL_39,INDIVDUL_40,INDIVDUL_41,                                                                                                                                                                                       
PRNTDSCR,PRZROBAL,CLCRATIO,INCLGNDS,GLSTTKDT,GLENTKDT,                                                                                                                                                                                                         
PRUNTACT,STACCNUM_1,STACCNUM_2,STACCNUM_3,                                                                                                                                                                                               
EDGACNUM_1,EDGACNUM_2,EDGACNUM_3,SEGSRTBY,                                                                                                                                                                                               
RANGEBY,ACCLSTAT,USEACCEL,CBZBNA,Accounts_Included,Start_Position_String,                                                                                                                                                                                      
End_Position_String,RPTXRATE,RPRTCLMD,PRTCURIN,Checkbook_Date,End_Month,                                                                                                                                                                                       
Start_Month,YEAR1,INCMCINF,STCURRID,ENDCURID,Include_Voided_Trx                                                                                                                                                                                                

from GL70500bkp

go

insert into GL70501
(
 
 
USERID,IFFILXST,FILEXPNM,EXPTTYPE,ASKECHTM,PRNTOFIL,                                                                                                                                                                                                           
PRTOPRTR,PRTOSCRN,PRNTTYPE,RPTGRIND,RTPACHIN,RTGRSBIN,                                                                                                                                                                                                         
SEQNUMBR,REPORTID,FINRPTNM,STTUDEF1,ENUSRDF1,STGENINT1,                                                                                                                                                                                                        
ENDGENINT1,STGENINT2,ENDGENINT2,STRTNGDT,ENDINGDT,STTCATEG,                                                                                                                                                                                                    
ENDCATEG,STTCATNM,ENDCATNM,STRTJRNL,ENDJRNAL,STRXSRC,                                                                                                                                                                                                          
ENTRXSRC,STRTCMTRXNUM,ENDCMTRXNUM,SSRCEDOC,ENDSRCDC,STTACDSC,                                                                                                                                                                                                  
ENDACDSC,STBDBSID,ENBDBSID,STBDBSDS,ENBDBSDS,STCHBKID,                                                                                                                                                                                                         
ENCHBKID,STRTDSCR,ENDDESCR,STTSEGID,ENDSEGID,STCTRNUM,                                                                                                                                                                                                         
ENCNTNUM,STDOCNUM,ENDOCNUM,STMASTID,ENMASTID,STMASTNM,                                                                                                                                                                                                         
ENMASTNM,SORTBY,CBINACTS,PSTNGACT,UNITACCT,RPRTSHOW,                                                                                                                                                                                                           
PRRPTFOR,PRVYRCMB,RPTDETAL,INDIVDUL_1,INDIVDUL_2,INDIVDUL_3,                                                                                                                                                                                                   
INDIVDUL_4,INDIVDUL_5,INDIVDUL_6,INDIVDUL_7,INDIVDUL_8,INDIVDUL_9,                                                                                                                                                                                             
INDIVDUL_10,INDIVDUL_11,INDIVDUL_12,INDIVDUL_13,INDIVDUL_14,INDIVDUL_15,                                                                                                                                                                                       
INDIVDUL_16,INDIVDUL_17,INDIVDUL_18,INDIVDUL_19,INDIVDUL_20,INDIVDUL_21,                                                                                                                                                                                       
INDIVDUL_22,INDIVDUL_23,INDIVDUL_24,INDIVDUL_25,INDIVDUL_26,INDIVDUL_27,                                                                                                                                                                                       
INDIVDUL_28,INDIVDUL_29,INDIVDUL_30,INDIVDUL_31,INDIVDUL_32,INDIVDUL_33,                                                                                                                                                                                       
INDIVDUL_34,INDIVDUL_35,INDIVDUL_36,INDIVDUL_37,INDIVDUL_38,INDIVDUL_39,                                                                                                                                                                                       
INDIVDUL_40,INDIVDUL_41,PRNTDSCR,PRZROBAL,CLCRATIO,INCLGNDS,                                                                                                                                                                                                   
GLSTTKDT,GLENTKDT,PRUNTACT,STACCNUM_1,STACCNUM_2,STACCNUM_3,                                                                                                                                                                                                   
EDGACNUM_1,EDGACNUM_2,EDGACNUM_3,                                                                                                                                                                                             
SEGSRTBY,RANGEBY,CBZBNA,Accounts_Included,Start_Position_String,                                                                                                                                                                                    
End_Position_String,RPTXRATE,RPRTCLMD,PRTCURIN,INCMCINF,STCURRID,                                                                                                                                                                                              
ENDCURID)

select USERID,IFFILXST,FILEXPNM,EXPTTYPE,ASKECHTM,PRNTOFIL,                                                                                                                                                                                                           
PRTOPRTR,PRTOSCRN,PRNTTYPE,RPTGRIND,RTPACHIN,RTGRSBIN,                                                                                                                                                                                                         
SEQNUMBR,REPORTID,FINRPTNM,STTUDEF1,ENUSRDF1,STGENINT1,                                                                                                                                                                                                        
ENDGENINT1,STGENINT2,ENDGENINT2,STRTNGDT,ENDINGDT,STTCATEG,                                                                                                                                                                                                    
ENDCATEG,STTCATNM,ENDCATNM,STRTJRNL,ENDJRNAL,STRXSRC,                                                                                                                                                                                                          
ENTRXSRC,STRTCMTRXNUM,ENDCMTRXNUM,SSRCEDOC,ENDSRCDC,STTACDSC,                                                                                                                                                                                                  
ENDACDSC,STBDBSID,ENBDBSID,STBDBSDS,ENBDBSDS,STCHBKID,                                                                                                                                                                                                         
ENCHBKID,STRTDSCR,ENDDESCR,STTSEGID,ENDSEGID,STCTRNUM,                                                                                                                                                                                                         
ENCNTNUM,STDOCNUM,ENDOCNUM,STMASTID,ENMASTID,STMASTNM,                                                                                                                                                                                                         
ENMASTNM,SORTBY,CBINACTS,PSTNGACT,UNITACCT,RPRTSHOW,                                                                                                                                                                                                           
PRRPTFOR,PRVYRCMB,RPTDETAL,INDIVDUL_1,INDIVDUL_2,INDIVDUL_3,                                                                                                                                                                                                   
INDIVDUL_4,INDIVDUL_5,INDIVDUL_6,INDIVDUL_7,INDIVDUL_8,INDIVDUL_9,                                                                                                                                                                                             
INDIVDUL_10,INDIVDUL_11,INDIVDUL_12,INDIVDUL_13,INDIVDUL_14,INDIVDUL_15,                                                                                                                                                                                       
INDIVDUL_16,INDIVDUL_17,INDIVDUL_18,INDIVDUL_19,INDIVDUL_20,INDIVDUL_21,                                                                                                                                                                                       
INDIVDUL_22,INDIVDUL_23,INDIVDUL_24,INDIVDUL_25,INDIVDUL_26,INDIVDUL_27,                                                                                                                                                                                       
INDIVDUL_28,INDIVDUL_29,INDIVDUL_30,INDIVDUL_31,INDIVDUL_32,INDIVDUL_33,                                                                                                                                                                                       
INDIVDUL_34,INDIVDUL_35,INDIVDUL_36,INDIVDUL_37,INDIVDUL_38,INDIVDUL_39,                                                                                                                                                                                       
INDIVDUL_40,INDIVDUL_41,PRNTDSCR,PRZROBAL,CLCRATIO,INCLGNDS,                                                                                                                                                                                                   
GLSTTKDT,GLENTKDT,PRUNTACT,STACCNUM_1,STACCNUM_2,STACCNUM_3,                                                                                                                                                                                                   
EDGACNUM_1,EDGACNUM_2,EDGACNUM_3,                                                                                                                                                                                             
SEGSRTBY,RANGEBY,CBZBNA,Accounts_Included,Start_Position_String,                                                                                                                                                                                    
End_Position_String,RPTXRATE,RPRTCLMD,PRTCURIN,INCMCINF,STCURRID,                                                                                                                                                                                              
ENDCURID                                                                                                                                                                                                                                                       
from GL70501bkp