DECLARE	@Integration	varchar(6) = 'SPCGL', 
		@JustDisplay	bit = 0,
        @Company		varchar(5) = DB_NAME(),
        @BatchId		varchar(15),
		@DatePortion	Varchar(15) = GPCustom.dbo.PADL(MONTH(GETDATE()), 2, '0') + GPCustom.dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(GPCustom.dbo.PADL(YEAR(GETDATE()), 4, '0'), 2) + GPCustom.dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + GPCustom.dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0'),
		@PstgDate		date,
		@Refrence		varchar(100),
		@TrxDate		date = '02/25/2022',
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@SqncLine		int

SET @BatchId = 'BOACASDHFEB' --@Integration + @DatePortion

DECLARE @tblDataSource	Table (Description Varchar(30), GLAccount Varchar(15), Amount Numeric(10,2), Reference Varchar(30))
DECLARE @tblData		Table (Description Varchar(100), AcctCredit Varchar(15), AcctDebit Varchar(15), Amount Numeric(10,2))

-- ="INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('"&D2&"','"&E2&"',"&A2&",'"&C2&"')"

INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-04-1010',29148.1,'IMCH1')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-00-2106',-29148.1,'IMCH1')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CEVA 3348      ','0-04-1010',16313.25,'IMCH2')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CEVA 3348      ','0-00-2106',-16313.25,'IMCH2')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CMA CGM America','0-04-1010',3749.05,'IMCH3')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CMA CGM America','0-00-2106',-3749.05,'IMCH3')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH COMPASS LOGISTI','0-04-1010',1873.1,'IMCH4')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH COMPASS LOGISTI','0-00-2106',-1873.1,'IMCH4')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH LOWES          ','0-04-1010',13649.5,'IMCH5')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH LOWES          ','0-00-2106',-13649.5,'IMCH5')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH LOWES          ','0-04-1010',28375.05,'IMCH6')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH LOWES          ','0-00-2106',-28375.05,'IMCH6')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Lynden         ','0-04-1010',1408,'IMCH7')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Lynden         ','0-00-2106',-1408,'IMCH7')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH MODE TRANSPORTA','0-04-1010',2721.5,'IMCH8')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH MODE TRANSPORTA','0-00-2106',-2721.5,'IMCH8')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Nolan Transport','0-04-1010',8424,'IMCH9')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Nolan Transport','0-00-2106',-8424,'IMCH9')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH PERDUE FARMS   ','0-04-1010',8192.25,'IMCH10')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH PERDUE FARMS   ','0-00-2106',-8192.25,'IMCH10')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH PERDUE FARMS   ','0-04-1010',50629.5,'IMCH11')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH PERDUE FARMS   ','0-00-2106',-50629.5,'IMCH11')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH SENATOR INTERNA','0-04-1010',22204.5,'IMCH12')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH SENATOR INTERNA','0-00-2106',-22204.5,'IMCH12')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS LCKBX 0222','0-04-1010',45338.6,'IMCH13')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS LCKBX 0222','0-00-2106',-45338.6,'IMCH13')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH AGILITY LOGISTI','0-04-1010',6903.76,'IMCH14')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH AGILITY LOGISTI','0-00-2106',-6903.76,'IMCH14')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CAH 200  LLC   ','0-04-1010',2142,'IMCH15')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CAH 200  LLC   ','0-00-2106',-2142,'IMCH15')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CMA CGM America','0-04-1010',5791.68,'IMCH16')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CMA CGM America','0-00-2106',-5791.68,'IMCH16')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CROWLEY 7789   ','0-04-1010',916.41,'IMCH17')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CROWLEY 7789   ','0-00-2106',-916.41,'IMCH17')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CWL032 - Crane ','0-04-1010',11357.8,'IMCH18')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CWL032 - Crane ','0-00-2106',-11357.8,'IMCH18')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXPEDITORS INTL','0-04-1010',2220.4,'IMCH19')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXPEDITORS INTL','0-00-2106',-2220.4,'IMCH19')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXXONMOBIL0102 ','0-04-1010',225,'IMCH20')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXXONMOBIL0102 ','0-00-2106',-225,'IMCH20')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH ODYSSEY LOGNTEC','0-04-1010',940.43,'IMCH21')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH ODYSSEY LOGNTEC','0-00-2106',-940.43,'IMCH21')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH P04635 TRADEMAN','0-04-1010',3698,'IMCH22')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH P04635 TRADEMAN','0-00-2106',-3698,'IMCH22')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH U S BANK NA    ','0-04-1010',51401.02,'IMCH23')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH U S BANK NA    ','0-00-2106',-51401.02,'IMCH23')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH WERNER LOGISTIC','0-04-1010',1400,'IMCH24')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH WERNER LOGISTIC','0-00-2106',-1400,'IMCH24')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS LCKBX 0222','0-04-1010',51003.09,'IMCH25')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS LCKBX 0222','0-00-2106',-51003.09,'IMCH25')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH 443 CORNERSTONE','0-04-1010',4516.14,'IMCH26')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH 443 CORNERSTONE','0-00-2106',-4516.14,'IMCH26')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH DT GRUELLE COMP','0-04-1010',33392,'IMCH27')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH DT GRUELLE COMP','0-00-2106',-33392,'IMCH27')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH INTEPLAST GROUP','0-04-1010',20945,'IMCH28')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH INTEPLAST GROUP','0-00-2106',-20945,'IMCH28')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH INTEPLAST GROUP','0-04-1010',90010.3,'IMCH29')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH INTEPLAST GROUP','0-00-2106',-90010.3,'IMCH29')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH LASKO PRODUCTS ','0-04-1010',200,'IMCH30')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH LASKO PRODUCTS ','0-00-2106',-200,'IMCH30')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS LCKBX 0222','0-04-1010',29041.84,'IMCH31')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS LCKBX 0222','0-00-2106',-29041.84,'IMCH31')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH COYOTE LOGISTIC','0-04-1010',2940,'IMCH32')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH COYOTE LOGISTIC','0-00-2106',-2940,'IMCH32')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH CVBMALOUFOPERAC','0-04-1010',16925,'IMCH33')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH CVBMALOUFOPERAC','0-00-2106',-16925,'IMCH33')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Flexport Inc   ','0-04-1010',655.33,'IMCH34')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Flexport Inc   ','0-00-2106',-655.33,'IMCH34')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Hapag-Lloyd (Am','0-04-1010',281.4,'IMCH35')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Hapag-Lloyd (Am','0-00-2106',-281.4,'IMCH35')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Hapag-Lloyd (Am','0-04-1010',1849.28,'IMCH36')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Hapag-Lloyd (Am','0-00-2106',-1849.28,'IMCH36')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH HONDA DEV MFG  ','0-04-1010',18987.08,'IMCH37')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH HONDA DEV MFG  ','0-00-2106',-18987.08,'IMCH37')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH PETSMART LLC   ','0-04-1010',17024.51,'IMCH38')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH PETSMART LLC   ','0-00-2106',-17024.51,'IMCH38')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Schenker of Can','0-04-1010',941.23,'IMCH39')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Schenker of Can','0-00-2106',-941.23,'IMCH39')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS LCKBX 0222','0-04-1010',43118.53,'IMCH40')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS LCKBX 0222','0-00-2106',-43118.53,'IMCH40')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA From 3348','0-04-1010',370.48,'IMCH41')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA From 3348','0-04-1011',-370.48,'IMCH41')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA To 3348','0-04-1010',-9187.51,'IMCH42')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA To 3348','0-04-1011',9187.51,'IMCH42')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH APMARITI5 6462 ','0-04-1010',530,'IMCH43')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH APMARITI5 6462 ','0-00-2106',-530,'IMCH43')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH ATLANTA RAG COM','0-04-1010',5250,'IMCH44')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH ATLANTA RAG COM','0-00-2106',-5250,'IMCH44')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-04-1010',1875,'IMCH45')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-00-2106',-1875,'IMCH45')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-04-1010',1930,'IMCH46')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-00-2106',-1930,'IMCH46')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CARGOMATIC INC ','0-04-1010',114321.25,'IMCH47')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CARGOMATIC INC ','0-00-2106',-114321.25,'IMCH47')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CASS INFO. CARR','0-04-1010',11345.4,'IMCH48')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CASS INFO. CARR','0-00-2106',-11345.4,'IMCH48')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH DSV A/S        ','0-04-1010',4641,'IMCH49')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH DSV A/S        ','0-00-2106',-4641,'IMCH49')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Flexport Inc   ','0-04-1010',18078.04,'IMCH50')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Flexport Inc   ','0-00-2106',-18078.04,'IMCH50')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Hapag-Lloyd (Am','0-04-1010',51695.25,'IMCH51')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Hapag-Lloyd (Am','0-00-2106',-51695.25,'IMCH51')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Lynden         ','0-04-1010',1768,'IMCH52')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Lynden         ','0-00-2106',-1768,'IMCH52')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH OEC FREIGH     ','0-04-1010',795,'IMCH53')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH OEC FREIGH     ','0-00-2106',-795,'IMCH53')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-04-1010',3412.79,'IMCH54')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-00-2106',-3412.79,'IMCH54')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-04-1010',10137.46,'IMCH55')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-00-2106',-10137.46,'IMCH55')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS LCKBX 0223','0-04-1010',14951.5,'IMCH56')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS LCKBX 0223','0-00-2106',-14951.5,'IMCH56')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CAH 200  LLC   ','0-04-1010',1059.5,'IMCH57')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CAH 200  LLC   ','0-00-2106',-1059.5,'IMCH57')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXXONMOBIL0102 ','0-04-1010',28984.19,'IMCH58')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXXONMOBIL0102 ','0-00-2106',-28984.19,'IMCH58')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH HELLMANN       ','0-04-1010',1024.5,'IMCH59')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH HELLMANN       ','0-00-2106',-1024.5,'IMCH59')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH INTEPLAST GROUP','0-04-1010',1796.6,'IMCH60')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH INTEPLAST GROUP','0-00-2106',-1796.6,'IMCH60')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH Nippon Express ','0-04-1010',2113,'IMCH61')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH Nippon Express ','0-00-2106',-2113,'IMCH61')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH ROAR LOGISTICS ','0-04-1010',145043.53,'IMCH62')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH ROAR LOGISTICS ','0-00-2106',-145043.53,'IMCH62')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS LCKBX 0223','0-04-1010',608.8,'IMCH63')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS LCKBX 0223','0-00-2106',-608.8,'IMCH63')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH Harbor Freight ','0-04-1010',1789,'IMCH64')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH Harbor Freight ','0-00-2106',-1789,'IMCH64')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH INTEPLAST GROUP','0-04-1010',2207.5,'IMCH65')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH INTEPLAST GROUP','0-00-2106',-2207.5,'IMCH65')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH OEC FREIGH     ','0-04-1010',14832.15,'IMCH66')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH OEC FREIGH     ','0-00-2106',-14832.15,'IMCH66')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH PORT X SO - 360','0-04-1010',1074.44,'IMCH67')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH PORT X SO - 360','0-00-2106',-1074.44,'IMCH67')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH SCHENKER-9422  ','0-04-1010',9055.83,'IMCH68')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH SCHENKER-9422  ','0-00-2106',-9055.83,'IMCH68')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS LCKBX 0223','0-04-1010',6404,'IMCH69')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS LCKBX 0223','0-00-2106',-6404,'IMCH69')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH EKMAN RECYCLING','0-04-1010',3701.25,'IMCH70')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH EKMAN RECYCLING','0-00-2106',-3701.25,'IMCH70')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH EVERGREEN      ','0-04-1010',327,'IMCH71')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH EVERGREEN      ','0-00-2106',-327,'IMCH71')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Flexport Inc   ','0-04-1010',43460.1,'IMCH72')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Flexport Inc   ','0-00-2106',-43460.1,'IMCH72')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH HONDA DEV MFG  ','0-04-1010',9125,'IMCH73')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH HONDA DEV MFG  ','0-00-2106',-9125,'IMCH73')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH JCI LOGISTICS L','0-04-1010',2922.5,'IMCH74')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH JCI LOGISTICS L','0-00-2106',-2922.5,'IMCH74')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Ocean Network E','0-04-1010',18206.41,'IMCH75')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Ocean Network E','0-00-2106',-18206.41,'IMCH75')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH ROAR LOGISTICS ','0-04-1010',1963.5,'IMCH76')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH ROAR LOGISTICS ','0-00-2106',-1963.5,'IMCH76')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH WIRE TYPE:WIRE ','0-04-1010',30980,'IMCH77')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH WIRE TYPE:WIRE ','0-00-2106',-30980,'IMCH77')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS LCKBX 0223','0-04-1010',12094.61,'IMCH78')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS LCKBX 0223','0-00-2106',-12094.61,'IMCH78')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA To 3348','0-04-1010',-890976.07,'IMCH79')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA To 3348','0-04-1011',890976.07,'IMCH79')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-04-1010',822.5,'IMCH80')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-00-2106',-822.5,'IMCH80')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH DAYU ENTERPR896','0-04-1010',14099.28,'IMCH81')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH DAYU ENTERPR896','0-00-2106',-14099.28,'IMCH81')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Hapag-Lloyd (Am','0-04-1010',30500.45,'IMCH82')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Hapag-Lloyd (Am','0-00-2106',-30500.45,'IMCH82')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Hecny Transport','0-04-1010',23338,'IMCH83')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Hecny Transport','0-00-2106',-23338,'IMCH83')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Ocean Network E','0-04-1010',718.08,'IMCH84')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Ocean Network E','0-00-2106',-718.08,'IMCH84')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH OEC GRP NY9859 ','0-04-1010',678.5,'IMCH85')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH OEC GRP NY9859 ','0-00-2106',-678.5,'IMCH85')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH PERDUE FARMS   ','0-04-1010',3897,'IMCH86')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH PERDUE FARMS   ','0-00-2106',-3897,'IMCH86')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH SS BROKERGE    ','0-04-1010',1286.5,'IMCH87')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH SS BROKERGE    ','0-00-2106',-1286.5,'IMCH87')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-04-1010',1242,'IMCH88')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-00-2106',-1242,'IMCH88')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-04-1010',31147.92,'IMCH89')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-00-2106',-31147.92,'IMCH89')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH WIRE TYPE:WIRE ','0-04-1010',2821.25,'IMCH90')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH WIRE TYPE:WIRE ','0-00-2106',-2821.25,'IMCH90')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS LCKBX 0224','0-04-1010',12953.5,'IMCH91')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS LCKBX 0224','0-00-2106',-12953.5,'IMCH91')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CAH 200  LLC   ','0-04-1010',9746.94,'IMCH92')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CAH 200  LLC   ','0-00-2106',-9746.94,'IMCH92')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH DAYU ENTERPR896','0-04-1010',9846.6,'IMCH93')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH DAYU ENTERPR896','0-00-2106',-9846.6,'IMCH93')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH ECHO GLOBAL    ','0-04-1010',900,'IMCH94')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH ECHO GLOBAL    ','0-00-2106',-900,'IMCH94')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXXONMOBIL0102 ','0-04-1010',5131,'IMCH95')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXXONMOBIL0102 ','0-00-2106',-5131,'IMCH95')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH GEBRUDER WEI074','0-04-1010',5780,'IMCH96')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH GEBRUDER WEI074','0-00-2106',-5780,'IMCH96')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH LAUFER GROUP IN','0-04-1010',160,'IMCH97')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH LAUFER GROUP IN','0-00-2106',-160,'IMCH97')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH Ocean Network E','0-04-1010',2220,'IMCH98')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH Ocean Network E','0-00-2106',-2220,'IMCH98')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS LCKBX 0224','0-04-1010',1869.71,'IMCH99')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS LCKBX 0224','0-00-2106',-1869.71,'IMCH99')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH CASS INFO. CARR','0-04-1010',2078.76,'IMCH100')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH CASS INFO. CARR','0-00-2106',-2078.76,'IMCH100')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Hapag-Lloyd (Am','0-04-1010',13022.15,'IMCH101')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Hapag-Lloyd (Am','0-00-2106',-13022.15,'IMCH101')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Ocean Network E','0-04-1010',42715.14,'IMCH102')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Ocean Network E','0-00-2106',-42715.14,'IMCH102')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS LCKBX 0224','0-04-1010',1320,'IMCH103')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS LCKBX 0224','0-00-2106',-1320,'IMCH103')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA To 3348','0-04-1010',-480859.83,'IMCH104')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA To 3348','0-04-1011',480859.83,'IMCH104')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH APMARITI5 6462 ','0-04-1010',7680,'IMCH105')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH APMARITI5 6462 ','0-00-2106',-7680,'IMCH105')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH BIS - US NINGBO','0-04-1010',1254,'IMCH106')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH BIS - US NINGBO','0-00-2106',-1254,'IMCH106')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-04-1010',1030,'IMCH107')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-00-2106',-1030,'IMCH107')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-04-1010',5437.48,'IMCH108')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH C H ROBINSON   ','0-00-2106',-5437.48,'IMCH108')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CARGO ALLIANCE ','0-04-1010',1094,'IMCH109')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CARGO ALLIANCE ','0-00-2106',-1094,'IMCH109')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CASS INFO. CARR','0-04-1010',4418.79,'IMCH110')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH CASS INFO. CARR','0-00-2106',-4418.79,'IMCH110')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH EVERGREEN      ','0-04-1010',4297.8,'IMCH111')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH EVERGREEN      ','0-00-2106',-4297.8,'IMCH111')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Flexport Inc   ','0-04-1010',150,'IMCH112')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Flexport Inc   ','0-00-2106',-150,'IMCH112')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH FMS NA LLC     ','0-04-1010',9960.2,'IMCH113')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH FMS NA LLC     ','0-00-2106',-9960.2,'IMCH113')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH GENERA         ','0-04-1010',58742.5,'IMCH114')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH GENERA         ','0-00-2106',-58742.5,'IMCH114')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH MODE TRANSPORTA','0-04-1010',2535,'IMCH115')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH MODE TRANSPORTA','0-00-2106',-2535,'IMCH115')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Ocean Network E','0-04-1010',3466.76,'IMCH116')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Ocean Network E','0-00-2106',-3466.76,'IMCH116')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Orient Overseas','0-04-1010',33977.8,'IMCH117')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Orient Overseas','0-00-2106',-33977.8,'IMCH117')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH PETSMART LLC   ','0-04-1010',3005,'IMCH118')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH PETSMART LLC   ','0-00-2106',-3005,'IMCH118')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRANS WORLD LIN','0-04-1010',360,'IMCH119')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRANS WORLD LIN','0-00-2106',-360,'IMCH119')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Transworld Ship','0-04-1010',1643.25,'IMCH120')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH Transworld Ship','0-00-2106',-1643.25,'IMCH120')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-04-1010',1301,'IMCH121')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH TRIUMPHPAY     ','0-00-2106',-1301,'IMCH121')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH WIRE TYPE:WIRE ','0-04-1010',9864.25,'IMCH122')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH WIRE TYPE:WIRE ','0-00-2106',-9864.25,'IMCH122')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH YTC            ','0-04-1010',4235,'IMCH123')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS ACH YTC            ','0-00-2106',-4235,'IMCH123')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS LCKBX 0225','0-04-1010',3415.5,'IMCH124')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('AIS LCKBX 0225','0-00-2106',-3415.5,'IMCH124')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH AMERICAN WOOL S','0-04-1010',5825.2,'IMCH125')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH AMERICAN WOOL S','0-00-2106',-5825.2,'IMCH125')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CROWLEY 7789   ','0-04-1010',1069.32,'IMCH126')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH CROWLEY 7789   ','0-00-2106',-1069.32,'IMCH126')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH DHY SHIPPING LI','0-04-1010',2132.72,'IMCH127')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH DHY SHIPPING LI','0-00-2106',-2132.72,'IMCH127')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXXONMOBIL0102 ','0-04-1010',14839.44,'IMCH128')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH EXXONMOBIL0102 ','0-00-2106',-14839.44,'IMCH128')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH Ocean Network E','0-04-1010',1101.95,'IMCH129')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH Ocean Network E','0-00-2106',-1101.95,'IMCH129')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH ROAR LOGISTICS ','0-04-1010',33005.6,'IMCH130')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH ROAR LOGISTICS ','0-00-2106',-33005.6,'IMCH130')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SCHENKER-9422  ','0-04-1010',5782.72,'IMCH131')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SCHENKER-9422  ','0-00-2106',-5782.72,'IMCH131')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',70,'IMCH132')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-70,'IMCH132')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',105,'IMCH133')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-105,'IMCH133')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',140,'IMCH134')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',140,'IMCH134')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',140,'IMCH135')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',140,'IMCH135')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-140,'IMCH136')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-140,'IMCH136')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-140,'IMCH137')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-140,'IMCH137')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',175,'IMCH138')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',175,'IMCH138')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',175,'IMCH139')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',175,'IMCH139')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',175,'IMCH140')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-175,'IMCH140')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-175,'IMCH141')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-175,'IMCH141')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-175,'IMCH142')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-175,'IMCH142')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',210,'IMCH143')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',210,'IMCH143')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',210,'IMCH144')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-210,'IMCH144')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-210,'IMCH145')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-210,'IMCH145')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',350,'IMCH146')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-350,'IMCH146')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',385,'IMCH147')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',385,'IMCH147')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-385,'IMCH148')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-385,'IMCH148')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',455,'IMCH149')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-455,'IMCH149')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH150')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH150')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH151')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH151')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH152')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH152')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH153')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH153')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH154')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH154')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH155')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH155')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH156')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH156')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH157')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH157')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH158')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH158')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH159')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH159')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH160')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH160')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH161')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH161')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',487.08,'IMCH162')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH162')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH163')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH163')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH164')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH164')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH165')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH165')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH166')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH166')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH167')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH167')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH168')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH168')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH169')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH169')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH170')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH170')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH171')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH171')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH172')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH172')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH173')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH173')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH174')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-487.08,'IMCH174')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-04-1010',1275.2,'IMCH175')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH SK PRIMACOR AME','0-00-2106',-1275.2,'IMCH175')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH TRIUMPHPAY     ','0-04-1010',3074.6,'IMCH176')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH TRIUMPHPAY     ','0-00-2106',-3074.6,'IMCH176')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH WINIX AMERI 335','0-04-1010',3864.36,'IMCH177')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS ACH WINIX AMERI 335','0-00-2106',-3864.36,'IMCH177')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS LCKBX 0225','0-04-1010',6999.28,'IMCH178')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('GIS LCKBX 0225','0-00-2106',-6999.28,'IMCH178')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH 443 CORNERSTONE','0-04-1010',14852.3,'IMCH179')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH 443 CORNERSTONE','0-00-2106',-14852.3,'IMCH179')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH A. DUIE PYLE  I','0-04-1010',2443.62,'IMCH180')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH A. DUIE PYLE  I','0-00-2106',-2443.62,'IMCH180')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH CARGO ALLIANCE ','0-04-1010',2753,'IMCH181')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH CARGO ALLIANCE ','0-00-2106',-2753,'IMCH181')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH HELLMANN       ','0-04-1010',840,'IMCH182')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH HELLMANN       ','0-00-2106',-840,'IMCH182')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH INTEPLAST GROUP','0-04-1010',6284.2,'IMCH183')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH INTEPLAST GROUP','0-00-2106',-6284.2,'IMCH183')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH Ocean Network E','0-04-1010',4280,'IMCH184')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH Ocean Network E','0-00-2106',-4280,'IMCH184')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH PORT X SO - 360','0-04-1010',1224.44,'IMCH185')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS ACH PORT X SO - 360','0-00-2106',-1224.44,'IMCH185')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS LCKBX 0225','0-04-1010',7121.11,'IMCH186')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('HMIS LCKBX 0225','0-00-2106',-7121.11,'IMCH186')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH EVERGREEN      ','0-04-1010',1198.3,'IMCH187')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH EVERGREEN      ','0-00-2106',-1198.3,'IMCH187')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Hapag-Lloyd (Am','0-04-1010',9729.35,'IMCH188')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Hapag-Lloyd (Am','0-00-2106',-9729.35,'IMCH188')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH HONDA DEV MFG  ','0-04-1010',7177.32,'IMCH189')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH HONDA DEV MFG  ','0-00-2106',-7177.32,'IMCH189')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Ocean Network E','0-04-1010',28751.14,'IMCH190')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH Ocean Network E','0-00-2106',-28751.14,'IMCH190')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH OIA PAYABLES   ','0-04-1010',28687.91,'IMCH191')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH OIA PAYABLES   ','0-00-2106',-28687.91,'IMCH191')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH WIRE TYPE:WIRE ','0-04-1010',5110,'IMCH192')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS ACH WIRE TYPE:WIRE ','0-00-2106',-5110,'IMCH192')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS LCKBX 0225','0-04-1010',21025.09,'IMCH193')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('OIS LCKBX 0225','0-00-2106',-21025.09,'IMCH193')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA To 3348','0-04-1010',-32008.48,'IMCH194')
INSERT INTO @tblDataSource (Description, GLAccount, Amount, Reference) VALUES ('ZBA To 3348','0-04-1011',32008.48,'IMCH194')

