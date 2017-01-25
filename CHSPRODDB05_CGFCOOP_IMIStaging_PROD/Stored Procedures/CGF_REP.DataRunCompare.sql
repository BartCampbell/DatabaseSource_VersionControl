SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--EXEC sp_who2 'active'
---EXEC dbo.sp_WhoIsActive @get_transaction_info = 1, @get_plans = 1, @find_block_leaders = 1
CREATE PROC [CGF_REP].[DataRunCompare]

@Client VARCHAR(20) = NULL ,
@DataRunID1 INT = 1,
@DataRunID2 INT = 2

AS

/*
DECLARE @Client VARCHAR(20),
	@DataRunID1 INT = 1,
	@DataRunID2 INT = 2
*/

SELECT 
		dr.EndSeedDate,
		cm.MeasureMetricDesc,
		IsNumerator = SUM(rbm.IsNumerator),
		IsDenominator = SUM(rbm.IsDenominator)
	FROM cgf.ResultsByMember rbm
		INNER JOIN cgf.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
			AND dr.DataRunID = @DataRunID2
		INNER JOIN cgf.Measures m
			ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
		INNER JOIN cgf.MeasureMEtrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
	WHERE rbm.IsDenominator = 1 
		AND dr.DataRunID = @DataRunID1
	GROUP BY 	
		dr.EndSeedDate,
		cm.MeasureMetricDesc
	ORDER BY
		dr.EndSeedDate,
		cm.MeasureMetricDesc

SELECT Client = ISNULL(run1.Client,run2.Client),
		PopulationDesc = ISNULL(Run1.PopulationDesc,run2.PopulationDesc),
		MeasureMetricDesc = ISNULL(Run1.MeasureMetricDesc,run2.MeasureMetricDesc),
		Run1_EndSeedDate = run1.EndSeedDate,
		Run1_DataRunID = Run1.DataRunID,
		Run1_Numerator = run1.IsNumerator,
		Run1_Denominator = run1.IsDenominator,
		Run1_rate= CASE WHEN run1.IsDenominator > 0 THEN run1.IsNumerator/(run1.IsDenominator*1.0) ELSE 0.00 END,
		Run2_EndSeedDate = run2.EndSeedDate,
		Run2_DataRunID = run2.DataRunID,
		Run2_Numerator = run2.IsNumerator,
		Run2_Denominator = run2.IsDenominator,
		Run2_rate= CASE WHEN run2.IsDenominator > 0 THEN run2.IsNumerator/(run2.IsDenominator*1.0) ELSE 0.00 END,
		Diff_Numerator = ISNULL(run1.IsNumerator,0) - ISNULL(run2.IsNumerator,0),
		Diff_Denominator = ISNULL(run1.IsDenominator,0) - ISNULL(run2.IsDenominator,0),
		Diff_Rate = CASE WHEN run1.IsDenominator > 0 THEN run1.IsNumerator/(run1.IsDenominator*1.0) ELSE 0.00 END 
						- CASE WHEN run2.IsDenominator > 0 THEN run2.IsNumerator/(run2.IsDenominator*1.0) ELSE 0.00 END
	FROM (SELECT 
				rbm.client,
				dr.EndSeedDate,
				PopulationDesc = ISNULL(rbm.PopulationDesc,'Not Defined'),
				cm.Measure,
				cm.MeasureMetricDesc,
				IsNumerator = SUM(rbm.IsNumerator),
				IsDenominator = SUM(rbm.IsDenominator),
				DataRunID = MAX(dr.DataRunID)
			FROM cgf.ResultsByMember rbm
				INNER JOIN cgf.DataRuns dr
					ON rbm.DataRunGuid = dr.DataRunGuid
				INNER JOIN cgf.Measures m
					ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
				INNER JOIN cgf.MeasureMEtrics cm
					ON rbm.MetricXrefGuid = cm.MetricXrefGuid
			WHERE rbm.IsDenominator = 1 
				AND rbm.Client = ISNULL(@Client,rbm.Client)
				AND dr.DataRunID = @DataRunID1
			GROUP BY 	rbm.client,
				dr.EndSeedDate,
				ISNULL(rbm.PopulationDesc,'Not Defined'),
				cm.Measure,
				cm.MeasureMetricDesc
			) Run1
		FULL OUTER JOIN (SELECT 
								rbm.client,
								dr.EndSeedDate,
								PopulationDesc = ISNULL(rbm.PopulationDesc,'Not Defined'),
								cm.Measure,
								cm.MeasureMetricDesc,
								IsNumerator = SUM(rbm.IsNumerator),
								IsDenominator = SUM(rbm.IsDenominator),
								DataRunID = MAX(dr.DataRunID)
							FROM cgf.ResultsByMember rbm
								INNER JOIN cgf.DataRuns dr
									ON rbm.DataRunGuid = dr.DataRunGuid
								INNER JOIN cgf.Measures m
									ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
								INNER JOIN cgf.MeasureMEtrics cm
									ON rbm.MetricXrefGuid = cm.MetricXrefGuid
							WHERE rbm.IsDenominator = 1 
								AND rbm.Client = ISNULL(@Client,rbm.Client)
								AND dr.DataRunID = @DataRunID2
							GROUP BY 	rbm.client,
								dr.EndSeedDate,
								ISNULL(rbm.PopulationDesc,'Not Defined'),
								cm.Measure,
								cm.MeasureMetricDesc
				) Run2
		ON Run2.Client = Run1.Client
		AND Run2.MeasureMetricDesc = Run1.MeasureMetricDesc
		AND Run2.PopulationDesc = Run1.PopulationDesc
	ORDER BY ISNULL(Run1.MeasureMetricDesc,run2.MeasureMetricDesc),
		ISNULL(run1.Client,run2.Client),
		ISNULL(Run1.EndSeedDate, run2.EndSeedDate),
		ISNULL(Run1.PopulationDesc,run2.PopulationDesc)
		

