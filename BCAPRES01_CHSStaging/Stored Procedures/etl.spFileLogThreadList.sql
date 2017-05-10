SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Return all FileLogID's assigned to a given Process/Thread
Use:

EXEC CHSStaging.etl.spFileLogThreadList 
	@FileLogSessionID = 1000000
	,@FileThread = 1

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2017-04-13	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spFileLogThreadList] (
	@FileLogSessionID INT
	,@FileThread INT
	)
AS
BEGIN

	SELECT fl.FileLogID
	FROM etl.FileLog fl
	WHERE 1=1
		AND fl.FileLogSessionID = @FileLogSessionID
		AND fl.FileThread = @FileThread
	ORDER BY fl.FileThreadPriority

END
GO
