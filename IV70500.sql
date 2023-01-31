/*Begin_IV70500*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IV70500]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[IV70500]
GO

CREATE TABLE [dbo].[IV70500] (
 [PRTBYSIT] [smallint] NOT NULL ,
 [PRNTOPTN] [smallint] NOT NULL ,
 [STTGNDSC] [char] (11) NOT NULL ,
 [ENGENDSC] [char] (11) NOT NULL ,
 [ENUSRCAT_1] [char] (11) NOT NULL ,
 [ENUSRCAT_2] [char] (11) NOT NULL ,
 [ENUSRCAT_3] [char] (11) NOT NULL ,
 [ENUSRCAT_4] [char] (11) NOT NULL ,
 [ENUSRCAT_5] [char] (11) NOT NULL ,
 [ENUSRCAT_6] [char] (11) NOT NULL ,
 [KITSRTBY] [smallint] NOT NULL ,
 [STRTUCAT_1] [char] (11) NOT NULL ,
 [STRTUCAT_2] [char] (11) NOT NULL ,
 [STRTUCAT_3] [char] (11) NOT NULL ,
 [STRTUCAT_4] [char] (11) NOT NULL ,
 [STRTUCAT_5] [char] (11) NOT NULL ,
 [STRTUCAT_6] [char] (11) NOT NULL ,
 [STTITNUM] [char] (31) NOT NULL ,
 [ENITMNBR] [char] (31) NOT NULL ,
 [PRVDRINF] [smallint] NOT NULL ,
 [PRTDSCNT] [tinyint] NOT NULL ,
 [FINRPTNM] [char] (31) NOT NULL ,
 [PRNTNOTS] [tinyint] NOT NULL ,
 [PRNTTYPE] [smallint] NOT NULL ,
 [ASKECHTM] [tinyint] NOT NULL ,
 [INCLGNDS] [tinyint] NOT NULL ,
 [PRNTOFIL] [tinyint] NOT NULL ,
 [PRTOPRTR] [tinyint] NOT NULL ,
 [PRTOSCRN] [tinyint] NOT NULL ,
 [IFFILXST] [smallint] NOT NULL ,
 [FILEXPNM] [char] (255) NOT NULL ,
 [EXPTTYPE] [smallint] NOT NULL ,
 [RPTGRIND] [smallint] NOT NULL ,
 [STTCLASS] [char] (11) NOT NULL ,
 [ENDCLASS] [char] (11) NOT NULL ,
 [STTSCHED] [char] (11) NOT NULL ,
 [ENSCHDUL] [char] (11) NOT NULL ,
 [STTLOCCD] [char] (11) NOT NULL ,
 [ENLOCNCD] [char] (11) NOT NULL ,
 [STTLOTTY] [char] (11) NOT NULL ,
 [ENLOTTYP] [char] (11) NOT NULL ,
 [STRTNGDT] [datetime] NOT NULL ,
 [ENDINGDT] [datetime] NOT NULL ,
 [ENDTKNDT] [smallint] NOT NULL ,
 [STTOKNDT] [smallint] NOT NULL ,
 [STRCTNUM] [char] (21) NOT NULL ,
 [ENRCTNBR] [char] (21) NOT NULL ,
 [RTPACHIN] [smallint] NOT NULL ,
 [RTGRSBIN] [numeric](19, 5) NOT NULL ,
 [SORTBY] [smallint] NOT NULL ,
 [PRTSRLOT] [tinyint] NOT NULL ,
 [INZROQTY] [tinyint] NOT NULL ,
 [PRTITQTY] [tinyint] NOT NULL ,
 [STTBINUM] [char] (21) NOT NULL ,
 [ENBINNBR] [char] (21) NOT NULL ,
 [STDOCNUM] [char] (21) NOT NULL ,
 [ENDOCNUM] [char] (21) NOT NULL ,
 [STDOCTYP] [smallint] NOT NULL ,
 [ENDOCTYP] [smallint] NOT NULL ,
 [STTMODUL] [char] (3) NOT NULL ,
 [ENDMODUL] [char] (3) NOT NULL ,
 [STRXSRC] [char] (13) NOT NULL ,
 [ENTRXSRC] [char] (13) NOT NULL ,
 [STBCHSRC] [char] (15) NOT NULL ,
 [ENBCHSRC] [char] (15) NOT NULL ,
 [STBCHNUM] [char] (15) NOT NULL ,
 [ENDBNMBR] [char] (15) NOT NULL ,
 [STVNDRID] [char] (15) NOT NULL ,
 [ENDVNDID] [char] (15) NOT NULL ,
 [INQTYREQ] [tinyint] NOT NULL ,
 [INZRORLV] [tinyint] NOT NULL ,
 [CALSGQTY] [smallint] NOT NULL ,
 [RCPTOPTS] [smallint] NOT NULL ,
 [VENDROPT] [smallint] NOT NULL ,
 [SEGSRTBY] [smallint] NOT NULL ,
 [STTACNUM_1] [char] (3) NOT NULL ,
 [STTACNUM_2] [char] (3) NOT NULL ,
 [STTACNUM_3] [char] (5) NOT NULL ,
 [EACCNBR_1] [char] (3) NOT NULL ,
 [EACCNBR_2] [char] (3) NOT NULL ,
 [EACCNBR_3] [char] (5) NOT NULL ,
 [SEGMNTRG] [smallint] NOT NULL ,
 [Start_PriceLevel] [char] (11) NOT NULL ,
 [End_PriceLevel] [char] (11) NOT NULL ,
 [Start_QTY_Type] [smallint] NOT NULL ,
 [End_QTY_Type] [smallint] NOT NULL ,
 [Start_Component_Item_Num] [char] (31) NOT NULL ,
 [End_Component_Item_Numbe] [char] (31) NOT NULL ,
 [BM_Assembly_Journal] [tinyint] NOT NULL ,
 [BM_Distribution_Detail] [tinyint] NOT NULL ,
 [BM_Bill_Status_Active] [tinyint] NOT NULL ,
 [BM_Bill_Status_Pending] [tinyint] NOT NULL ,
 [BM_Bill_Status_Obsolete] [tinyint] NOT NULL ,
 [BM_Comp_Status_Active] [tinyint] NOT NULL ,
 [BM_Comp_Status_Pending] [tinyint] NOT NULL ,
 [BM_Comp_Status_Obsolete] [tinyint] NOT NULL ,
 [BM_Comp_Type_Misc_Charge] [tinyint] NOT NULL ,
 [BM_Comp_Type_Services] [tinyint] NOT NULL ,
 [BM_Comp_Type_Flat_Fee] [tinyint] NOT NULL ,
 [BM_Print_Notes_Bill] [tinyint] NOT NULL ,
 [BM_Print_Notes_Comp] [tinyint] NOT NULL ,
 [BM_Print_Cost_Options] [smallint] NOT NULL ,
 [Max_Levels] [smallint] NOT NULL ,
 [DATE1] [datetime] NOT NULL ,
 [BMTRXSTATNOTREL] [tinyint] NOT NULL ,
 [BMTRXSTATREL] [tinyint] NOT NULL ,
 [OPTIONS] [smallint] NOT NULL ,
 [Start_TRX_ID] [char] (19) NOT NULL ,
 [End_TRX_ID] [char] (19) NOT NULL ,
 [Starting_TRX_Date] [datetime] NOT NULL ,
 [Ending_TRX_Date] [datetime] NOT NULL ,
 [STRTSRLT] [char] (21) NOT NULL ,
 [ENDSERLT] [char] (21) NOT NULL ,
 [StartPriceGroup] [char] (11) NOT NULL ,
 [EndPriceGroup] [char] (11) NOT NULL ,
 [STCURRID] [char] (15) NOT NULL ,
 [ENDCURID] [char] (15) NOT NULL ,
 [STRTABCCD] [smallint] NOT NULL ,
 [ENDABCCD] [smallint] NOT NULL ,
 [STRTSTCKCNTID] [char] (15) NOT NULL ,
 [ENDSTCKCNTID] [char] (15) NOT NULL ,
 [Start_Landed_Cost_ID] [char] (15) NOT NULL ,
 [End_Landed_Cost_ID] [char] (15) NOT NULL ,
 [Start_LandedCostGroupID] [char] (15) NOT NULL ,
 [End_LandedCostGroupID] [char] (15) NOT NULL ,
 [ASOFDATE] [datetime] NOT NULL ,
 [INZRQTYI] [tinyint] NOT NULL ,
 [STARTBIN] [char] (15) NOT NULL ,
 [ENDBIN] [char] (15) NOT NULL ,
 [LNGSTRTDESC] [char] (101) NOT NULL ,
 [LNGENDDESC] [char] (101) NOT NULL ,
 [USEGLPOSTINGDATE] [tinyint] NOT NULL ,
 [INNGVQTY] [tinyint] NOT NULL ,
 [COSTAVGPERIODIC] [smallint] NOT NULL ,
 [DEX_ROW_ID] [int] IDENTITY (1, 1) NOT NULL ,
 CONSTRAINT [PKIV70500] PRIMARY KEY  NONCLUSTERED 
 (
 [RPTGRIND],
 [RTPACHIN],
 [RTGRSBIN]
 )  ON [PRIMARY] ,
 CHECK (datepart(hour,[ASOFDATE])=(0) AND datepart(minute,[ASOFDATE])=(0) AND datepart(second,[ASOFDATE])=(0) AND datepart(millisecond,[ASOFDATE])=(0)),
 CHECK (datepart(hour,[DATE1])=(0) AND datepart(minute,[DATE1])=(0) AND datepart(second,[DATE1])=(0) AND datepart(millisecond,[DATE1])=(0)),
 CHECK (datepart(hour,[ENDINGDT])=(0) AND datepart(minute,[ENDINGDT])=(0) AND datepart(second,[ENDINGDT])=(0) AND datepart(millisecond,[ENDINGDT])=(0)),
 CHECK (datepart(hour,[Ending_TRX_Date])=(0) AND datepart(minute,[Ending_TRX_Date])=(0) AND datepart(second,[Ending_TRX_Date])=(0) AND datepart(millisecond,[Ending_TRX_Date])=(0)),
 CHECK (datepart(hour,[STRTNGDT])=(0) AND datepart(minute,[STRTNGDT])=(0) AND datepart(second,[STRTNGDT])=(0) AND datepart(millisecond,[STRTNGDT])=(0)),
 CHECK (datepart(hour,[Starting_TRX_Date])=(0) AND datepart(minute,[Starting_TRX_Date])=(0) AND datepart(second,[Starting_TRX_Date])=(0) AND datepart(millisecond,[Starting_TRX_Date])=(0))
) ON [PRIMARY]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[ASKECHTM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[IV70500].[ASOFDATE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BMTRXSTATNOTREL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BMTRXSTATREL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Assembly_Journal]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Bill_Status_Active]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Bill_Status_Obsolete]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Bill_Status_Pending]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Comp_Status_Active]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Comp_Status_Obsolete]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Comp_Status_Pending]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Comp_Type_Flat_Fee]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Comp_Type_Misc_Charge]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Comp_Type_Services]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Distribution_Detail]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Print_Cost_Options]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Print_Notes_Bill]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[BM_Print_Notes_Comp]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[CALSGQTY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[COSTAVGPERIODIC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[IV70500].[DATE1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[EACCNBR_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[EACCNBR_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[EACCNBR_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENBCHSRC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENBINNBR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[ENDABCCD]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENDBIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENDBNMBR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENDCLASS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENDCURID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[IV70500].[ENDINGDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENDMODUL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENDOCNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[ENDOCTYP]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENDSERLT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENDSTCKCNTID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[ENDTKNDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENDVNDID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENGENDSC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENITMNBR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENLOCNCD]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENLOTTYP]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENRCTNBR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENSCHDUL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENTRXSRC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENUSRCAT_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENUSRCAT_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENUSRCAT_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENUSRCAT_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENUSRCAT_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[ENUSRCAT_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[EXPTTYPE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[EndPriceGroup]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[End_Component_Item_Numbe]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[End_LandedCostGroupID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[End_Landed_Cost_ID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[End_PriceLevel]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[End_QTY_Type]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[End_TRX_ID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[IV70500].[Ending_TRX_Date]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[FILEXPNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[FINRPTNM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[IFFILXST]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[INCLGNDS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[INNGVQTY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[INQTYREQ]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[INZROQTY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[INZRORLV]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[INZRQTYI]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[KITSRTBY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[LNGENDDESC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[LNGSTRTDESC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[Max_Levels]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[OPTIONS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRNTNOTS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRNTOFIL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRNTOPTN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRNTTYPE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRTBYSIT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRTDSCNT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRTITQTY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRTOPRTR]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRTOSCRN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRTSRLOT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[PRVDRINF]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[RCPTOPTS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[RPTGRIND]'
GO

EXEC sp_bindefault N'[dbo].[GPS_MONEY]', N'[IV70500].[RTGRSBIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[RTPACHIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[SEGMNTRG]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[SEGSRTBY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[SORTBY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STARTBIN]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STBCHNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STBCHSRC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STCURRID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STDOCNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[STDOCTYP]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRCTNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[STRTABCCD]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[IV70500].[STRTNGDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRTSRLT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRTSTCKCNTID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRTUCAT_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRTUCAT_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRTUCAT_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRTUCAT_4]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRTUCAT_5]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRTUCAT_6]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STRXSRC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTACNUM_1]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTACNUM_2]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTACNUM_3]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTBINUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTCLASS]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTGNDSC]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTITNUM]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTLOCCD]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTLOTTY]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTMODUL]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[STTOKNDT]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STTSCHED]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[STVNDRID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[StartPriceGroup]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[Start_Component_Item_Num]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[Start_LandedCostGroupID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[Start_Landed_Cost_ID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[Start_PriceLevel]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[Start_QTY_Type]'
GO

EXEC sp_bindefault N'[dbo].[GPS_CHAR]', N'[IV70500].[Start_TRX_ID]'
GO

EXEC sp_bindefault N'[dbo].[GPS_DATE]', N'[IV70500].[Starting_TRX_Date]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[USEGLPOSTINGDATE]'
GO

EXEC sp_bindefault N'[dbo].[GPS_INT]', N'[IV70500].[VENDROPT]'
GO

setuser
GO

GRANT  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[IV70500]  TO [DYNGRP]
GO

/*End_IV70500*/