/*
SELECT EndSeedDate = ISNULL(Run1.EndSeedDate, run2.EndSeedDate),
		MeasureMetricDesc = ISNULL(Run1.MeasureMetricDesc,run2.MeasureMetricDesc),
		Run1_DataRunID = @dataRunID1,
		Run1_Numerator = run1.IsNumerator,
		Run1_Denominator = run1.IsDenominator,
		Run1_rate= CASE WHEN run1.IsDenominator > 0 THEN run1.IsNumerator/(run1.IsDenominator*1.0) ELSE 0.00 END,
		Run2_DataRunID = @dataRunID2,
		Run2_Numerator = run2.IsNumerator,
		Run2_Denominator = run2.IsDenominator,
		Run2_rate= CASE WHEN run2.IsDenominator > 0 THEN run2.IsNumerator/(run2.IsDenominator*1.0) ELSE 0.00 END,
		Diff_Numerator = ISNULL(run1.IsNumerator,0) - ISNULL(run2.IsNumerator,0),
		Diff_Denominator = ISNULL(run1.IsDenominator,0) - ISNULL(run2.IsDenominator,0),
		Diff_Rate = CASE WHEN run1.IsDenominator > 0 THEN run1.IsNumerator/(run1.IsDenominator*1.0) ELSE 0.00 END 
						- CASE WHEN run2.IsDenominator > 0 THEN run2.IsNumerator/(run2.IsDenominator*1.0) ELSE 0.00 END
	FROM (SELECT 
				dr.EndSeedDate,
				cm.MeasureMetricDesc,
				IsNumerator = SUM(rbm.IsNumerator),
				IsDenominator = SUM(rbm.IsDenominator)
			FROM cgf.ResultsByMember rbm
				INNER JOIN cgf.DataRuns dr
					ON rbm.DataRunGuid = dr.DataRunGuid
				INNER JOIN cgf.Measures m
					ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
				INNER JOIN cgf.MeasureMEtrics cm
					ON rbm.MetricXrefGuid = cm.MetricXrefGuid
			WHERE rbm.IsDenominator = 1 
				AND dr.DataRunID = @DataRunID1
			GROUP BY 	
				dr.EndSeedDate,
				cm.MeasureMetricDesc
			) Run1
		FULL OUTER JOIN (SELECT 
								dr.EndSeedDate,
								cm.MeasureMetricDesc,
								IsNumerator = SUM(rbm.IsNumerator),
								IsDenominator = SUM(rbm.IsDenominator)
							FROM cgf.ResultsByMember rbm
								INNER JOIN cgf.DataRuns dr
									ON rbm.DataRunGuid = dr.DataRunGuid
								INNER JOIN cgf.Measures m
									ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
								INNER JOIN cgf.MeasureMEtrics cm
									ON rbm.MetricXrefGuid = cm.MetricXrefGuid
							WHERE rbm.IsDenominator = 1 
								AND dr.DataRunID = @DataRunID2
							GROUP BY 	
								dr.EndSeedDate,
								cm.MeasureMetricDesc
				) Run2
		ON  Run2.EndSeedDate = Run1.EndSeedDate
		AND Run2.MeasureMetricDesc = Run1.MeasureMetricDesc
	ORDER BY ISNULL(Run1.MeasureMetricDesc,run2.MeasureMetricDesc),
		ISNULL(Run1.EndSeedDate, run2.EndSeedDate)


SELECT dr.datarunid,
		MeasureMetricDesc,
				IsNumerator = SUM(rbm.IsNumerator),
				IsDenominator = SUM(rbm.IsDenominator)
			FROM cgf.ResultsByMember rbm
				INNER JOIN cgf.DataRuns dr
					ON rbm.DataRunGuid = dr.DataRunGuid
group BY dr.datarunid, MeasureMetricDesc
ORDER BY MeasureMetricDesc, dr.DataRunID

*/

GO
