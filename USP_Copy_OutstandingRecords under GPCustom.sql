USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_Copy_OutstandingRecords]    Script Date: 1/11/2018 10:03:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_Copy_OutstandingRecords 'AIS', 'DSDR091015CK'
EXECUTE USP_Copy_OutstandingRecords 'AIS', '052208DSDRVCK'
*/
ALTER PROCEDURE [dbo].[USP_Copy_OutstandingRecords]
		@Company	Char(5),
		@BatchId	Char(15),
		@IsTemp		Bit = 0
AS
DECLARE	@Query	Varchar(500) = 'EXECUTE ' + RTRIM(@Company) + '.dbo.USP_Copy_OutstandingRecords ''' + RTRIM(@Company) + ''',''' + RTRIM(@BatchId) + ''',' + CASE WHEN @IsTemp = 1 THEN '1' ELSE '0' END

PRINT @Query
EXECUTE(@Query)