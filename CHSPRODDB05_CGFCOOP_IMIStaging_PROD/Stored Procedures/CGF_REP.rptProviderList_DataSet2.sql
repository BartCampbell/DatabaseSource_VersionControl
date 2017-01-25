SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec [CGF_REP].[rptProviderList_DataSet2] 'DHMP','12/31/2013 00:00.000'

--/*
CREATE PROC [CGF_REP].[rptProviderList_DataSet2]
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
	Var3Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate,
	Var3Name = '@PopulationDesc',
	Var3Val = @PopulationDesc


SELECT  curr.ProviderID,
		curr.ProviderFullName,
		EndSeedDate = @endseeddate,
		CurrentDenominator = curr.Denominator,
		CurrentCompliance = curr.Compliance,
		PreviousMthDenominator = PrevPeriod.Denominator,
		PreviousMthCompliance = PrevPeriod.Compliance ,
		PreviousYrDenominator = PrevYear.Denominator ,
		PreviousYrCompliance = PrevYear.Compliance 
FROM (SELECT a.ProviderID,
			a.ProviderFullName,
			EndSeedDate = a.EndSeedDate,
			Denominator = Max(IsDenominator ),
			Compliance = AVG(Compliance )
		FROM (SELECT rbm.ProviderID,
					p.ProviderFullName,
					rbm.EndSeedDate,
					rbm.MeasureSet,
					rbm.Measure,
					rbm.MeasureDesc,
					rbm.MeasureMetricDesc,
					IsDenominator = sum(rbm.IsDenominator),
					Compliance = SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0)
				FROM CGF.ResultsByMember rbm
					INNER JOIN provider p
						ON rbm.ProviderID = p.ProviderID
					INNER JOIN CGF.metrics mt
						ON rbm.MetricXrefGuid = mt.MetricXrefGuid
						AND mt.IsShown = 1
				WHERE rbm.IsDenominator = 1 
					AND rbm.Client = @client
					AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
					AND rbm.EndSeedDate = @endseeddate
				GROUP BY rbm.ProviderID,
					p.ProviderFullName,
					rbm.client,
					rbm.EndSeedDate,
					rbm.MeasureSet,
					rbm.Measure,
					rbm.MeasureDesc,
					rbm.MeasureMetricDesc
				) a
		GROUP BY a.ProviderID,
			a.ProviderFullName,
			a.EndSeedDate
		) Curr
		LEFT JOIN (SELECT a.ProviderID,
							a.ProviderFullName,
							EndSeedDate = a.EndSeedDate,
							Denominator = Max(IsDenominator ),
							Compliance = AVG(Compliance )
						FROM (SELECT rbm.ProviderID,
									p.ProviderFullName,
									rbm.client,
									rbm.EndSeedDate,
									rbm.MeasureSet,
									rbm.Measure,
									rbm.MeasureDesc,
									rbm.MeasureMetricDesc,
									IsDenominator = sum(rbm.IsDenominator),
									Compliance = SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0)
								FROM CGF.ResultsByMember rbm
									INNER JOIN provider p
										ON rbm.ProviderID = p.ProviderID
									INNER JOIN CGF.metrics mt
										ON rbm.MetricXrefGuid = mt.MetricXrefGuid
										AND mt.IsShown = 1
								WHERE rbm.IsDenominator = 1 
									AND rbm.Client = @client
									AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
									AND rbm.EndSeedDate = (SELECT MAX(endSeedDate) FROM CGF.ResultsByMember WHERE Client = @Client and EndSeedDate < @endseeddate)
								GROUP BY rbm.ProviderID,
									p.ProviderFullName,
									rbm.client,
									rbm.EndSeedDate,
									rbm.MeasureSet,
									rbm.Measure,
									rbm.MeasureDesc,
									rbm.MeasureMetricDesc
								) a
						GROUP BY a.ProviderID,
							a.ProviderFullName,
							a.EndSeedDate
			) PrevPeriod
				ON curr.ProviderID = PrevPeriod.ProviderID
				AND curr.ProviderFullName = PrevPeriod.ProviderFullName
		LEFT JOIN (SELECT a.ProviderID,
							a.ProviderFullName,
							EndSeedDate = a.EndSeedDate,
							Denominator = Max(IsDenominator ),
							Compliance = AVG(Compliance )
						FROM (SELECT rbm.ProviderID,
									p.ProviderFullName,
									rbm.client,
									rbm.EndSeedDate,
									rbm.MeasureSet,
									rbm.Measure,
									rbm.MeasureDesc,
									rbm.MeasureMetricDesc,
									IsDenominator = sum(rbm.IsDenominator),
									Compliance = SUM(rbm.IsNumerator)/SUM(rbm.IsDenominator*1.0)
								FROM CGF.ResultsByMember rbm
									INNER JOIN provider p
										ON rbm.ProviderID = p.ProviderID
									INNER JOIN CGF.metrics mt
										ON rbm.MetricXrefGuid = mt.MetricXrefGuid
										AND mt.IsShown = 1
								WHERE rbm.IsDenominator = 1 
									AND rbm.Client = @client
									AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
									AND rbm.EndSeedDate = DATEADD(year,-1,@endseeddate)
								GROUP BY rbm.ProviderID,
									p.ProviderFullName,
									rbm.client,
									rbm.EndSeedDate,
									rbm.MeasureSet,
									rbm.Measure,
									rbm.MeasureDesc,
									rbm.MeasureMetricDesc
								) a
						GROUP BY a.ProviderID,
							a.ProviderFullName,
							a.EndSeedDate
			) PrevYear
				ON curr.ProviderID = PrevYear.ProviderID
				AND curr.ProviderFullName = PrevYear.ProviderFullName
	ORDER BY curr.ProviderFullName

--GO

--exec [CGF_REP].[rptProviderList_DataSet2]
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptProviderList_DataSet2] TO [db_ViewProcedures]
GO
