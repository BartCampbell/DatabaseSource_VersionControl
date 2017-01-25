SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--EXEC [CGF_REP].[rptMeasuerByPRoviderComparison_DataSet2]

--/*
CREATE PROC [CGF_REP].[rptMeasuerByPRoviderComparison_DataSet2]
@client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL,
@Metric VARCHAR(200) = 'CDC-HbA1C Test',
@OrderBy INT = 1
AS
--*/

/*------------------
DECLARE  @client VARCHAR(100),
	@endseeddate DATETIME,
	@Metric VARCHAR(200),
	@OrderBY INT

SELECT @client = 'DHMP', 
	@endseeddate = MAX(EndSeedDate) ,
	@Metric =  'CDC-HbA1C Test', --MAX(rbm.MeasureMEtricDesc)
	@orderBy = 2
	FROM CGF.ResultsByMember_Sum rbm
--------------------*/

DECLARE @vcCmd VARCHAR(4000)

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
	Var3Val,
	Var4Name,
	Var4Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate,
	Var3Name = '@Metric',
	Var3Val = @Metric,
	Var4Name = '@OrderBy',
	Var4Val = @OrderBy

IF object_id('tempdb..#res') IS NOT NULL 
	DROP TABLE #res

--SET @vcCmd = 
SELECT rbm.ProviderID,
		p.ProviderFullName,
		mbr.client,
		dr.EndSeedDate,
		dr.MeasureSet,
		cm.Measure,
		cm.MeasureDesc,
		cm.MeasureMetricDesc,
		IsNumerator = SUM(rbm.IsNumerator),
		IsDenominator = SUM(rbm.IsDenominator),
		Compliance = SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0)
	INTO #res
	FROM CGF.ResultsByMember rbm
		INNER JOIN CGF.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
			--AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM cgf.dataruns GROUP BY EndSeedDate)
		INNER JOIN CGF.Measures m
			ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
		INNER JOIN CGF.MeasureMetrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
		INNER JOIN Member mbr
			ON rbm.IHDSMemberID = mbr.IHDS_member_ID
		INNER JOIN provider p
			ON rbm.ProviderID = p.ProviderID
		INNER JOIN CGF.metrics mt
			ON rbm.MetricXrefGuid = mt.MetricXrefGuid
			AND mt.IsShown = 1
	WHERE rbm.IsDenominator = 1 
		AND mbr.Client = @Client --''' + @client + '''
		and CONVERT(VARCHAR(8),dr.EndSeedDate,112) =CONVERT(VARCHAR(8),CONVERT(DATETIME,@endseeddate),112) --''' +  CONVERT(VARCHAR(8),CONVERT(DATETIME,@endseeddate),112) + '''
		AND cm.MeasureMetricDesc = @Metric-- ''' + @Metric + '''
	GROUP BY rbm.ProviderID,
		p.ProviderFullName,
		mbr.client,
		dr.EndSeedDate,
		dr.MeasureSet,
		cm.Measure,
		cm.MeasureDesc,
		cm.MeasureMetricDesc
	ORDER BY ProviderFullName, MeasureMetricDesc
--' 
--+ CASE @OrderBY
--			WHEN 2 THEN 'SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0) DESC, SUM(rbm.IsDenominator) desc'
--			WHEN 3 THEN 'SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0), SUM(rbm.IsDenominator) desc'
--			ELSE 'p.ProviderFullName, cm.MeasureMetricDesc'
--			END
	
--PRINT @vcCmd
--EXEC (@vcCmd)

IF @OrderBy = 1
	SELECT * FROM #res ORDER BY ProviderFullName, MeasureMetricDesc
	ELSE 
	IF @OrderBy = 2 
		SELECT * FROM #res ORDER BY Compliance DESC, IsDenominator DESC
	ELSE IF @OrderBy = 3
			SELECT * FROM #res ORDER BY Compliance, IsDenominator DESC
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptMeasuerByPRoviderComparison_DataSet2] TO [db_ViewProcedures]
GO
