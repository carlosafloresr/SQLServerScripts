USE [master]
GO

/****** Object:  LinkedServer [FIDepot_SyBase]    Script Date: 08/15/2013 12:49:09 PM ******/
EXEC master.dbo.sp_dropserver @server=N'FIDepot_SyBase', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [FIDepot_SyBase]    Script Date: 08/15/2013 12:49:09 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'FIDepot_SyBase', @srvproduct=N'Advantage', @provider=N'Advantage OLE DB Provider', @datasrc=N'\\LENSXTS003\DS4\DATA\', @provstr=N'ServeType=ADS_REMOTE_SERVER;TableType=ADS_VFP;SecurityMode=ADS_IGNORERIGHTS;LockMode=ADS_COMPATIBLE_LOCKING;CommType=TCP_IP;CharType=ADS_ANSI;DbfsUseNulls=TRUE;Early Metadata=True;collation compatible=false;query timeout=0;'

 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'FIDepot_SyBase',@useself=N'False',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
GO