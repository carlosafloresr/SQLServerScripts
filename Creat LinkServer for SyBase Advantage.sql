--EXEC sp_dropserver 'FIDepot_SyBase'
--GO

EXECUTE master.dbo.sp_addlinkedserver @server = N'FIDepot_SyBase', @srvproduct=N'Advantage', @provider=N'Advantage OLE DB Provider', @datasrc=N'\\LENSXTS003\DS4\DATA\', 
@provstr=N'ServeType=ADS_REMOTE_SERVER;TableType=ADS_VFP;SecurityMode=ADS_IGNORERIGHTS;LockMode=ADS_COMPATIBLE_LOCKING;CommType=TCP_IP;CharType=ADS_ANSI;DbfsUseNulls=TRUE;Early Metadata=True;'
GO

EXEC master.dbo.sp_serveroption @server=N'FIDepot_SyBase', @optname=N'data access', @optvalue=N'true';
EXEC master.dbo.sp_serveroption @server=N'FIDepot_SyBase', @optname=N'rpc out', @optvalue=N'true';
EXEC master.dbo.sp_serveroption @server=N'FIDepot_SyBase', @optname=N'connect timeout', @optvalue=N'0';
EXEC master.dbo.sp_serveroption @server=N'FIDepot_SyBase', @optname=N'collation name', @optvalue=null;
EXEC master.dbo.sp_serveroption @server=N'FIDepot_SyBase', @optname=N'query timeout', @optvalue=N'0';
EXEC master.dbo.sp_serveroption @server=N'FIDepot_SyBase', @optname=N'use remote collation', @optvalue=N'true';
EXEC master.dbo.sp_serveroption @server=N'FIDepot_SyBase', @optname=N'Use Early Metadata', @optvalue=N'true';
GO

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FIDepot_SyBase',@useself=N'False',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
GO

--\\LENSXTS003\DS4\DATA

DBCC TRACEON(3604, 7300)
GO

SELECT * FROM OPENQUERY(FIDepot_SyBase, 'SELECT * FROM invoices WHERE inv_no = 965100')
SELECT * FROM OPENQUERY(FIDepot_SyBase, 'SELECT INV.Inv_No FROM Invoices INV INNER JOIN (SELECT Inv_No FROM Transact WHERE Inv_No > 0 AND Last_Date = ''04/17/2013'') DAT ON INV.Inv_no = DAT.Inv_No')

go