INSERT INTO [AIS].[dbo].[PM10100]
           ([VCHRNMBR]
           ,[DSTSQNUM]
           ,[CNTRLTYP]
           ,[CRDTAMNT]
           ,[DEBITAMT]
           ,[DSTINDX]
           ,[DISTTYPE]
           ,[CHANGED]
           ,[USERID]
           ,[PSTGSTUS]
           ,[VENDORID]
           ,[TRXSORCE]
           ,[PSTGDATE]
           ,[INTERID]
           ,[CURNCYID]
           ,[CURRNIDX]
           ,[ORCRDAMT]
           ,[ORDBTAMT]
           ,[APTVCHNM]
           ,[APTODCTY]
           ,[SPCLDIST]
           ,[DistRef]
           ,[XCHGRATE]
           ,[EXCHDATE]
           ,[TIME1]
           ,[RTCLCMTD]
           ,[DECPLACS]
           ,[EXPNDATE]
           ,[ICCURRID]
           ,[ICCURRIX])
select [VCHRNMBR]
           ,[DSTSQNUM]
           ,[CNTRLTYP]
           ,[CRDTAMNT]
           ,[DEBITAMT]
           ,[DSTINDX]
           ,[DISTTYPE]
           ,[CHANGED]
           ,'manual 11182010'
           ,[PSTGSTUS]
           ,[VENDORID]
           ,[TRXSORCE]
           ,[PSTGDATE]
			,'AIS'
           ,[CURNCYID]
           ,[CURRNIDX]
           ,[ORCRDAMT]
           ,[ORDBTAMT]
           ,[APTVCHNM]
           ,[APTODCTY]
           ,[SPCLDIST]
           ,[DistRef],
			1,
			'01/01/1900',
			'01/01/1900',
			0,
			2,
			'01/01/1900',
			'USD2',
			1001
from [AIS].[dbo].[PM30600]
WHERE VCHRNMBR IN (SELECT VCHRNMBR FROM PM30200_11182010) AND DOCTYPE = 1