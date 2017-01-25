SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
select top 1 *,
		'EXEC [CGF_REP].[rptProvMedGrp_ProviderListMeasure_DataSet2] '''+var1Val+''',''' + var2Val +''',''' + var3Val +''',''' +var4Val+''',''' +Var5Val+''',''' +ISNULL(Var6Val,'NULL')+''',''' +ISNULL(Var7Val,'NULL')+''''
	from cgf_rep.ReportVariableLog
	order by rowid desc
EXEC [CGF_REP].[rptProvMedGrp_ProviderListMeasure_DataSet2] 'TN Co-Op','0','Dec 31 2014 12:00AM','AMM-Acute Phase Treatment','Medicaid',NULL,NULL
*/


--/*
CREATE PROC [CGF_REP].[rptProvMedGrp_ProviderListMeasure_DataSet2]
@client VARCHAR(100) = NULL,
@ProviderMedicalGroupID VARCHAR(50) = null,
@endseeddate DATETIME= NULL,
@Metric VARCHAR(200) = NULL,
@PopulationDesc VARCHAR(50) = NULL,
@ComplianceLimit NUMERIC(5,2) = 1.0,
@MinDenominator INT = NULL
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100),
	@ProviderMedicalGroupID VARCHAR(50) ,
	@endseeddate DATETIME,
	@Metric VARCHAR(200),
	@PopulationDesc VARCHAR(50) ,
	@ComplianceLimit NUMERIC(5,2) = .50,
	@MinDenominator INT = NULL --10
--------------------*/


if @client is null 
	select @Client = max(Client) from cgf.ResultsByMember

IF @metric IS NULL
	SELECT @metric =  'CCS-Cervical Cancer Screening'

IF @endseeddate is null 
	SELECT @endseeddate = MAX(EndSeedDate)
		FROM CGF.ResultsByMember rbm
		WHERE Client = @Client
			AND MeasureMetricDesc = @Metric


IF @ProviderMedicalGroupID IS NULL
	SELECT TOP 1
		@ProviderMedicalGroupID = rbm.ProviderMedicalGroupID
		FROM CGF.ResultsByMember rbm
		WHERE IsDenominator = 1
			AND rbm.Client = @Client
			AND rbm.EndSeedDate = @endseeddate
			AND rbm.PopulationDesc = ISNULL(@PopulationDesc,rbm.PopulationDesc)
			AND rbm.ProviderMedicalGroupID IS NOT NULL 
			AND rbm.MeasureMetricDesc = ISNULL(@Metric,rbm.MeasureMetricDesc)

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
	Var5Val,
	Var6Name,
	Var6Val,
	Var7Name,
	Var7Val
	 )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name= '@ProviderMedicalGroupID',
	Var2val = @ProviderMedicalGroupID,
	Var3Name = '@endseeddate',
	Var3Val = @endseeddate,
	Var4Name = '@Metric',
	Var4Val = @metric,
	Var5Name = '@PopulationDesc',
	Var5Val = @PopulationDesc,
	Var6name = '@ComplianceLimit',
	Var6val = @ComplianceLimit,
	Var7Name = '@MinDenominator',
	Var7Val = @MinDenominator

SELECT  curr.ProviderMedicalGroupID,
		curr.MedicalGroupName,
		curr.ProviderID,
		curr.ProviderFullName,
		Curr.MeasureMetricDesc,
		EndSeedDate = @endseeddate,
		Client = @client,
		CurrentDenominator = curr.Denominator,
		CurrentCompliance = curr.Compliance,
		PreviousMthDenominator = PrevPeriod.Denominator,
		PreviousMthCompliance = PrevPeriod.Compliance ,
		PreviousYrDenominator = PrevYear.Denominator ,
		PreviousYrCompliance = PrevYear.Compliance 
FROM (SELECT a.ProviderMedicalGroupID,
			a.MedicalGroupName,
			a.ProviderID,
			a.ProviderFullName,
			a.MeasureMetricDesc,
			EndSeedDate = a.EndSeedDate,
			Denominator = Max(IsDenominator ),
			Compliance = AVG(Compliance )
		FROM (SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
					MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
					rbm.ProviderID,
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
					LEFT JOIN ProviderMedicalGroup pmg
						ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
					INNER JOIN CGF.metrics mt
						ON rbm.MetricXrefGuid = mt.MetricXrefGuid
						AND mt.IsShown = 1
				WHERE rbm.IsDenominator = 1 
					AND rbm.Client = @client
					AND ISNULL(rbm.ProviderMedicalGroupID,0) = @ProviderMedicalGroupID
					AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
					AND rbm.EndSeedDate = @endseeddate
					AND rbm.MeasureMetricDesc = ISNULL(@Metric,rbm.MeasureMetricDesc)
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
				) a
		GROUP BY a.ProviderMedicalGroupID,
			a.MedicalGroupName,
			a.ProviderID,
			a.ProviderFullName,
			a.EndSeedDate,
			a.MeasureMetricDesc
		) Curr
		LEFT JOIN (SELECT a.ProviderMedicalGroupID,
							a.MedicalGroupName,
							a.ProviderID,
							a.ProviderFullName,
							a.MeasureMetricDesc,
							EndSeedDate = a.EndSeedDate,
							Denominator = Max(IsDenominator ),
							Compliance = AVG(Compliance )
						FROM (SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
									MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
									rbm.ProviderID,
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
									LEFT JOIN ProviderMedicalGroup pmg
										ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
									INNER JOIN CGF.metrics mt
										ON rbm.MetricXrefGuid = mt.MetricXrefGuid
										AND mt.IsShown = 1
								WHERE rbm.IsDenominator = 1 
									AND rbm.Client = @client
									AND ISNULL(rbm.ProviderMedicalGroupID,0) = @ProviderMedicalGroupID
									AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
									AND rbm.EndSeedDate = (SELECT MAX(endSeedDate) FROM CGF.ResultsByMember WHERE Client = @Client and EndSeedDate < @endseeddate)
									AND rbm.MeasureMetricDesc = ISNULL(@Metric,rbm.MeasureMetricDesc)
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
								) a
						GROUP BY a.ProviderMedicalGroupID,
							a.MedicalGroupName,
							a.ProviderID,
							a.ProviderFullName,
							a.EndSeedDate,
							a.MeasureMetricDesc
			) PrevPeriod
				ON curr.ProviderMedicalGroupID = PrevPeriod.ProviderMedicalGroupID
				AND curr.MedicalGroupName = PrevPeriod.MedicalGroupName
				AND curr.ProviderID = PrevPeriod.ProviderID
				AND curr.ProviderFullName = PrevPeriod.ProviderFullName
				AND curr.MeasureMetricDesc = prevPeriod.MeasureMetricDesc
		LEFT JOIN (SELECT a.ProviderMedicalGroupID,
							a.MedicalGroupName,
							a.ProviderID,
							a.ProviderFullName,
							EndSeedDate = a.EndSeedDate,
							a.MeasureMetricDesc,
							Denominator = Max(IsDenominator ),
							Compliance = AVG(Compliance )
						FROM (SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
									MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
									rbm.ProviderID,
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
									LEFT JOIN ProviderMedicalGroup pmg
										ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
									INNER JOIN provider p
										ON rbm.ProviderID = p.ProviderID
									INNER JOIN CGF.metrics mt
										ON rbm.MetricXrefGuid = mt.MetricXrefGuid
										AND mt.IsShown = 1
								WHERE rbm.IsDenominator = 1 
									AND rbm.Client = @client
									AND ISNULL(rbm.ProviderMedicalGroupID,0) = @ProviderMedicalGroupID
									AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
									AND rbm.EndSeedDate = DATEADD(year,-1,@endseeddate)
									AND rbm.MeasureMetricDesc = ISNULL(@Metric,rbm.MeasureMetricDesc)
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
								) a
						GROUP BY a.ProviderMedicalGroupID,
							a.MedicalGroupName,
							a.ProviderID,
							a.ProviderFullName,
							a.EndSeedDate,
							a.MeasureMetricDesc
			) PrevYear
				ON curr.ProviderMedicalGroupID = PrevYear.ProviderMedicalGroupID
				AND curr.MedicalGroupName = PrevYear.MedicalGroupName
				AND curr.ProviderID = PrevYear.ProviderID
				AND curr.ProviderFullName = PrevYear.ProviderFullName
				AND curr.MeasureMetricDesc = prevyear.MeasureMetricDesc
	WHERE ISNULL(@ComplianceLimit,1.00) >= curr.Compliance 
		AND ISNULL(@MinDenominator,curr.Denominator) <= curr.Denominator
	ORDER BY curr.ProviderFullName

GO
