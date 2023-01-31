UPDATE	[Drivers].[dbo].[Users]
SET		Password = 'Defaulted2#'
WHERE	LEN(Password) = 9
		AND ISNUMERIC(LEFT(Password, 1)) = 1