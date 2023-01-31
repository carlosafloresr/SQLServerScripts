-- SELECT RTRIM(InterId) + ' Test', CmpnyNam FROM Dynamics..SY01500

UPDATE Dynamics..SY01500 SET CmpnyNam  = RTRIM(InterId) + ' Test'