
-- sp_addlinkedserver 'DEPOT_RCMR','','MSDASQL',NULL,NULL,'DRIVER={Microsoft Visual FoxPro Driver};SourceDB=\\ilsrc01\DS4\DATA\;SourceType=DBC;NULL'

-- sp_addlinkedserver 'FIDEPOT','','[Advantage OLE DB Provider]',NULL,NULL,'DRIVER={Advantage OLE DB Provider};SourceDB=\\ilsrc01\DS4\DATA\;SourceType=DBC;NULL'

SELECT * FROM OPENQUERY(FIDEPOT, 'SELECT * FROM Invoices WHERE Inv_No = 338212')

EXEC master.dbo.sp_addlinkedserver 
  @server = N'FIDEPOT', @srvproduct=N'Advantage', 
  @provider=N'Advantage OLE DB Provider', 
  @datasrc=N'\\lensxts003\ds4\data\'


EXEC master.dbo.sp_addlinkedsrvlogin       
  @rmtsrvname=N'ADVANTAGE',
  @useself=N'False',
  @locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL