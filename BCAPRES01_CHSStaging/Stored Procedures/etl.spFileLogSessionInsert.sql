SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Description:	Create an entry into FileLogSession
Use:

DECLARE @FileLogSessionID INT
EXEC CHSStaging.etl.spFileLogSessionInsert 
	1001, @FileLogSessionID OUTPUT
SELECT @FileLogSessionID
SELECT * FROM etl.FileLogSession WHERE FileLogSessionID = @FileLogSessionID


Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2017-01-20	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spFileLogSessionInsert] (
	@FileProcessID INT
	,@FileLogSessionID INT OUTPUT
	)
AS
BEGIN
	-- Insert

	INSERT INTO etl.FileLogSession (
		FileProcessID
		)
	VALUES (
		@FileProcessID
		)

	SELECT @FileLogSessionID = MAX(FileLogSessionID) -- SELECT *
	FROM etl.FileLogSession
	WHERE 1=1
		AND FileProcessID = @FileProcessID

END

GO
