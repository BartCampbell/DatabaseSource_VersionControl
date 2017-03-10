SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2016
-- Description:	Retrieves all record counts of the tables related to the file objects in the specified file format for the given batch.  
-- =============================================
CREATE PROCEDURE [Cloud].[GetBatchFileObjectRecordCounts]
(
	@BatchID int,
	@FileFormatID int,
	@FileObjectID int = NULL,
	@IsVerify bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;

	SELECT	@DataRunID = BB.DataRunID,
			@DataSetID = BB.DataSetID
	FROM	Batch.[Batches] AS BB
	WHERE	(BB.BatchID = @BatchID);

	DECLARE @SqlCmds TABLE (CountRecords bigint NULL, FileObjectID int NOT NULL, ID int NOT NULL IDENTITY(1, 1), SqlCmd nvarchar(max) NOT NULL, PRIMARY KEY CLUSTERED (FileObjectID));

	WITH Cloud_FileObjects AS
	(
		SELECT	*,
				CASE WHEN @IsVerify = 1 THEN InSourceName ELSE OutSourceName END AS SourceName,
				CASE WHEN @IsVerify = 1 THEN InSourceSchema ELSE OutSourceSchema END SourceSchema
		FROM	Cloud.FileObjects
	)
	INSERT INTO @SqlCmds
			(FileObjectID, SqlCmd)
	SELECT	CFO.FileObjectID,
			'SELECT @CountRecords = COUNT(*) FROM ' + QUOTENAME(CFO.SourceSchema) + '.' + QUOTENAME(CFO.SourceName) + ' AS t WHERE (1 = 1)' +
				
				--Must return 0 as the count for BatchFileObjects to match original counts, since original can't count itself...
				CASE WHEN @IsVerify = 1 AND CFO.SourceSchema = 'Cloud' AND CFO.SourceName = 'BatchFileObjects' THEN ' AND (1 = 2)' ELSE '' END +
				 
				CASE WHEN C.HasBatchID = 1 THEN ' AND (t.BatchID = @BatchID)' ELSE '' END + 
				CASE WHEN C.HasDataRunID = 1 THEN ' AND (t.DataRunID = @DataRunID)' ELSE '' END + 
				CASE WHEN C.HasDataSetID = 1 THEN ' AND (t.DataSetID = @DataSetID)' ELSE '' END + 

				--Never count medical record and hybrid result types, as those results are external to engine processing...
				CASE WHEN C.HasResultTypeID = 1 THEN ' AND (t.ResultTypeID NOT IN (2, 3))' ELSE '' END + 

				CASE WHEN C.HasBatchID = 0 AND C.HasDSMemberID = 1 THEN ' AND (t.DSMemberID IN (SELECT DSMemberID FROM [Cloud].[BatchMembers] WHERE (BatchID = @BatchID) UNION SELECT DSMemberID FROM [Internal].[Members] WHERE (BatchID = @BatchID)))' ELSE '' END +
				CASE WHEN C.HasBatchID = 0 AND C.HasDSMemberID = 0 AND C.HasDSProviderID = 1 THEN ' AND (t.DSProviderID IN (SELECT DSProviderID FROM [Cloud].[BatchProviders] WHERE (BatchID = @BatchID) UNION SELECT DSProviderID FROM [Internal].[Providers] WHERE (BatchID = @BatchID)))' ELSE '' END 
				AS SqlCmd
	FROM	Cloud.FileFormats AS CFF
			INNER JOIN Cloud_FileObjects AS CFO
					ON CFO.FileFormatID = CFF.FileFormatID
			OUTER APPLY	(
							SELECT	CONVERT(bit, MAX(CASE WHEN tC.COLUMN_NAME = 'BatchID' THEN 1 ELSE 0 END)) AS HasBatchID,
									CONVERT(bit, MAX(CASE WHEN tC.COLUMN_NAME = 'DataRunID' THEN 1 ELSE 0 END)) AS HasDataRunID,
									CONVERT(bit, MAX(CASE WHEN tC.COLUMN_NAME = 'DataSetID' THEN 1 ELSE 0 END)) AS HasDataSetID,
									CONVERT(bit, MAX(CASE WHEN tC.COLUMN_NAME = 'DSMemberID' THEN 1 ELSE 0 END)) AS HasDSMemberID,
									CONVERT(bit, MAX(CASE WHEN tC.COLUMN_NAME = 'DSProviderID' THEN 1 ELSE 0 END)) AS HasDSProviderID,
									CONVERT(bit, MAX(CASE WHEN tC.COLUMN_NAME = 'ResultTypeID' THEN 1 ELSE 0 END)) AS HasResultTypeID
							FROM	INFORMATION_SCHEMA.COLUMNS AS tC
							WHERE	tC.TABLE_NAME = CFO.SourceName AND
									tC.TABLE_SCHEMA = CFO.SourceSchema
						) C
	WHERE	(CFF.FileFormatID = @FileFormatID) AND
			(CFF.IsEnabled = 1) AND
			((@FileObjectID IS NULL) OR (CFO.FileObjectID = @FileObjectID)) AND
			(CFO.IsEnabled = 1) AND
			(CFO.InSourceName IS NOT NULL) AND
			(CFO.InSourceSchema IS NOT NULL)
	ORDER BY CFO.FileObjectID;

	DECLARE @ID int, @MaxID int, @MinID int;
	SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM @SqlCmds;

	DECLARE @CountRecords bigint;
	DECLARE @SqlCmd nvarchar(max);
	DECLARE @SqlParams nvarchar(max);

	SET @SqlParams = '@BatchID int, @CountRecords bigint OUTPUT, @DataRunID int, @DataSetID int';

	WHILE @ID BETWEEN @MinID AND @MaxID
		BEGIN;
			SET @CountRecords = NULL;

			SELECT	@SqlCmd = SqlCmd
			FROM	@SqlCmds
			WHERE	ID = @ID;

			EXEC sys.sp_executesql @SqlCmd, @SqlParams, @BatchID = @BatchID, @CountRecords = @CountRecords OUTPUT, @DataRunID = @DataRunID, @DataSetID = @DataSetID;

			UPDATE @SqlCmds SET CountRecords = @CountRecords WHERE ID = @ID;

			SET @ID = ISNULL(@ID, 0) + 1;
		END;
	
	SELECT @BatchID AS BatchID, CountRecords, FileObjectID FROM @SqlCmds;
END

GO
GRANT VIEW DEFINITION ON  [Cloud].[GetBatchFileObjectRecordCounts] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchFileObjectRecordCounts] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchFileObjectRecordCounts] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchFileObjectRecordCounts] TO [Submitter]
GO
