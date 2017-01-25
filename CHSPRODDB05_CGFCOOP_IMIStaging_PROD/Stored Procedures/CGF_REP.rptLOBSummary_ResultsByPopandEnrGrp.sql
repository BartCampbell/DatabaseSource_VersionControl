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

--EXEC [CGF_REP].[rptClientSummary_ResultsByMember_sum] NULL,'20131231',1

--/*
CREATE PROC [CGF_REP].[rptLOBSummary_ResultsByPopandEnrGrp]

@Client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL,
@PopulationDesc VARCHAR(100) = NULL

AS
--*/
/*
DECLARE @Client VARCHAR(100) = NULL
DECLARE	@endseeddate DATETIME = '20131231'
*/

if @client is null 
	select @Client = max(Client) from cgf.ResultsByMember_sum

IF @endseeddate IS NULL
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember_sum 
		WHERE IsDenominator = 1
			AND client = @Client

insert into cgf_rep.ReportVariableLog
	(RunDate ,
	ProcName ,
	Var1Name ,
	Var1Val ,
	Var2Name,
	Var2Val,
	Var3Name,
	Var3Val)
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate,
	Var3Name = '@PopulationDesc',
	Var3Val = @PopulationDesc


SELECT mbr.client,
		dr.EndSeedDate,
		PopulationDesc = ISNULL(rbm.PopulationDesc,'Not Defined'),
		EnrollmentGroupDesc= ISNULL(rbm.EnrollmentGroupDesc,'Not Defined'),
		cm.Measure,
		cm.MeasureMetricDesc,
		IsNumerator = SUM(rbm.IsNumerator),
		IsDenominator = SUM(rbm.IsDenominator),
		ComplianceRate = SUM(rbm.IsNumerator)*1.0/SUM(rbm.IsDenominator)	
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
		AND rbm.PopulationDesc = ISNULL(@PopulationDesc,rbm.PopulationDesc)
	GROUP BY 	mbr.client,
		dr.EndSeedDate,
		ISNULL(rbm.PopulationDesc,'Not Defined'),
		ISNULL(rbm.EnrollmentGroupDesc,'Not Defined'),
		cm.Measure,
		cm.MeasureMetricDesc
	ORDER BY 	mbr.client,
		dr.EndSeedDate,
		ISNULL(rbm.PopulationDesc,'Not Defined'),
		ISNULL(rbm.EnrollmentGroupDesc,'Not Defined'),
		cm.Measure,
		cm.MeasureMetricDesc
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptLOBSummary_ResultsByPopandEnrGrp] TO [db_ViewProcedures]
GO
