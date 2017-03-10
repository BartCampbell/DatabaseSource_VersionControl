SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[FinalizeAbstractionReviewSet]
(
	@AbstractionReviewSetID int,
	@StartDate smalldatetime = NULL,
	@EndDate smalldatetime = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
    
	DECLARE @TranCount int = @@TRANCOUNT;

	BEGIN TRY;
	
		BEGIN TRAN TReviewSetFinalize;

		IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.AbstractionReviewSet AS t WHERE t.AbstractionReviewSetID = @AbstractionReviewSetID AND t.Finalized = 0)
			RAISERROR ('The specified review set is invalid.', 16, 1);

		DECLARE @HasDataEntry bit;
		DECLARE @IsCompliant bit;
		DECLARE @SelectAllComponents bit;
		DECLARE @SelectionCriteria xml;

		UPDATE	t 
		SET		@StartDate = StartDate = ISNULL(@StartDate, StartDate), 
				@EndDate = EndDate = ISNULL(@EndDate, EndDate),
				@HasDataEntry = HasDataEntry,
				@IsCompliant = IsCompliant,
				@SelectAllComponents = ISNULL(SelectAllComponents, 0),
				@SelectionCriteria = SelectionCriteria
		FROM	dbo.AbstractionReviewSet AS t 
		WHERE	t.AbstractionReviewSetID = @AbstractionReviewSetID AND 
				t.Finalized = 0;

		IF OBJECT_ID('tempdb..#Config') IS NOT NULL
			DROP TABLE #Config;

		SELECT	*
		INTO	#Config
		FROM	dbo.AbstractionReviewSetConfiguration AS ARSC
		WHERE	ARSC.AbstractionReviewSetID = @AbstractionReviewSetID AND
				ARSC.SelectionPercentage > 0

		CREATE UNIQUE CLUSTERED INDEX IX_#Config ON #Config (AbstractionReviewSetConfigID);

		DECLARE @ChartStatuses TABLE
		(
			ChartStatusValueID int NOT NULL,
			Description varchar(50) NOT NULL,
			PRIMARY KEY CLUSTERED (ChartStatusValueID)
		);

		IF @SelectionCriteria IS NOT NULL AND
			@SelectionCriteria.exist('criteria[1]/chartstatuses[1]') = 1 
			BEGIN;
				WITH ChartStatuses AS 
				(
					SELECT	chartstatus.value('@id', 'int') AS ChartStatusValueID,
							chartstatus.value('@name', 'varchar(50)') AS Description
					FROM	@SelectionCriteria.nodes('/criteria[1]/chartstatuses[1]/chartstatus') AS c(chartstatus)
				)
				INSERT INTO @ChartStatuses
						(ChartStatusValueID, Description)
				SELECT	CST.ChartStatusValueID, CST.Description							
				FROM	ChartStatuses AS CST
						LEFT OUTER JOIN dbo.ChartStatusValue AS CSV
								ON CSV.ChartStatusValueID = CST.ChartStatusValueID
				WHERE	CST.ChartStatusValueID = -1 OR CSV.ChartStatusValueID IS NOT NULL
				ORDER BY 1;
			END;
		ELSE
			BEGIN;
				INSERT INTO @ChartStatuses
						(ChartStatusValueID, Description)
				SELECT	CSV.ChartStatusValueID, CSV.Title
				FROM	dbo.ChartStatusValue AS CSV
				UNION
				SELECT	-1, 'None'
				ORDER BY 1;
			END;

		IF OBJECT_ID('tempdb..#CompletedPursuits') IS NOT NULL
			DROP TABLE #CompletedPursuits;

		SELECT DISTINCT
				R.AbstractorID,
				x.AbstractionReviewSetConfigID,
				x.AbstractionReviewSetID,
				MC.MeasureComponentID,
				MC.MeasureID,
				MBR.MemberID,
				MBR.Product,
				MBR.ProductLine,
				RV.PursuitEventID,
				R.PursuitID,
				ROW_NUMBER() OVER (PARTITION BY x.AbstractionReviewSetConfigID ORDER BY CHECKSUM(NEWID())) AS RandomSort
		INTO	#CompletedPursuits
		FROM	dbo.PursuitEvent AS RV
				INNER JOIN dbo.Pursuit AS R
						ON RV.PursuitID = R.PursuitID
				INNER JOIN @ChartStatuses AS CST
						ON CST.ChartStatusValueID = ISNULL(RV.ChartStatusValueID, -1)
				INNER JOIN dbo.Member AS MBR
						ON R.MemberID = MBR.MemberID
				INNER JOIN dbo.MeasureComponent AS MC
						ON RV.MeasureID = MC.MeasureID
				INNER JOIN dbo.AbstractionStatus AS AST
						ON RV.AbstractionStatusID = AST.AbstractionStatusID
				OUTER APPLY (
								--Make sure at least one entry was made
								SELECT TOP 1 
										1 AS N 
								FROM	dbo.MedicalRecordComposite AS t1 
								WHERE	(t1.PursuitEventID = RV.PursuitEventID) AND	
										(t1.MeasureComponentID = MC.MeasureComponentID)
							) AS MRC
				OUTER APPLY (
								SELECT	SUM(CASE WHEN (tMMMS.AdministrativeHitCount < tMMMS.MedicalRecordHitCount AND tMMMS.HybridHitCount > 0) OR (tMMMS.MedicalRecordHit = 1 AND tMMMS.HybridHit = 1) THEN 1 ELSE 0 END) AS CountCompliant,
										SUM(CASE WHEN (tMMMS.HybridHitCount = 0) OR (tmmms.Denominator = 1 AND tMMMS.HybridHit = 0) THEN 1 ELSE 0 END) AS CountNotCompliant,
										COUNT(*) AS CountRecords
								FROM	dbo.MemberMeasureSample AS tMMS
										INNER JOIN dbo.MemberMeasureMetricScoring AS tMMMS
												ON tMMMS.MemberMeasureSampleID = tMMS.MemberMeasureSampleID
										INNER JOIN dbo.MeasureComponentMetrics AS tMCMX
												ON tMCMX.HEDISSubMetricID = tMMMS.HEDISSubMetricID
								WHERE	tMMS.MemberID = R.MemberID AND
										tMMS.MeasureID = RV.MeasureID AND
										tMMS.EventDate = RV.EventDate AND
										tMCMX.MeasureComponentID = MC.MeasureComponentID
							) AS MMMS
				CROSS APPLY (
								--Get the latest status update date/time for the current abstraction status
								SELECT TOP 1 
										CONVERT(datetime, FLOOR(CONVERT(decimal(18, 6), t2.LogDate))) AS LogDate 
								FROM	dbo.PursuitEventStatusLog AS t2 
								WHERE	t2.PursuitEventID = RV.PursuitEventID AND 
										t2.AbstractionStatusID = RV.AbstractionStatusID  AND
										t2.AbstractionStatusChanged = 1
								ORDER BY LogDate DESC
							) AS RVSL
				INNER JOIN #Config AS x
						ON MC.MeasureComponentID = x.MeasureComponentID AND
							MBR.Product = x.Product AND
							MBR.ProductLine = x.ProductLine AND
							R.AbstractorID = x.AbstractorID
		WHERE	(AST.IsCompleted = 1) AND
				(AST.IsOmittedIRR = 0) AND
				((@HasDataEntry IS NULL) OR (@HasDataEntry = 1 AND MRC.N = 1) OR (@HasDataEntry = 0 AND MRC.N IS NULL)) AND
				((@IsCompliant IS NULL) OR (@IsCompliant = 1 AND ISNULL(MMMS.CountCompliant, 0) > 0) OR (@IsCompliant = 0 AND ISNULL(MMMS.CountNotCompliant, 0) > 0)) AND
				(RVSL.LogDate BETWEEN @StartDate AND @EndDate);

		IF OBJECT_ID('tempdb..#SelectionTotals') IS NOT NULL
			DROP TABLE #SelectionTotals;

		SELECT	x.AbstractionReviewSetConfigID, 
				COUNT(DISTINCT t.PursuitEventID) AS CountPursuitEvents,
				COUNT(DISTINCT t.PursuitID) AS CountPursuits,
				COUNT(*) AS CountRecords,
				MIN(x.SelectionPercentage) AS SelectionPercentage,
				CEILING(MIN(x.SelectionPercentage) * CONVERT(decimal(24,6), MAX(t.RandomSort))) AS SelectionTotal
		INTO	#SelectionTotals
		FROM	#CompletedPursuits AS t
				INNER JOIN #Config AS x
						ON t.AbstractionReviewSetConfigID = x.AbstractionReviewSetConfigID
		GROUP BY x.AbstractionReviewSetConfigID;

		CREATE UNIQUE CLUSTERED INDEX IX_#SelectionTotals ON #SelectionTotals (AbstractionReviewSetConfigID);

		DECLARE @ReviewDate datetime;
		SET @ReviewDate = GETDATE();

		INSERT INTO dbo.AbstractionReview
				(PursuitEventID,
				ReviewerID,
				ReviewDate,
				ReviewPointsAvailable,
				MeasureComponentID,
				AbstractionReviewStatusID,
				AbstractionReviewSetConfigID)
		SELECT	t.PursuitEventID,
				NULL,
				@ReviewDate,
				ARP.ReviewPointsAvailable,
				MC.MeasureComponentID,
				1,
				s.AbstractionReviewSetConfigID
		FROM	#SelectionTotals AS s
				INNER JOIN #CompletedPursuits AS t
						ON s.AbstractionReviewSetConfigID = t.AbstractionReviewSetConfigID AND
							s.SelectionTotal >= t.RandomSort
				LEFT OUTER JOIN dbo.MeasureComponent AS MC
						ON MC.MeasureID = t.MeasureID
				LEFT OUTER JOIN dbo.AbstractionReviewPoints AS ARP
						ON MC.MeasureComponentID = ARP.MeasureComponentID
		WHERE	(MC.EnabledOnReviews = 1) AND
				(MC.EnabledOnWebsite = 1) AND
				(
					(MC.MeasureComponentID = t.MeasureComponentID) OR
					(
						(MC.MeasureComponentID <> t.MeasureComponentID) AND
						(@SelectAllComponents = 1)
					)
				);

		UPDATE dbo.AbstractionReviewSet SET Finalized = 1 WHERE AbstractionReviewSetID = @AbstractionReviewSetID;
		
		UPDATE	ARSC
		SET		PursuitEventsAvailable = t.CountPursuitEvents,
				PursuitEventsSelected = t.SelectionTotal
		FROM	dbo.AbstractionReviewSetConfiguration AS ARSC
				INNER JOIN #SelectionTotals AS t
						ON t.AbstractionReviewSetConfigID = ARSC.AbstractionReviewSetConfigID;

		COMMIT TRAN TReviewSetFinalize;

		SELECT 1

	END TRY
	BEGIN CATCH
		WHILE @@TRANCOUNT > @TranCount
			ROLLBACK;

		PRINT ERROR_MESSAGE();
	END CATCH;
END
GO
