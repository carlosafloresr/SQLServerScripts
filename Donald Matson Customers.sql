SELECT RM2.CNTCPRSN, RM1.* FROM RM00101 RM1 LEFT JOIN RM00102 RM2 ON RM1.CUSTNMBR = RM2.CUSTNMBR WHERE CUSTNAME LIKE '%MATSON%'

SELECT * FROM RM00102 WHERE CUSTNMBR IN (SELECT CUSTNMBR FROM RM00101 WHERE CUSTNAME LIKE '%MATSON%')