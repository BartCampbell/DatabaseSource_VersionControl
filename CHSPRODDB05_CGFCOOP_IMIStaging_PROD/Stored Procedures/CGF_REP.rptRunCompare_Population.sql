SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--EXEC sp_who2 'active'
---EXEC dbo.sp_WhoIsActive @get_transaction_info = 1, @get_plans = 1, @find_block_leaders = 1

/*

SELECT dr.datarunid,
		MeasureMetricDesc,
				IsNumerator = SUM(rbm.IsNumerator),
				IsDenominator = SUM(rbm.IsDenominator)
			FROM cgf.ResultsByMember rbm
				INNER JOIN cgf.DataRuns dr
					ON rbm.DataRunGuid = dr.DataRunGuid
group BY dr.datarunid, MeasureMetricDesc
ORDER BY MeasureMetricDesc, dr.DataRunID


SELECT 
		dr.EndSeedDate,
		cm.MeasureMetricDesc,
		IsNumerator = SUM(rbm.IsNumerator),
		IsDenominator = SUM(rbm.IsDenominator)
	FROM cgf.ResultsByMember rbm
		INNER JOIN cgf.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
			AND dr.DataRunID = 2
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


*/
/*************************************************************************************
Procedure:	rptRunCompare_Population
Author:		Leon Dowling
Copyright:	© 2013
Date:		2014.12.30
Purpose:	
Parameters:	
Depends On:	
Calls:		
Called By:	
Returns:	
Notes:		
Process:	
Test Script:	

exec [CGF_REP].[rptRunCompare_Population]
	@Client = NULL,
	@EndSeedDate = NULL,
	@MeasureMetricDesc = NULL,
	@DataRunID1 = 1,
	@DataRunID2 = 2 

exec [CGF_REP].[rptRunCompare_Population] @Client = NULL, @EndSeedDate = NULL, @DataRunID1 = 1, @DataRunID2 = 2, 
	@MeasureMetricDesc = ''
	
ToDo:		


	select * from cgf.DataRuns


*************************************************************************************/

--EXEC [CGF_REP].[rptClientSummary_ResultsByMember_sum] 'DHMP','20131231'

--/*
CREATE PROC [CGF_REP].[rptRunCompare_Population]

	@Client VARCHAR(20) = NULL,
	@EndSeedDate DATETIME = NULL,
	@MeasureMetricDesc VARCHAR(200) = NULL,
	@DataRunID1 INT ,
	@DataRunID2 INT 

AS

--*/
/*----------------------------------------------
DECLARE @Client VARCHAR(20),
	@EndSeedDate DATETIME ,
	@DataRunID1 INT = 1,
	@DataRunID2 INT = 2
--*/--------------------------------------------

insert into cgf_rep.ReportVariableLog
	(RunDate ,
	ProcName ,
	Var1Name ,
	Var1Val ,
	Var2Name,
	Var2Val ,
	Var3Name ,
	Var3Val ,
	Var4Name ,
	Var4Val 
	)
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@EndSeedDate',
	Var2Val = @EndSeedDate,
	Var3Name = '@DataRunID1',
	Var3Val = @DataRunID1,
	Var4Name = '@DataRunID2',
	Var4Val = @DataRunID2

SELECT Client = ISNULL(run1.Client,run2.Client),
		EndSeedDate = ISNULL(Run1.EndSeedDate, run2.EndSeedDate),
		PopulationDesc = ISNULL(Run1.PopulationDesc,run2.PopulationDesc),
		MeasureMetricDesc = ISNULL(Run1.MeasureMetricDesc,run2.MeasureMetricDesc),
		Run1_EndSeedDate = Run1.EndSeedDate,
		Run1_DataRunID = Run1.DataRunID,
		Run1_Numerator = run1.IsNumerator,
		Run1_Denominator = run1.IsDenominator,
		Run1_rate= CASE WHEN run1.IsDenominator > 0 THEN run1.IsNumerator/(run1.IsDenominator*1.0) ELSE 0.00 END,
		Run2_EndSeedDate = Run2.EndSeedDate,
		Run2_DataRunID = run2.DataRunID,
		Run2_Numerator = run2.IsNumerator,
		Run2_Denominator = run2.IsDenominator,
		Run2_rate= CASE WHEN run2.IsDenominator > 0 THEN run2.IsNumerator/(run2.IsDenominator*1.0) ELSE 0.00 END,
		Diff_Numerator = ISNULL(run1.IsNumerator,0) - ISNULL(run2.IsNumerator,0),
		Diff_Denominator = ISNULL(run1.IsDenominator,0) - ISNULL(run2.IsDenominator,0),
		Diff_Rate = CASE WHEN run1.IsDenominator > 0 THEN run1.IsNumerator/(run1.IsDenominator*1.0) ELSE 0.00 END 
						- CASE WHEN run2.IsDenominator > 0 THEN run2.IsNumerator/(run2.IsDenominator*1.0) ELSE 0.00 END
	FROM (
			SELECT 
				rbm.client,
				EndSeedDate = MAX(dr.EndSeedDate),
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
				AND CONVERT(VARCHAR(8),dr.EndSeedDate,112) = ISNULL(CONVERT(VARCHAR(8),@EndSeedDate,112),CONVERT(VARCHAR(8),dr.EndSeedDate,112))
				AND dr.DataRunID = @DataRunID1
				AND (cm.MeasureMetricDesc = @MeasureMetricDesc OR (@MeasureMetricDesc IS NULL AND cm.MeasureMetricDesc LIKE '%%'))
			GROUP BY 	rbm.client,
				ISNULL(rbm.PopulationDesc,'Not Defined'),
				cm.Measure,
				cm.MeasureMetricDesc
		) Run1
		FULL OUTER JOIN (
							SELECT 
								rbm.client,
								EndSeedDate = MAX(dr.EndSeedDate),
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
								AND CONVERT(VARCHAR(8),dr.EndSeedDate,112) = ISNULL(CONVERT(VARCHAR(8),@EndSeedDate,112),CONVERT(VARCHAR(8),dr.EndSeedDate,112))
								AND dr.DataRunID = @DataRunID2
								AND (cm.MeasureMetricDesc = @MeasureMetricDesc OR (@MeasureMetricDesc IS NULL AND cm.MeasureMetricDesc LIKE '%%'))
							GROUP BY 	rbm.client,
								ISNULL(rbm.PopulationDesc,'Not Defined'),
								cm.Measure,
								cm.MeasureMetricDesc
				) Run2
		ON Run2.Client = Run1.Client
		AND Run2.MeasureMetricDesc = Run1.MeasureMetricDesc
		AND Run2.PopulationDesc = Run1.PopulationDesc
	ORDER BY ISNULL(Run1.MeasureMetricDesc,run2.MeasureMetricDesc),
		ISNULL(run1.Client,run2.Client),
		ISNULL(Run1.PopulationDesc,run2.PopulationDesc)
		
GO
