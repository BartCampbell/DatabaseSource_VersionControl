SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/25/2016
-- Description:	Refreshes the list of EntryXrefs, adding an new missing items.
-- =============================================
CREATE PROCEDURE [Log].[RefreshEntryXrefs]
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#ProgressInfo') IS NOT NULL
		DROP TABLE #ProgressInfo;

	WITH ProgressInfoBase AS
	(
		SELECT	LP.Descr,
				CASE 
					WHEN CHARINDEX(' completed.', LTRIM(LP.Descr)) > 0 OR 
						CHARINDEX(' failed.', LTRIM(LP.Descr)) > 0 OR 
						CHARINDEX(' successfully.', LTRIM(LP.Descr)) > 0 OR 
						CHARINDEX(' succcessfully.', LTRIM(LP.Descr)) > 0 OR 
						CHARINDEX(' succeeded.', LTRIM(LP.Descr)) > 0
					THEN 1 
					ELSE 0 
					END IsFinished,
				CASE 
					WHEN CHARINDEX(' started.', LTRIM(LP.Descr)) > 0
					THEN 1 
					ELSE 0 
					END AS IsStarted,
				LSO.ObjectName,
				LSO.ObjectSchema,
				CHARINDEX(' for BATCH ', LTRIM(LP.Descr)) AS PositionBatch1,
				CHARINDEX(' to BATCH ', LTRIM(LP.Descr)) AS PositionBatch2,
				CHARINDEX(' of BATCH ', LTRIM(LP.Descr)) AS PositionBatch3,
				CHARINDEX(' Initialing BATCH ', LTRIM(LP.Descr)) AS PositionBatch4,
				CHARINDEX(' BATCH ', LTRIM(LP.Descr)) AS PositionBatch5,
				CHARINDEX(' completed.', LTRIM(LP.Descr)) AS PositionComplete,
				CHARINDEX(' of RUN-', LTRIM(LP.Descr)) AS PositionDataRun,
				CHARINDEX(' SET-', LTRIM(LP.Descr)) AS PositionDataSet,
				CHARINDEX(' failed.', LTRIM(LP.Descr)) AS PositionFail,
				CHARINDEX(' for ITERATION ', LTRIM(LP.Descr)) AS PositionIteration1,
				CHARINDEX(' from ITERATION ', LTRIM(LP.Descr)) AS PositionIteration2,
				CHARINDEX(' of ITERATION ', LTRIM(LP.Descr)) AS PositionIteration3,
				CASE 
					WHEN LTRIM(LP.Descr) LIKE '- %' OR 
						LTRIM(LP.Descr) LIKE '[0-9]) %' OR
						LTRIM(LP.Descr) LIKE '[0-9][0-9]) %'
					THEN CHARINDEX(' ', LTRIM(LP.Descr)) + 1
					ELSE 1
					END AS PositionStart,
				CHARINDEX(' successfully.', LTRIM(LP.Descr)) AS PositionSuccess1,
				CHARINDEX(' succcessfully.', LTRIM(LP.Descr)) AS PositionSuccess2,
				CHARINDEX(' succeeded.', LTRIM(LP.Descr)) AS PositionSuccess3,
				LP.LogID,
				LP.SrcObjectGuid,
				LP.SrcObjectID
		FROM	[Log].ProcessEntries AS LP
				INNER JOIN [Log].SourceObjects AS LSO
						ON LP.SrcObjectGuid = LSO.SrcObjectGuid AND
							LP.SrcObjectID = LSO.SrcObjectID
	),
	ProgressInfo AS
	(
		SELECT	PIB.Descr,
				CASE 
					WHEN COALESCE(NULLIF(PIB.PositionBatch1, 0), 
									NULLIF(PIB.PositionBatch2, 0),
									NULLIF(PIB.PositionBatch3, 0),
									NULLIF(PIB.PositionBatch4, 0),
									NULLIF(PIB.PositionBatch5, 0),
									0) > 0
					THEN 1
					ELSE 0
					END AS IsBatch,
				PIB.IsFinished,
				CASE 
					WHEN COALESCE(NULLIF(PIB.PositionIteration1, 0), 
									NULLIF(PIB.PositionIteration2, 0),
									NULLIF(PIB.PositionIteration3, 0),
									0) > 0
					THEN 1
					ELSE 0
					END AS IsIteration,
				PIB.IsStarted,
				RTRIM(SUBSTRING(LTRIM(PIB.Descr), PIB.PositionStart, COALESCE(NULLIF(PIB.PositionIteration1, 0), 
																				NULLIF(PIB.PositionIteration2, 0), 
																				NULLIF(PIB.PositionIteration3, 0),
																				NULLIF(PIB.PositionBatch1, 0), 
																				NULLIF(PIB.PositionBatch2, 0),
																				NULLIF(PIB.PositionBatch3, 0),
																				NULLIF(PIB.PositionBatch4, 0),
																				NULLIF(PIB.PositionBatch5, 0),
																				NULLIF(PIB.PositionComplete, 0), 
																				NULLIF(PIB.PositionDataRun, 0), 
																				NULLIF(PIB.PositionDataSet, 0), 
																				NULLIF(PIB.PositionFail, 0), 
																				NULLIF(PIB.PositionSuccess1, 0), 
																				NULLIF(PIB.PositionSuccess2, 0), 
																				NULLIF(PIB.PositionSuccess3, 0),
																				LEN(LTRIM(PIB.Descr))) - PIB.PositionStart + 1)) AS ParseDescr,
				PIB.ObjectName,
				PIB.ObjectSchema,
				PIB.PositionStart,
				PIB.LogID,
				PIB.SrcObjectGuid,
				PIB.SrcObjectID
		FROM	ProgressInfoBase AS PIB
	)
	SELECT	PI.*,
			IDENTITY(int, 1, 1) AS RowID
	INTO	#ProgressInfo
	FROM	ProgressInfo AS PI
	ORDER BY PI.LogID

	IF OBJECT_ID('tempdb..#EntryIdentifiers') IS NOT NULL
		DROP TABLE #EntryIdentifiers;

	SELECT	ParseDescr AS Descr,
			NEWID() AS EntryXrefGuid,
			CONVERT(smallint, ROW_NUMBER() OVER (ORDER BY ObjectSchema, ObjectName, ParseDescr)) AS EntryXrefID,
			SrcObjectGuid,
			SrcObjectID
	INTO	#EntryIdentifiers
	FROM	#ProgressInfo
	GROUP BY ParseDescr,
			ObjectName,
			ObjectSchema,
			SrcObjectGuid,
			SrcObjectID
	ORDER BY ObjectName,
			ObjectSchema,
			ParseDescr;
		
	CREATE UNIQUE CLUSTERED INDEX IX_#EntryIdentifiers ON #EntryIdentifiers (EntryXrefID ASC);
		
	--SELECT * FROM #ProgressInfo;
	--SELECT * FROM #EntryIdentifiers;

	INSERT INTO Log.ProcessEntryXrefs
	        (Descr,
	         EntryXrefGuid,
	         SrcObjectGuid,
	         SrcObjectID
	        )
	SELECT	t.Descr,
            t.EntryXrefGuid,
            t.SrcObjectGuid,
            t.SrcObjectID
	FROM	#EntryIdentifiers AS t 
			LEFT OUTER JOIN Log.ProcessEntryXrefs AS LPEX
					ON LPEX.SrcObjectGuid = t.SrcObjectGuid AND
						LPEX.SrcObjectID = t.SrcObjectID --AND
						--LPEX.Descr = t.Descr
	WHERE	LPEX.EntryXrefID IS NULL
	ORDER BY t.EntryXrefID;

END
GO
GRANT EXECUTE ON  [Log].[RefreshEntryXrefs] TO [Processor]
GO
GRANT EXECUTE ON  [Log].[RefreshEntryXrefs] TO [Submitter]
GO
