EXEC sp_addlinkedserver 
   @server = 'Pervasive', 
   @provider = 'MSDASQL', 
   @datasrc = 'OneView',
   @srvproduct = ''
GO

EXEC sp_addlinkedserver 
  @server = N'OneView', @srvproduct=N'Pervasive', 
  @provider=N'PervasiveOLEDB', 
  @datasrc=N'lensasql003.iilogistics.com'

-- DSN=Pervasive;ServerName=lensasql003.iilogistics.com.1583;UID=;PWD=;ArrayFetchOn=1;ArrayBufferSize=8;TransportHint=TCP:SPX;DBQ=IES;ClientVersion=11.30.051.000;CodePageConvert=1252;PvClientEncoding=CP1252;PvServerEncoding=CP1252;

SELECT * FROM Pervasive.OneView..AP_Hdr WHERE BL_number = 'IGS-0010148-9'