INSERT INTO @tblData
SELECT	DISTINCT REPLACE(REPLACE(RTRIM(Description), '  ', ''), ' - ', '-') + Reference AS Description,
		SUBSTRING(GLAccounts, 1, 9) AS AcctCredit,
		SUBSTRING(GLAccounts, 11, 9) AS AcctDebit,
		ABS(Amount) AS Amount
FROM	(
SELECT	T1.Description,
		T1.Amount,
		GLAccounts,
		T1.Reference
FROM	@tblDataSource T1
		CROSS APPLY (SELECT RTRIM(T2.GLAccount) + ',' 
              FROM @tblDataSource T2
			  WHERE T2.Reference = T1.Reference ORDER BY T2.Amount FOR XML PATH('')) EML (GLAccounts)
		) DATA

SELECT	*
INTO	#tmpData
FROM	(
SELECT	@TrxDate AS TRXDATE,
		Description AS REFRENCE,
		2 AS SERIES,
		AcctDebit AS ACTNUMST,
		0 AS CRDTAMNT,
		Amount AS DEBITAMT
FROM	@tblData
UNION
SELECT	@TrxDate AS TRXDATE,
		Description AS REFRENCE,
		2 AS SERIES,
		AcctCredit AS ACTNUMST,
		Amount AS CRDTAMNT,
		0 AS DEBITAMT
FROM	@tblData
		) DATA
