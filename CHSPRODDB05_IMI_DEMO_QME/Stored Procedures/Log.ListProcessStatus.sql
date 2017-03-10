SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/18/2015
-- Description:	Retrieves the standardized view of processing status for the engine.
-- =============================================
CREATE PROCEDURE [Log].[ListProcessStatus]
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT TOP 1 1 FROM Log.ProcessErrors)
		BEGIN;
			SELECT 'ERROR!!!' AS ErrorMessage;
			SELECT * FROM Log.ProcessErrors;
		END;
	
	SELECT	dbo.GetTimeElapse(MIN(BeginTime), MAX(EndTime)) AS TimeElapseTotal, 
			dbo.GetTimeElapse(MAX(EndTime), GETDATE()) AS TimeElapseLastStepUntilNow,
			dbo.GetTimeElapse(MIN(BeginTime), GETDATE()) AS TimeElapseTotalUntilNow
	FROM	Log.ProcessEntries;

	SELECT	dbo.GetTimeElapse(BeginTime, EndTime) AS TimeElapse, LPE.Descr, CountRecords, BeginTime, EndTime,
			QUOTENAME(LSO.ObjectSchema) + '.' + QUOTENAME(LSO.ObjectName) AS TargetObject,
			LPEX.Descr AS TargetPurpose
	FROM	Log.ProcessEntries AS LPE
			INNER JOIN Log.ProcessEntryXrefs AS LPEX
					ON LPEX.EntryXrefGuid = LPE.EntryXrefGuid
			INNER JOIN Log.SourceObjects AS LSO
					ON LSO.SrcObjectGuid = LPEX.SrcObjectGuid
	ORDER BY LogID DESC;
END

GO
GRANT VIEW DEFINITION ON  [Log].[ListProcessStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Log].[ListProcessStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Log].[ListProcessStatus] TO [Processor]
GO
GRANT EXECUTE ON  [Log].[ListProcessStatus] TO [Submitter]
GO
