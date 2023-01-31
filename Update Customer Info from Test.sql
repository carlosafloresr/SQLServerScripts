
UPDATE [dbo].[RM00101]
   SET [CUSTNAME] = data.[CUSTNAME]
      ,[CUSTCLAS] = data.[CUSTCLAS]
      ,[STMTNAME] = data.[STMTNAME]
      ,[ADRSCODE] = data.[ADRSCODE]
      ,[ADDRESS1] = data.[ADDRESS1]
      ,[ADDRESS2] = data.[ADDRESS2]
      ,[ADDRESS3] = data.[ADDRESS3]
      ,[COUNTRY] = data.[COUNTRY]
      ,[CITY] = data.[CITY]
      ,[STATE] = data.[STATE]
      ,[ZIP] = data.[ZIP]
      ,[PHONE1] = data.[PHONE1]
      ,[CHEKBKID] = data.[CHEKBKID]
      ,[MXWOFTYP] = data.[MXWOFTYP]
      ,[NOTEINDX] = data.[NOTEINDX]
      ,[ORDERFULFILLDEFAULT] = data.[ORDERFULFILLDEFAULT]
      ,[RMOvrpymtWrtoffAcctIdx] = data.[RMOvrpymtWrtoffAcctIdx]
from (
select * from LENSASQL001T.pts.DBO.rm00101 where custnmbr = 'MITCYP'
) data
 WHERE RM00101.CUSTNMBR = DATA.CUSTNMBR


