SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[prRescoreAllMeasures]
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ScoringProcedures TABLE
    (
		ID int IDENTITY(1, 1) NOT NULL,
		HEDISMeasure varchar(50) NOT NULL,
		MeasureID int NOT NULL,
		ScoringProcedure nvarchar(128) NOT NULL
	);

	INSERT INTO @ScoringProcedures
	        (HEDISMeasure, MeasureID, ScoringProcedure)
	SELECT	HEDISMeasure, MeasureID, ScoringProcedure
	FROM	dbo.Measure
	WHERE	ScoringProcedure IS NOT NULL
	ORDER BY HEDISMeasure;

	DECLARE @ID int, @MaxID int, @MinID int;
	SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM @ScoringProcedures;

	DECLARE @HEDISMeasure varchar(50);
	DECLARE @MeasureID int;
	DECLARE @ScoringProcedure nvarchar(128);

	WHILE @ID BETWEEN @MinID AND @MaxID
		BEGIN;
			SELECT @HEDISMeasure = HEDISMeasure, @MeasureID = MeasureID, @ScoringProcedure = ScoringProcedure FROM @ScoringProcedures WHERE ID = @ID;

			IF EXISTS (SELECT TOP 1 1 FROM dbo.MemberMeasureSample WHERE MeasureID = @MeasureID)
				BEGIN;
					PRINT '*** Executing ' + @HEDISMeasure + ' ***********************************************************';
					EXEC dbo.prRescoreMeasure @cScoringProc = @ScoringProcedure;
				END;

			SET @ID = @ID + 1;
		END;

	EXEC dbo.CalculateReportedScoring
END
GO
