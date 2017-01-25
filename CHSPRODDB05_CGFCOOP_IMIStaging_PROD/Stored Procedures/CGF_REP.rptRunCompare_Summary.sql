SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*************************************************************************************
Procedure:	rptRunCompare_Summary 
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

exec [CGF_REP].[rptRunCompare_Summary]
	@Client = NULL,
	@EndSeedDate = NULL,
	@DataRunID1 = 1,
	@DataRunID2 = 2 

ToDo:		


	select * from cgf.DataRuns


*************************************************************************************/

--/*
CREATE PROC [CGF_REP].[rptRunCompare_Summary]

	@Client VARCHAR(20) = NULL,
	@EndSeedDate DATETIME = NULL,
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


SELECT EndSeedDate = ISNULL(Run1.EndSeedDate, run2.EndSeedDate),
		MeasureMetricDesc = ISNULL(Run1.MeasureMetricDesc,run2.MeasureMetricDesc),
		Run1_EndSeedDate = Run1.EndSeedDate,
		Run1_DataRunID = @dataRunID1,
		Run1_Numerator = run1.IsNumerator,
		Run1_Denominator = run1.IsDenominator,
		Run1_rate= CASE WHEN run1.IsDenominator > 0 THEN run1.IsNumerator/(run1.IsDenominator*1.0) ELSE 0.00 END,
		Run2_EndSeedDate = Run2.EndSeedDate,
		Run2_DataRunID = @dataRunID2,
		Run2_Numerator = run2.IsNumerator,
		Run2_Denominator = run2.IsDenominator,
		Run2_rate= CASE WHEN run2.IsDenominator > 0 THEN run2.IsNumerator/(run2.IsDenominator*1.0) ELSE 0.00 END,
		Diff_Numerator = ISNULL(run1.IsNumerator,0) - ISNULL(run2.IsNumerator,0),
		Diff_Denominator = ISNULL(run1.IsDenominator,0) - ISNULL(run2.IsDenominator,0),
		Diff_Rate = CASE WHEN run1.IsDenominator > 0 THEN run1.IsNumerator/(run1.IsDenominator*1.0) ELSE 0.00 END 
						- CASE WHEN run2.IsDenominator > 0 THEN run2.IsNumerator/(run2.IsDenominator*1.0) ELSE 0.00 END
	FROM (
			SELECT 
				EndSeedDate= MAX(dr.EndSeedDate),
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
				AND CONVERT(VARCHAR(8),dr.EndSeedDate,112) = ISNULL(CONVERT(VARCHAR(8),@EndSeedDate,112),CONVERT(VARCHAR(8),dr.EndSeedDate,112))
				AND dr.DataRunID = @DataRunID1
			GROUP BY 
				cm.MeasureMetricDesc
			) Run1
		FULL OUTER JOIN (SELECT 
								EndSeedDate = MAX(dr.EndSeedDate),
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
								AND CONVERT(VARCHAR(8),dr.EndSeedDate,112) = ISNULL(CONVERT(VARCHAR(8),@EndSeedDate,112),CONVERT(VARCHAR(8),dr.EndSeedDate,112))
								AND dr.DataRunID = @DataRunID2
							GROUP BY 	
								cm.MeasureMetricDesc
				) Run2
		ON  Run2.MeasureMetricDesc = Run1.MeasureMetricDesc
	ORDER BY ISNULL(Run1.MeasureMetricDesc,run2.MeasureMetricDesc)


GO
