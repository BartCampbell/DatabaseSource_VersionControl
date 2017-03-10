SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/29/2015
-- Description:	Copies the layout of one measure set's PLD files to another measure set.  
-- =============================================
CREATE PROCEDURE [Ncqa].[PLD_DuplicateFileLayout]
(
	@FromMeasureSetID int,
	@ToMeasureSetID int
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY;

		IF NOT EXISTS(SELECT TOP 1 1 FROM Measure.MeasureSets WHERE MeasureSetID = @FromMeasureSetID)
			RAISERROR('The "From" measure set does not exist.', 16, 1);

		IF NOT EXISTS(SELECT TOP 1 1 FROM Measure.MeasureSets WHERE MeasureSetID = @ToMeasureSetID)
			RAISERROR('The "To" measure set does not exist.', 16, 1);

		IF NOT EXISTS(SELECT TOP 1 1 FROM Ncqa.PLD_Files WHERE MeasureSetID = @FromMeasureSetID)
			RAISERROR('The "From" measure set does not have one or more existing file layouts to copy.', 16, 1);

		IF EXISTS(SELECT TOP 1 1 FROM Ncqa.PLD_FileLayouts AS NPFL INNER JOIN Ncqa.PLD_Files AS NPF ON NPF.PldFileID = NPFL.PldFileID WHERE NPF.MeasureSetID = @ToMeasureSetID)
			RAISERROR('The "To" measure set is already populated.', 16, 1);

		BEGIN TRANSACTION TCopyPLD_Layout;

		IF (SELECT COUNT(*) FROM Ncqa.PLD_Files AS NPF WHERE NPF.MeasureSetID = @FromMeasureSetID) >
			(SELECT COUNT(*) FROM Ncqa.PLD_Files AS NPF WHERE NPF.MeasureSetID = @ToMeasureSetID)
			BEGIN;

				DECLARE @MeasureYear varchar(4);
				SELECT @MeasureYear = CONVERT(varchar(4), YEAR(DefaultSeedDate) + 1) FROM Measure.MeasureSets WHERE MeasureSetID = @ToMeasureSetID;

				INSERT INTO Ncqa.PLD_Files
						(Descr,
						MeasureSetID,
						PldFileGuid,
						PldFileID,
						PldFileProcessID,
						PldFileTypeID)
				SELECT	REPLACE(NPF.Descr, CONVERT(varchar(4), YEAR(MMS.DefaultSeedDate) + 1), @MeasureYear) AS Descr,
						@ToMeasureSetID,
						NEWID() AS PldFileGuid,
						ROW_NUMBER() OVER (ORDER BY NPF.PldFileID) + 
							(SELECT MAX(x.PldFileID) FROM Ncqa.PLD_Files AS x WITH(SERIALIZABLE)) AS PldFileID,
						NPF.PldFileProcessID,
						NPF.PldFileTypeID
				FROM	Ncqa.PLD_Files AS NPF
						INNER JOIN Measure.MeasureSets AS MMS
								ON MMS.MeasureSetID = NPF.MeasureSetID
						LEFT OUTER JOIN Ncqa.PLD_Files AS t
								ON t.PldFileProcessID = NPF.PldFileProcessID AND
									t.PldFileTypeID = NPF.PldFileTypeID AND
									t.MeasureSetID = @ToMeasureSetID
				WHERE	(NPF.MeasureSetID = @FromMeasureSetID) AND
						(t.PldFileID IS NULL)
				ORDER BY NPF.PldFileID;

			END;

		DECLARE @FromCount int;
		DECLARE @ToCount int;

		SELECT @FromCount = COUNT(*) FROM Ncqa.PLD_FileLayouts AS NPFL INNER JOIN Ncqa.PLD_Files AS NPF ON NPF.PldFileID = NPFL.PldFileID WHERE NPF.MeasureSetID = @FromMeasureSetID;

		WITH Metrics AS 
		(
			SELECT	MX.* 
			FROM	Measure.Metrics AS MX 
					INNER JOIN Measure.Measures AS MM 
							ON MM.MeasureID = MX.MeasureID 
			WHERE	(MM.MeasureSetID = @ToMeasureSetID)
		)
		INSERT INTO Ncqa.PLD_FileLayouts
				(AggregateID,
				ColumnEnd,
				ColumnLength,
				ColumnPosition,
				ColumnStart,
				FieldDescr,
				FieldName,
				FromAge,
				Gender,
				MeasureID,
				MetricAbbrev,
				MetricID,
				PldColumnID,
				PldFileID,
				PldLayoutGuid,
				ToAge,
				ValidateID)
		SELECT	NPFL.AggregateID,
				NPFL.ColumnEnd,
				NPFL.ColumnLength,
				NPFL.ColumnPosition,
				NPFL.ColumnStart,
				NPFL.FieldDescr,
				NPFL.FieldName,
				NPFL.FromAge,
				NPFL.Gender,
				MX.MeasureID,
				NPFL.MetricAbbrev,
				MX.MetricID,
				NPFL.PldColumnID,
				NPF2.PldFileID,
				NEWID() AS PldLayoutGuid,
				NPFL.ToAge,
				NPFL.ValidateID
		FROM	Ncqa.PLD_FileLayouts AS NPFL
				INNER JOIN Ncqa.PLD_Files AS NPF
						ON NPF.PldFileID = NPFL.PldFileID
				INNER JOIN Ncqa.PLD_Files AS NPF2
						ON NPF2.PldFileProcessID = NPF.PldFileProcessID AND
							NPF2.PldFileTypeID = NPF.PldFileTypeID
				LEFT OUTER JOIN Metrics AS MX
						ON MX.Abbrev = NPFL.MetricAbbrev					
		WHERE	(NPF.MeasureSetID = @FromMeasureSetID) AND
				(NPF2.MeasureSetID = @ToMeasureSetID) AND
				(
					(NPFL.MetricAbbrev IS NULL) OR 
					(MX.MetricID IS NOT NULL)
				)
		ORDER BY NPF2.PldFileID, NPFL.PldLayoutID;

		SET @ToCount = @@ROWCOUNT;

		IF @FromCount = @ToCount
			COMMIT TRANSACTION TCopyPLD_Layout;
		ELSE
			RAISERROR('The "To" layout(s) did not copy successfully.  Record counts of the new layout(s) do(es) not match the original(s).', 16, 1);
	END TRY
	BEGIN CATCH;
		WHILE @@TRANCOUNT > 0 
			ROLLBACK;

		PRINT 'Unable to copy PLD layout.';
		PRINT ERROR_MESSAGE();
	END CATCH;
END

GO
GRANT VIEW DEFINITION ON  [Ncqa].[PLD_DuplicateFileLayout] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PLD_DuplicateFileLayout] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PLD_DuplicateFileLayout] TO [Processor]
GO
