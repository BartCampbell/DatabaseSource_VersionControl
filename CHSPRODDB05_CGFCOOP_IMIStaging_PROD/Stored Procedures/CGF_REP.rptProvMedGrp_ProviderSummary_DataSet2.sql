SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--/*

--select * from cgf_rep.ReportVariableLog order by rundate desc

--exec [CGF_REP].[rptProvMedGrp_ProviderSummary_DataSet2] 'DHMP','20131231','8289725',null

--/*
CREATE PROC [CGF_REP].[rptProvMedGrp_ProviderSummary_DataSet2]
@client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL,
@providerid VARCHAR(50) = NULL,
@PopulationDesc VARCHAR(50) = NULL,
@ProviderMedicalGroupID VARCHAR(50) = null
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100),
	@endseeddate DATETIME,
	@providerid VARCHAR(50),
	@PopulationDesc VARCHAR(50) ,
	@ProviderMedicalGroupID VARCHAR(50) 
--------------------*/

if @client is null 
	select @Client = max(Client) from cgf.ResultsByMember_sum

IF @endseeddate IS NULL
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember
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

IF @ProviderMedicalGroupID IS NULL
	SELECT TOP 1
		@ProviderMedicalGroupID = rbm.ProviderMedicalGroupID
		FROM CGF.ResultsByMember rbm
		WHERE IsDenominator = 1
			AND rbm.Client = @Client
			AND rbm.EndSeedDate = @endseeddate
			AND rbm.PopulationDesc = ISNULL(@PopulationDesc,rbm.PopulationDesc)
			AND rbm.ProviderMedicalGroupID IS NOT NULL 

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
	Var4Val,
	Var5Name,
	Var5Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate,
	Var3Name = '@providerid',
	Var3Val = @providerid,
	Var4Name = '@PopulationDesc',
	Var4Val = @PopulationDesc ,
	Var5Name = '@ProviderMedicalGroupID',
	Var5Val = @ProviderMedicalGroupID 


SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
		MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
		rbm.ProviderID,
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
		LEFT JOIN ProviderMedicalGroup pmg
			ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
		INNER JOIN provider p
			ON rbm.ProviderID = p.ProviderID
		INNER JOIN CGF.metrics mt
			ON rbm.MetricXrefGuid = mt.MetricXrefGuid
			AND mt.IsShown = 1
	WHERE rbm.IsDenominator = 1 
		AND rbm.Client = @client
		and rbm.EndSeedDate = @endseeddate
		AND p.ProviderID = @providerid
		AND ISNULL(RBM.ProviderMedicalGroupID,0) = @ProviderMedicalGroupID
		AND rbm.PopulationDesc = isnull(@PopulationDesc ,rbm.PopulationDesc)
	GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0),
		CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
		rbm.ProviderID,
		p.ProviderFullName,
		rbm.client,
		rbm.EndSeedDate,
		rbm.MeasureSet,
		rbm.Measure,
		rbm.MeasureDesc,
		rbm.MeasureMetricDesc
	ORDER BY rbm.MeasureMetricDesc		
GO
