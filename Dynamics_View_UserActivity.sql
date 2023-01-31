CREATE VIEW View_UserActivity
AS
SELECT	Activity.UserId,
		SY01400.UserName,
		Activity.CmpnyNam,
		CAST(CONVERT(Char(10), LoginDat, 101) + ' ' + CONVERT(Char(10), LoginTim, 108) AS Datetime) AS LoginDate
FROM	Activity
		INNER JOIN SY01400 ON Activity.UserId = SY01400.UserId