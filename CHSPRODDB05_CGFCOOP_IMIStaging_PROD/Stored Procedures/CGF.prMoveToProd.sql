SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	cgf.prMoveToProd
Author:		Leon Dowling
Copyright:	© 2014
Date:		2014.01.01
Purpose:	
Parameters: 
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		
Update Log:
8/22/2014 - Init w/ indexes and stats

Process:	
Test Script: 
ToDo:		

*/
--/*
CREATE PROC [CGF].[prMoveToProd] 

@vcTargDB VARCHAR(100)

AS
--*/
--DECLARE @vcTargDB VARCHAR(100) = 'DHMP_IMIStaging_PROD'

-- Tables to move

DECLARE @tTabLIst TABLE (RowID INT IDENTITY(1,1), 
							SchemaName VARCHAR(100),
							TabName VARCHAR(100))

INSERT INTO @tTabLIst
SELECT DISTINCT
	TABLE_SCHEMA, TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_SCHEMA = 'CGF'
		AND 1 = CASE WHEN LEFT(table_name,15) = 'ResultsByMember' AND LEN(table_name) > 15 THEN 0 ELSE 1 END

DECLARE @i INT,
	@vcCmd VARCHAR(4000)

SELECT @i = MIN(Rowid) FROM @tTabLIst

WHILE @i IS NOT NULL 
BEGIN



	SELECT @vcCmd = @vcTargDB + '.' + SchemaName + '.' + TabName
		FROM @tTabLIst
		WHERE RowID = @i

	IF OBJECT_ID(@vcCmd) IS NOT NULL 
	BEGIN
		SELECT @vcCmd = 'DROP TABLE ' + @vcCmd
			FROM @tTabLIst
			WHERE RowID = @i

		PRINT @vcCmd
		EXEC (@vcCMD)
	END

	SELECT @vcCmd = 'SELECT * INTO ' + @vcTargDB + '.' + SchemaName + '.' + TabName
					+ ' FROM ' + SchemaName + '.' + TabName
		FROM @tTabLIst a
		WHERE RowID = @i

	PRINT @vcCmd
	EXEC (@vcCMD)

	SELECT @i = MIN(Rowid) 
		FROM @tTabLIst
		WHERE Rowid > @i


END

DECLARE @tIndex TABLE (RowID INT IDENTITY(1,1),
						IndexName VARCHAR(100),
						SchemaName VARCHAR(100),
						TableName VARCHAR(100),
						IndexFields VARCHAR(1000),
						IncludeFields VARCHAR(1000))

INSERT INTO @tIndex SELECT 'IX_AgeBands','CGF','AgeBands','AgeBandGuid',NULL
INSERT INTO @tIndex SELECT 'IX_AgeBandSegments','CGF','AgeBandSegments','AgeBandSegGuid',NULL
INSERT INTO @tIndex SELECT 'IX_DataRuns','CGF','DataRuns','DataRunGuid',NULL
INSERT INTO @tIndex SELECT 'IX_DataSets','CGF','DataSets','DataSetGuid',NULL
INSERT INTO @tIndex SELECT 'IX_Measures','CGF','Measures','MeasureXrefGuid',NULL
INSERT INTO @tIndex SELECT 'IX_ExclusionTypes','CGF','ExclusionTypes','ExclusionTypeGuid',NULL
INSERT INTO @tIndex SELECT 'IX_Metrics','CGF','Metrics','MetricXrefGuid',NULL
INSERT INTO @tIndex SELECT 'IX_Payers','CGF','Payers','PayerGuid',NULL
INSERT INTO @tIndex SELECT 'IX_ProductLines','CGF','ProductLines','ProductLineGuid',NULL
INSERT INTO @tIndex SELECT 'IX_ResultTypes','CGF','ResultTypes','ResultTypeGuid',NULL
INSERT INTO @tIndex SELECT 'IX_Measures_Measure','CGF','Measures','Measure',NULL
INSERT INTO @tIndex SELECT 'IX_ExclusionTypes_ExclusionType','CGF','ExclusionTypes','ExclusionType',NULL
INSERT INTO @tIndex SELECT 'IX_Metrics_Metric','CGF','Metrics','Metric',NULL
INSERT INTO @tIndex SELECT 'IX_Payers_Payer','CGF','Payers','Payer',NULL
INSERT INTO @tIndex SELECT 'IX_ProductLines_ProductLine','CGF','ProductLines','ProductLine',NULL
INSERT INTO @tIndex SELECT 'idx_ResultByMember','CGF','ResultsByMember','IsDenominator,Client,EndSeedDate,PopulationDesc','DataRunGuid, IHDSMemberID, IsNumerator, MeasureXrefGuid, MetricXrefGuid'

SELECT @i = MIN(Rowid) FROM @tIndex

WHILE @i IS NOT NULL 
BEGIN

	SELECT @vcCmd = 'CREATE INDEX ' + IndexName + ' ON ' + @vcTargDB + '.' + SchemaName + '.' + TableName + ' (' + IndexFields + ')'
						 + CASE WHEN IncludeFields IS NOT NULL THEN ' INCLUDE (' + IncludeFields + ')' ELSE '' END
		FROM @tIndex
		WHERE RowID = @i

	PRINT @vcCmd
	EXEC (@vcCMD)
	
	SELECT @vcCmd = 'CREATE STATISTICS sp' + IndexName + ' ON ' + @vcTargDB + '.' + SchemaName + '.' + TableName + ' (' + IndexFields + ')'
		FROM @tIndex
		WHERE RowID = @i

	PRINT @vcCmd
	EXEC (@vcCMD)


	SELECT @i = MIN(Rowid) 
		FROM @tIndex
		WHERE Rowid > @i

END
GO
