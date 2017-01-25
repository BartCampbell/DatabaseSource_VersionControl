SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
DECLARE @Client VARCHAR(100) 
DECLARE @ReportEndDate DATETIME = '20131231'

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
and dr.EndSeedDate = @ReportEndDate
group BY 		mbr.client,
		dr.EndSeedDate,
		cm.MeasureMetricDesc
order BY 		mbr.client,
		dr.EndSeedDate,
		cm.MeasureMetricDesc

	EXEC [CGF_REP].[rptMetricSummary_ResultsByClient] @Client = null

	EXEC [CGF_REP].[rptMetricSummary_ResultsByClient] @Client = 'Aetna'


	select top 10 * from CGF_REP.ReportVariableLog order by rowid desc 

*/

--/*
CREATE PROC [CGF_REP].[rptMetricSummary_ResultsByClient_BACKUP_05272016]

	@ReportEndDate		datetime = NULL
	,@Client			varchar(30)

AS
--*/
/*
DECLARE	@ReportEndDate DATETIME = NULL--'20131231'
--*/

DECLARE @ClientTable TABLE (Client varchar(50)) 

IF @client IS NULL 
	INSERT INTO @ClientTable (Client) SELECT DISTINCT Client FROM cgf.ResultsByMember_sum
	--INSERT INTO @ClientTable (Client) SELECT 'Aetna'
ELSE 
	INSERT INTO @ClientTable (Client) SELECT @client 
	
IF @ReportEndDate IS NULL
	SELECT @ReportEndDate = MAX(endseeddate) 
		FROM CGF.ResultsByMember_sum 
		WHERE IsDenominator = 1

INSERT INTO CGF_REP.ReportVariableLog
	(RunDate 
	,ProcName 
	,Var1Name 
	,Var1Val 
	,Var2Name 
	,Var2Val 
	)
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID)
	,Var1Name = '@Client'
	,Var1Val = @Client
	,Var1Name = '@ReportEndDate'
	,Var1Val = @ReportEndDate



IF (@Client IS NULL) 
BEGIN 
	--SELECT 'here'
	SELECT 
			client = 'All',
			--mbr.client,
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
			INNER JOIN Member mbr
				ON rbm.IHDSMemberId = mbr.ihds_member_id	

		WHERE rbm.IsDenominator = 1 
			AND CONVERT(VARCHAR(8),dr.EndSeedDate,112) = CONVERT(VARCHAR(8),@ReportEndDate,112)
			AND mbr.client IN (SELECT Client FROM @ClientTable)

		GROUP BY 	
			--mbr.client,
			dr.EndSeedDate,
			cm.Measure,
			cm.MeasureMetricDesc
		ORDER BY 	
			--mbr.client,
			dr.EndSeedDate,
			cm.Measure,
			cm.MeasureMetricDesc
END 
ELSE 
BEGIN 
	--SELECT 'There'
	SELECT 
			mbr.client,
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
			INNER JOIN Member mbr
				ON rbm.IHDSMemberId = mbr.ihds_member_id	

		WHERE rbm.IsDenominator = 1 
			AND CONVERT(VARCHAR(8),dr.EndSeedDate,112) = CONVERT(VARCHAR(8),@ReportEndDate,112)
			AND mbr.client IN (SELECT Client FROM @ClientTable)

		GROUP BY 	
			mbr.client,
			dr.EndSeedDate,
			cm.Measure,
			cm.MeasureMetricDesc
		ORDER BY 	
			mbr.client,
			dr.EndSeedDate,
			cm.Measure,
			cm.MeasureMetricDesc



END 

GO
