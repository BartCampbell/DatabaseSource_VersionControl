SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec [CGF_REP].[rptProvMedGrpList_DataSet2] 'DHMP','12/31/2013 00:00.000'

--/*
CREATE PROC [CGF_REP].[rptProvMedGrpList_DataSet2]
@client VARCHAR(100) = NULL,
@endseeddate DATETIME  = NULL,
@PopulationDesc VARCHAR(50) = NULL
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100) ,
	@endseeddate DATETIME  ,
	@PopulationDesc VARCHAR(50) 
--------------------*/

if @client is null 
	select @Client = max(Client) from cgf.ResultsByMember

IF @endseeddate IS NULL
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember
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
	Var3Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate,
	Var3Name = '@PopulationDesc',
	Var3Val = @PopulationDesc


SELECT  curr.ProviderMedicalGroupID,
		curr.MedicalGroupName,
		EndSeedDate = @endseeddate,
		CurrentDenominator = curr.Denominator,
		CurrentCompliance = curr.Compliance,
		PreviousMthDenominator = PrevPeriod.Denominator,
		PreviousMthCompliance = PrevPeriod.Compliance ,
		PreviousYrDenominator = PrevYear.Denominator ,
		PreviousYrCompliance = PrevYear.Compliance 
FROM (SELECT a.ProviderMedicalGroupID,
			a.MedicalGroupName,
			EndSeedDate = a.EndSeedDate,
			Denominator = Max(IsDenominator ),
			Compliance = AVG(Compliance )
		FROM (SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
					MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
					rbm.EndSeedDate,
					rbm.MeasureSet,
					rbm.Measure,
					rbm.MeasureDesc,
					rbm.MeasureMetricDesc,
					IsDenominator = sum(rbm.IsDenominator),
					Compliance = SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0)
				FROM CGF.ResultsByMember rbm
					LEFT JOIN ProviderMedicalGroup pmg
						ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
					INNER JOIN CGF.metrics mt
						ON rbm.MetricXrefGuid = mt.MetricXrefGuid
						AND mt.IsShown = 1
				WHERE rbm.IsDenominator = 1 
					AND rbm.Client = @client
					AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
					AND rbm.EndSeedDate = @endseeddate
				GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0),
					CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
					rbm.client,
					rbm.EndSeedDate,
					rbm.MeasureSet,
					rbm.Measure,
					rbm.MeasureDesc,
					rbm.MeasureMetricDesc
				) a
		GROUP BY a.ProviderMedicalGroupID,
			a.MedicalGroupName,
			a.EndSeedDate
		) Curr
		LEFT JOIN (SELECT a.ProviderMedicalGroupID,
							a.MedicalGroupName,
							EndSeedDate = a.EndSeedDate,
							Denominator = Max(IsDenominator ),
							Compliance = AVG(Compliance )
						FROM (SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
									MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
									rbm.client,
									rbm.EndSeedDate,
									rbm.MeasureSet,
									rbm.Measure,
									rbm.MeasureDesc,
									rbm.MeasureMetricDesc,
									IsDenominator = sum(rbm.IsDenominator),
									Compliance = SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0)
								FROM CGF.ResultsByMember rbm
									LEFT JOIN ProviderMedicalGroup pmg
										ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
									INNER JOIN CGF.metrics mt
										ON rbm.MetricXrefGuid = mt.MetricXrefGuid
										AND mt.IsShown = 1
								WHERE rbm.IsDenominator = 1 
									AND rbm.Client = @client
									AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
									AND rbm.EndSeedDate = (SELECT MAX(endSeedDate) FROM CGF.ResultsByMember WHERE Client = @Client and EndSeedDate < @endseeddate)
								GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0),
									CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
									rbm.client,
									rbm.EndSeedDate,
									rbm.MeasureSet,
									rbm.Measure,
									rbm.MeasureDesc,
									rbm.MeasureMetricDesc
								) a
						GROUP BY a.ProviderMedicalGroupID,
							a.MedicalGroupName,
							a.EndSeedDate
			) PrevPeriod
				ON curr.ProviderMedicalGroupID = PrevPeriod.ProviderMedicalGroupID
				AND curr.MedicalGroupName = PrevPeriod.MedicalGroupName
		LEFT JOIN (SELECT a.ProviderMedicalGroupID,
							a.MedicalGroupName,
							EndSeedDate = a.EndSeedDate,
							Denominator = Max(IsDenominator ),
							Compliance = AVG(Compliance )
						FROM (SELECT  ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
									MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
									rbm.client,
									rbm.EndSeedDate,
									rbm.MeasureSet,
									rbm.Measure,
									rbm.MeasureDesc,
									rbm.MeasureMetricDesc,
									IsDenominator = sum(rbm.IsDenominator),
									Compliance = SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0)
								FROM CGF.ResultsByMember rbm
									LEFT JOIN ProviderMedicalGroup pmg
										ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
									INNER JOIN CGF.metrics mt
										ON rbm.MetricXrefGuid = mt.MetricXrefGuid
										AND mt.IsShown = 1
								WHERE rbm.IsDenominator = 1 
									AND rbm.Client = @client
									AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
									AND rbm.EndSeedDate = DATEADD(year,-1,@endseeddate)
								GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0),
									CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
									rbm.client,
									rbm.EndSeedDate,
									rbm.MeasureSet,
									rbm.Measure,
									rbm.MeasureDesc,
									rbm.MeasureMetricDesc
								) a
						GROUP BY a.ProviderMedicalGroupID,
							a.MedicalGroupName,
							a.EndSeedDate
			) PrevYear
				ON curr.ProviderMedicalGroupID = PrevYear.ProviderMedicalGroupID
				AND curr.MedicalGroupName = PrevYear.MedicalGroupName
	ORDER BY curr.MedicalGroupName

--GO

--exec [CGF_REP].[rptProviderList_DataSet2]
GO
