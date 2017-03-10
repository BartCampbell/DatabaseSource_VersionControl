SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/17/2013
-- Description:	Sub process for updating ChartNet results (ChartNet.RefreshResults) to update SourceDenominator and SourceNumerator values.
-- =============================================
CREATE PROCEDURE [ChartNet].[UpdateResultSources]
(
	@FromDataRunID int,
	@ToDataRunID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	IF OBJECT_ID('tempdb..#MemberMeasures') IS NOT NULL
		DROP TABLE #MemberMeasures;
		
	SELECT DISTINCT
			RDSMK.CustomerMemberID, RMD.DataRunID, RMD.DSMemberID, 
			RDSMK.IhdsMemberID, RMD.MeasureID, RMD.MeasureXrefID
	INTO	#MemberMeasures
	FROM	Result.MeasureDetail AS RMD
			INNER JOIN Result.DataSetMemberKey AS RDSMK
					ON RMD.DataRunID = RDSMK.DataRunID AND
						RMD.DSMemberID = RDSMK.DSMemberID
	WHERE	(RMD.DataRunID = @ToDataRunID) AND
			(RMD.ResultTypeID IN (2, 3));

	CREATE UNIQUE INDEX IX_#MemberMeasures ON #MemberMeasures (DSMemberID, MeasureID, DataRunID);

	IF OBJECT_ID('tempdb..#Results') IS NOT NULL
		DROP TABLE #Results;

	SELECT	RMD.Age,
			RMD.AgeMonths,
			RMD.AgeBandID,
			RMD.AgeBandSegID,
			RMD.BatchID,
			RMD.BeginDate,
			RMD.ClinCondID,
			RDSMK.CustomerMemberID,
			RMD.DataRunID,
			RMD.DataSetID,
			RMD.Days,
			RMD.DSEntityID,
			RMD.DSMemberID,
			RMD.DSProviderID,
			RMD.EndDate,
			RMD.EnrollGroupID,
			RMD.EntityID,
			RMD.ExclusionTypeID,
			RMD.Gender,
			RDSMK.IhdsMemberID,
			RMD.IsDenominator,
			RMD.IsExclusion,
			RMD.IsIndicator,
			RMD.IsNumerator,
			RMD.IsNumeratorAdmin,
			RMD.IsNumeratorMedRcd,
			RMD.KeyDate,
			RMD.MeasureID,
			RMD.MeasureXrefID,
			RMD.MetricID,
			RMD.MetricXrefID,
			RMD.PayerID,
			RMD.PopulationID,
			RMD.ProductLineID,
			RMD.Qty,
			RMD.ResultRowGuid,
			RMD.ResultRowID,
			RMD.ResultTypeID,
			RMD.SourceDenominator,
			RMD.SourceExclusion,
			RMD.SourceIndicator,
			RMD.SourceNumerator,
			RMD.SysSampleRefID,
			RMD.Weight
	INTO	#Results
	FROM	Result.MeasureDetail AS RMD
			INNER JOIN #MemberMeasures AS MM
					ON RMD.DataRunID = MM.DataRunID AND
						RMD.DSMemberID = MM.DSMemberID AND
						RMD.MeasureID = MM.MeasureID
			INNER JOIN Result.DataSetMemberKey AS RDSMK
					ON RMD.DataRunID = RDSMK.DataRunID AND
						RMD.DSMemberID = RDSMK.DSMemberID
	WHERE	(RMD.DataRunID = @ToDataRunID);

	IF OBJECT_ID('tempdb..#AllEventMeasures') IS NOT NULL
		DROP TABLE #AllEventMeasures;

	SELECT DISTINCT
			/*MM.Abbrev, MM.MeasureID, */MM.MeasureXrefID
	INTO	#AllEventMeasures
	FROM	Measure.EntityToMetricMapping AS METMM
			INNER JOIN Measure.Metrics AS MX
					ON METMM.MetricID = MX.MetricID
			INNER JOIN Measure.Measures AS MM
					ON MX.MeasureID = MM.MeasureID
			INNER JOIN Measure.Entities AS ME
					ON METMM.EntityID = ME.EntityID AND
						MM.MeasureSetID = ME.MeasureSetID
			INNER JOIN Measure.EntityTypes AS MET
					ON ME.EntityTypeID = MET.EntityTypeID
			INNER JOIN Measure.MappingTypes AS MMT
					ON METMM.MapTypeID = MMT.MapTypeID
	WHERE	(MMT.MapTypeGuid = '1615D299-5BA1-4455-AE77-BE49646F54A4') AND
			(MET.EntityTypeGuid = 'A86A519D-C00A-441E-9934-C4DC5D623DAE') AND
			(MM.IsHybrid = 1);

	IF OBJECT_ID('tempdb..#SourceUpdate') IS NOT NULL
		DROP TABLE #SourceUpdate;

	SELECT	RF.ResultRowID,
			t.SourceDenominator, 
			t.SourceNumerator
	INTO	#SourceUpdate
	FROM	#Results AS RF
			OUTER APPLY	(
							SELECT TOP 1
									*
							FROM	#Results AS RT
							WHERE	RT.DataRunID = RF.DataRunID AND
									RT.IhdsMemberID = RF.IhdsMemberID AND
									(
										(
											(RT.KeyDate BETWEEN DATEADD(dd, -60, RF.KeyDate) AND DATEADD(dd, 60, RF.KeyDate)) AND
											(RT.MeasureXrefID IN (SELECT MeasureXrefID FROM #AllEventMeasures))
										) OR 
										(RT.MeasureXrefID NOT IN (SELECT MeasureXrefID FROM #AllEventMeasures))
									) AND
									RT.MeasureXrefID = RF.MeasureXrefID AND
									RT.MetricXrefID = RF.MetricXrefID AND
									RT.PopulationID = RF.PopulationID AND
									RT.ProductLineID = RF.ProductLineID AND
									RT.ResultTypeID IN (1)
							ORDER BY ABS(DATEDIFF(dd, RF.KeyDate, RT.KeyDate))
						) AS t
	WHERE	(t.ResultRowID IS NOT NULL) AND
			(RF.ResultTypeID IN (2, 3))

	--SELECT COUNT(*) FROM #Results WHERE ResultTypeID IN (2,3)
	--SELECT COUNT(*) FROM #SourceUpdate;

	IF EXISTS (SELECT * FROM #SourceUpdate WHERE ResultRowID IN (SELECT ResultRowID FROM #SourceUpdate GROUP BY ResultRowID HAVING (COUNT(*) > 1)))
		RAISERROR ('Duplicate rows were identified for SourceDenominator/SourceNumerator updates.', 16, 1);
	ELSE
		UPDATE	RMD
		SET		SourceDenominator = ISNULL(RMD.SourceDenominator, t.SourceDenominator),
				SourceNumerator = ISNULL(RMD.SourceNumerator, t.SourceNumerator)
		FROM	Result.MeasureDetail AS RMD
				INNER JOIN #SourceUpdate AS t
						ON RMD.ResultRowID = t.ResultRowID AND
							RMD.DataRunID = @ToDataRunID
		WHERE	(t.SourceDenominator IS NOT NULL OR t.SourceNumerator IS NOT NULL) AND
				(RMD.SourceDenominator IS NULL OR RMD.SourceNumerator IS NULL);
END


GO
GRANT VIEW DEFINITION ON  [ChartNet].[UpdateResultSources] TO [db_executer]
GO
GRANT EXECUTE ON  [ChartNet].[UpdateResultSources] TO [db_executer]
GO
GRANT EXECUTE ON  [ChartNet].[UpdateResultSources] TO [Processor]
GO
