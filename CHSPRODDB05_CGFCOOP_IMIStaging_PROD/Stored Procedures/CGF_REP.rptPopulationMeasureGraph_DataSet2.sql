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

--EXEC [CGF_REP].[rptPopulationMeasureGraph_DataSet2]

--/*
CREATE PROC [CGF_REP].[rptPopulationMeasureGraph_DataSet2]

@Client VARCHAR(100) = NULL,
@measuremetricdesc VARCHAR(200) = NULL

AS
--*/
/*
DECLARE @Client VARCHAR(100) = NULL
DECLARE @measuremetricdesc VARCHAR(200) 
--*/

if @client is null 
	select @Client = max(Client) from cgf.ResultsByMember_sum

IF @measuremetricdesc IS NULL
	SELECT @measuremetricdesc =  'CCS-Cervical Cancer Screening'

insert into cgf_rep.ReportVariableLog
	(RunDate ,
	ProcName ,
	Var1Name ,
	Var1Val ,
	Var2Name,
	Var2Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@measuremetricdesc',
	Var2Val = @measuremetricdesc

SELECT rbm.client,
		rbm.EndSeedDate,
		PopulationDesc = ISNULL(rbm.PopulationDesc,'Not Defined'),
		rbm.MeasureMetricDesc,
		ComplianceRate = SUM(rbm.IsNumerator)*1.0/SUM(rbm.IsDenominator)	
	FROM cgf.ResultsByMember rbm
	WHERE rbm.IsDenominator = 1 
		AND rbm.Client = ISNULL(@Client,rbm.Client)
		AND rbm.MeasureMetricDesc = @measuremetricdesc
	GROUP BY rbm.client,
		rbm.EndSeedDate,
		ISNULL(rbm.PopulationDesc,'Not Defined'),
		rbm.MeasureMetricDesc
	ORDER BY rbm.client,
		rbm.EndSeedDate,
		ISNULL(rbm.PopulationDesc,'Not Defined'),
		rbm.MeasureMetricDesc


GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptPopulationMeasureGraph_DataSet2] TO [db_ViewProcedures]
GO
