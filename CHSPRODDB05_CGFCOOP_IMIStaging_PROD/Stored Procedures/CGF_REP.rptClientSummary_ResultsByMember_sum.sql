SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
DECLARE @Client VARCHAR(100) 
DECLARE @endseeddate DATETIME = '20131231'

SELECT 
		mbr.client,
		dr.EndSeedDate,
		cm.MeasureMetricDesc,
		IsNumerator = SUM(rbm.IsNumerator ),
		IsDenominator = SUM(rbm.IsDenominator)
	FROM cgf.ResultsByMember rbm
		INNER JOIN cgf.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
			AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM cgf.dataruns GROUP BY EndSeedDate)
		INNER JOIN cgf.Measures m
			ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
		INNER JOIN cgf.MeasureMEtrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
		INNER JOIN Member mbr
			ON rbm.IHDSMemberId = mbr.ihds_member_id		
	WHERE rbm.IsDenominator = 1 
AND mbr.Client = ISNULL(@Client,mbr.Client)
and dr.EndSeedDate = @endseeddate
group BY 		mbr.client,
		dr.EndSeedDate,
		cm.MeasureMetricDesc
order BY 		mbr.client,
		dr.EndSeedDate,
		cm.MeasureMetricDesc
*/


--EXEC [CGF_REP].[rptClientSummary_ResultsByMember_sum] 'DHMP','20131231'

CREATE PROC [CGF_REP].[rptClientSummary_ResultsByMember_sum]

@Client VARCHAR(100) = NULL,
@endseeddate DATETIME = '20131231',
@PopulationDesc VARCHAR(50) = NULL

AS

insert into cgf_rep.ReportVariableLog
	(RunDate ,
	ProcName ,
	Var1Name ,
	Var1Val ,
	Var2Name,
	Var2Val ,
	Var3Name ,
	Var3Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate,
	Var3Name = '@PopulationDesc',
	Var3Val = @PopulationDesc


SELECT 
		mbr.client,
		dr.EndSeedDate,
		PopulationDesc = ISNULL(rbm.PopulationDesc,'Not Defined'),
		cm.Measure,
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
		INNER JOIN Member mbr
			ON rbm.IHDSMemberId = mbr.ihds_member_id
	WHERE rbm.IsDenominator = 1 
		AND mbr.Client = ISNULL(@Client,mbr.Client)
		AND CONVERT(VARCHAR(8),dr.EndSeedDate,112) = CONVERT(VARCHAR(8),@endseeddate,112)
		AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
	GROUP BY 	mbr.client,
		dr.EndSeedDate,
		ISNULL(rbm.PopulationDesc,'Not Defined'),
		cm.Measure,
		cm.MeasureMetricDesc
	ORDER BY 	mbr.client,
		dr.EndSeedDate,
		ISNULL(rbm.PopulationDesc,'Not Defined'),
		cm.Measure,
		cm.MeasureMetricDesc
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptClientSummary_ResultsByMember_sum] TO [db_ViewProcedures]
GO
