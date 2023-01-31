/*
SELECT * FROM UPR41300
SELECT * FROM ILSGP01T.Dynamics.dbo.UPR41300

SELECT * FROM UPR41301
SELECT * FROM ILSGP01T.Dynamics.dbo.UPR41301

SELECT * FROM UPR41302
SELECT * FROM ILSGP01T.Dynamics.dbo.UPR41302

SELECT * FROM UPR41303
SELECT * FROM ILSGP01T.Dynamics.dbo.UPR41303
*/

TRUNCATE TABLE DYNAMICS.dbo.UPR41300
INSERT INTO DYNAMICS.dbo.UPR41300
           (TAXCODE
           ,DSCRIPTN
           ,TXCALCTN_1
           ,TXCALCTN_2
           ,TXCALCTN_3
           ,TXCALCTN_4
           ,TXCALCTN_5
           ,TXCALCTN_6
           ,TXCALCTN_7
           ,TXCALCTN_8
           ,TXCALCTN_9
           ,TXCALCTN_10
           ,ESTDEDTN
           ,DEPEXMPT
           ,MXEICPMT
           ,EXWGLIMT
           ,EXTXRATE)
SELECT		TAXCODE
           ,DSCRIPTN
           ,TXCALCTN_1
           ,TXCALCTN_2
           ,TXCALCTN_3
           ,TXCALCTN_4
           ,TXCALCTN_5
           ,TXCALCTN_6
           ,TXCALCTN_7
           ,TXCALCTN_8
           ,TXCALCTN_9
           ,TXCALCTN_10
           ,ESTDEDTN
           ,DEPEXMPT
           ,MXEICPMT
           ,EXWGLIMT
           ,EXTXRATE
FROM		ILSGP01T.Dynamics.dbo.UPR41300

TRUNCATE TABLE DYNAMICS.dbo.UPR41301
INSERT INTO DYNAMICS.dbo.UPR41301
           (TAXCODE
           ,TXFLGSTS
           ,STSDESCR
           ,LINCLIM
           ,PRSEXAMT
           ,INCPSNEX
           ,INCADALW
           ,INCLDEPN
           ,FDTXPRCT
           ,FEDTXMAX
           ,FICATXPT
           ,FICATXMN
           ,FLATAXRT
           ,STDDMTHD
           ,STDDPCNT
           ,STDDEDAM
           ,STDEDMIN
           ,STDEDMAX
           ,SPCLEXAM
           ,SPCLSDED
           ,SPCLTXRT)
SELECT		TAXCODE
           ,TXFLGSTS
           ,STSDESCR
           ,LINCLIM
           ,PRSEXAMT
           ,INCPSNEX
           ,INCADALW
           ,INCLDEPN
           ,FDTXPRCT
           ,FEDTXMAX
           ,FICATXPT
           ,FICATXMN
           ,FLATAXRT
           ,STDDMTHD
           ,STDDPCNT
           ,STDDEDAM
           ,STDEDMIN
           ,STDEDMAX
           ,SPCLEXAM
           ,SPCLSDED
           ,SPCLTXRT
FROM		ILSGP01T.Dynamics.dbo.UPR41301

TRUNCATE TABLE DYNAMICS.dbo.UPR41302
INSERT INTO DYNAMICS.dbo.UPR41302
           (TAXCODE
           ,TXFLGSTS
           ,TXTBLTYP
           ,TXTBLSEQ
           ,TXBRULMT
           ,TXBRKTAM
           ,RXBRKTRT
           ,TXBREXWG)
SELECT		TAXCODE
           ,TXFLGSTS
           ,TXTBLTYP
           ,TXTBLSEQ
           ,TXBRULMT
           ,TXBRKTAM
           ,RXBRKTRT
           ,TXBREXWG
FROM		ILSGP01T.Dynamics.dbo.UPR41302