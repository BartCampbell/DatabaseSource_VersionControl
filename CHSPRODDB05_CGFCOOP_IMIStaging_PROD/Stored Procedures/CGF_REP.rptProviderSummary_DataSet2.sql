SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--/*

--select * from cgf_rep.ReportVariableLog order by rundate desc

--exec [CGF_REP].[rptProviderSummary_DataSet2] 'DHMP','20131231','8289725',null

--/*
CREATE PROC [CGF_REP].[rptProviderSummary_DataSet2]
@client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL,
@providerid VARCHAR(50) = NULL,
@PopulationDesc VARCHAR(50) = NULL
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100),
	@endseeddate DATETIME,
	@providerid VARCHAR(50),
	@PopulationDesc VARCHAR(50) 
--------------------*/

if @client is null 
	select @Client = max(Client) from cgf.ResultsByMember_sum

IF @endseeddate IS NULL
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember_sum 
		WHERE IsDenominator = 1
			AND client = @Client

IF @providerid IS NULL
	SELECT TOP 1
		@providerid = rbm.providerid
		FROM CGF.ResultsByMember rbm
			INNER JOIN provider p
				ON rbm.ProviderID = p.ProviderID
		WHERE IsDenominator = 1
			AND rbm.Client = @Client
			AND rbm.EndSeedDate = @endseeddate
			and ISNULL(p.ProviderFullName,'Default, provider') <> 'Default, provider' 
			AND rbm.PopulationDesc = ISNULL(@PopulationDesc,rbm.PopulationDesc)

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
	Var3Name = '@providerid',
	Var3Val = @providerid,
	Var4Name = '@PopulationDesc',
	Var4Val = @PopulationDesc 

SELECT rbm.ProviderID,
		p.ProviderFullName,
		rbm.client,
		rbm.EndSeedDate,
		rbm.MeasureSet,
		rbm.Measure,
		rbm.MeasureDesc,
		rbm.MeasureMetricDesc,
		IsNumerator = SUM(rbm.IsNumerator),
		IsDenominator = SUM(rbm.IsDenominator),
		Compliance = SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0)
	FROM CGF.ResultsByMember rbm
		INNER JOIN provider p
			ON rbm.ProviderID = p.ProviderID
		INNER JOIN CGF.metrics mt
			ON rbm.MetricXrefGuid = mt.MetricXrefGuid
			AND mt.IsShown = 1
	WHERE rbm.IsDenominator = 1 
		AND rbm.Client = @client
		and rbm.EndSeedDate = @endseeddate
		AND p.ProviderID = @providerid
		AND rbm.PopulationDesc = isnull(@PopulationDesc ,rbm.PopulationDesc)
	GROUP BY rbm.ProviderID,
		p.ProviderFullName,
		rbm.client,
		rbm.EndSeedDate,
		rbm.MeasureSet,
		rbm.Measure,
		rbm.MeasureDesc,
		rbm.MeasureMetricDesc
	ORDER BY rbm.MeasureMetricDesc		
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptProviderSummary_DataSet2] TO [db_ViewProcedures]
GO