ORDER BY REFRENCE

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		TRXDATE,
		REFRENCE,
		TRXDATE,
		2 AS SERIES,
		'CFLORES' AS UserId,
		ACTNUMST,
		CRDTAMNT,
		DEBITAMT,
		RTRIM(REFRENCE) AS TRXDESCRIP,
		0 as RowNumber --ROW_NUMBER() OVER(PARTITION BY Invoice ORDER BY Invoice) * 500 AS RowNumber
FROM	#tmpData
ORDER BY REFRENCE, ACTNUMST

IF @JustDisplay = 0
BEGIN
	IF (SELECT [Name] FROM sys.servers WHERE Server_Id = 0) = 'PRISQL01P'
	BEGIN
		DELETE	IntegrationsDB.Integrations.dbo.Integrations_GL
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Integration = @Integration

		DELETE	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Integration = @Integration
	END
	ELSE
	BEGIN
		DELETE	PRISQL004P.Integrations.dbo.Integrations_GL
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Integration = @Integration

		DELETE	PRISQL004P.Integrations.dbo.ReceivedIntegrations
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Integration = @Integration
	END

	OPEN curData 
	FETCH FROM curData INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
										  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @SqncLine

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @Refrence = RTRIM(LEFT(@Refrence, 30))

		IF (SELECT [Name] FROM sys.servers WHERE Server_Id = 0) = 'PRISQL01P'
			EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
												  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, Null, Null, Null, Null, Null, Null, Null, @SqncLine
		ELSE
			EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
												  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, Null, Null, Null, Null, Null, Null, Null, @SqncLine

		FETCH FROM curData INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
											  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @SqncLine
	END

	CLOSE curData
	DEALLOCATE curData

	IF @@ERROR = 0
	BEGIN
		IF (SELECT [Name] FROM sys.servers WHERE Server_Id = 0) = 'PRISQL01P'
		BEGIN
			EXECUTE IntegrationsDB.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId
			EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL_Select @Company, @BatchId, @Integration
		END
		ELSE
		BEGIN
			EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId
			EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_GL_Select @Company, @BatchId, @Integration
		END
	END
END
ELSE
	SELECT * FROM #tmpData ORDER BY REFRENCE, ACTNUMST

DROP TABLE #tmpData

GO