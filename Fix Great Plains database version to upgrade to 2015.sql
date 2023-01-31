Update DYNAMICS..DU000020 set versionBuild = 698 where PRODID in (2277, 2992, 3104)

Update DYNAMICS..DB_Upgrade set db_verBuild=698, db_verOldBuild = 698 where PRODID in (2277, 2992, 3104)

Select * from DYNAMICS..DU000020 where PRODID in (0, 2277, 2992, 3104)

Select * from DYNAMICS..DU000020 where PRODID in (0, 2277, 2992, 3104)

Update DYNAMICS..DB_Upgrade set db_verMajor=14, db_verOldMinor=14 where db_name = 'PTS' and PRODID in (2277, 2992, 3104)

Update DYNAMICS..DU000020 set versionMajor=14 where companyID = 37 and PRODID in (2277, 2992, 3104)

Delete DYNAMICS..DB_Upgrade where PRODID = 2150 and db_name in ('GSA', 'IGSC', 'OIS', 'PTS')

Delete DYNAMICS..DU000020 where PRODID = 2150 and companyID in (32, 33, 34, 37)

Delete DYNAMICS..DU000030 where PRODID = 2150 and companyID in (32, 33, 34, 37)


Drop Table RVLPD006