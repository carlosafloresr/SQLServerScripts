/*
ALTER DATABASE DYNAMICS  
SET CHANGE_TRACKING = ON  
(CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON)  
*/
SELECT * FROM sys.change_tracking_tables sctt

left join sys.tables st on sctt.object_id = st.object_id

ALTER TABLE dbo.SY01500
ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);