SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--/*

--select * from cgf_rep.ReportVariableLog order by rundate desc

--exec [CGF_REP].[rptProvMedGrpSummary_DataSet2] 'DHMP','20140430','2413',null

--/*
CREATE PROC [CGF_REP].[rptProvMedGrpSummary_DataSet2]
@client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL,
@ProviderMedicalGroupID VARCHAR(50) = NULL,
@PopulationDesc VARCHAR(50) = NULL
AS
--*/

/*--------------------
DECLARE @client VARCHAR(100) ,
	@endseeddate DATETIME ,
	@ProviderMedicalGroupID VARCHAR(50) ,
	@PopulationDesc VARCHAR(50) 
--------------------*/

if @client is null 
	select @Client = max(Client) from cgf.ResultsByMember

IF @endseeddate IS NULL
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember
		WHERE IsDenominator = 1
			AND client = @Client

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
	Var4Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate,
	Var3Name = '@ProviderMedicalGroupID',
	Var3Val = @ProviderMedicalGroupID,
	Var4Name = '@PopulationDesc',
	Var4Val = @PopulationDesc 

SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
		MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
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
		INNER JOIN CGF.metrics mt
			ON rbm.MetricXrefGuid = mt.MetricXrefGuid
			AND mt.IsShown = 1
	WHERE rbm.IsDenominator = 1 
		AND rbm.Client = @client
		and rbm.EndSeedDate = @endseeddate
		AND rbm.ProviderMedicalGroupID = @ProviderMedicalGroupID
		AND rbm.PopulationDesc = isnull(@PopulationDesc ,rbm.PopulationDesc)
	GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0),
		CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
		rbm.client,
		rbm.EndSeedDate,
		rbm.MeasureSet,
		rbm.Measure,
		rbm.MeasureDesc,
		rbm.MeasureMetricDesc
	ORDER BY rbm.MeasureMetricDesc		

GO
