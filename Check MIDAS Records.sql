--update Repairs set Status = 0 where WorkOrder = 'HH003-00126'

SELECT * FROM Repairs where WorkOrder = 'HH003-00126'
SELECT * FROM RepairsDetails WHERE Fk_RepairId = 1829