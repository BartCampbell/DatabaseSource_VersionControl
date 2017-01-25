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
		INNER JOIN dbo.Member mbr
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

	EXEC [CGF_REP].[rptMetricSummary_ResultsByClient]

*/

--/*
CREATE	PROC [CGF_REP].[rptMetricSummary_ResultsByClient_backup_05282016]

@endseeddate DATETIME = NULL

AS
--*/
/*
DECLARE	@endseeddate DATETIME = NULL--'20131231'
--*/

IF @endseeddate IS NULL
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember_sum 
		WHERE IsDenominator = 1

insert into cgf_rep.ReportVariableLog
	(RunDate ,
	ProcName ,
	Var1Name ,
	Var1Val 
	)
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@endseeddate',
	Var1Val = @endseeddate

SELECT mbr.client,
		dr.EndSeedDate,
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
		INNER JOIN dbo.Member mbr
			ON rbm.IHDSMemberId = mbr.ihds_member_id	
	WHERE rbm.IsDenominator = 1 
		AND CONVERT(VARCHAR(8),dr.EndSeedDate,112) = CONVERT(VARCHAR(8),@endseeddate,112)
	GROUP BY 	mbr.client,
		dr.EndSeedDate,
		cm.Measure,
		cm.MeasureMetricDesc
	ORDER BY 	mbr.client,
		dr.EndSeedDate,
		cm.Measure,
		cm.MeasureMetricDesc


GO
