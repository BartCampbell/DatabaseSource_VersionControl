SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Description:	Create an entry into FileLogDetail for more granular tracking
Use:

EXEC CHSStaging.etl.spFileLogDetailInsert 1000000,'RowCntFile Start'

SELECT * FROM CHSStaging.etl.FileLogDetail ORDER BY FileLogDetailDate DESC

-- TRUNCATE TABLE CHSStaging.etl.FileLogDetail

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2017-01-13	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spFileLogDetailInsert] (
	@FileLogID INT,
	@FileLogDetailTxt VARCHAR(MAX)
	)
AS
BEGIN

	INSERT INTO etl.FileLogDetail (
		FileLogID,
		FileLogDetailTxt
		)
	VALUES (
		@FileLogID,
		@FileLogDetailTxt
		)

END


GO
