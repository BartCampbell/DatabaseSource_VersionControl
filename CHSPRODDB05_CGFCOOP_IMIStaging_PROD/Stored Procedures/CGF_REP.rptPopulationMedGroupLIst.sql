SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
select top 10 *
	from cgf_rep.ReportVariableLog
	order by rowid desc
*/
--exec [CGF_REP].[rptPopulationMedGroupLIst] 'tn co-op','12/31/2014 00:00.000','Medicaid','AMM-Acute Phase Treatment'

--/*
CREATE PROC [CGF_REP].[rptPopulationMedGroupLIst]
(
	@client VARCHAR(100) = NULL,
	@endseeddate DATETIME  = NULL,
	@PopulationDesc VARCHAR(50) = NULL, 
	@Metric VARCHAR(200) = NULL
)
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100) ,
	@endseeddate DATETIME  ,
	@PopulationDesc VARCHAR(50) ,
	@Metric VARCHAR(200) 


	select * from cgf_rep.ReportVariableLog where procname = 'rptPopulationMedGroupLIst' order by rundate desc 

	exec [CGF_REP].[rptPopulationMedGroupLIst] @Client='CGFTest', @endseeddate='12/31/2014', 
		@PopulationDesc	= 'CHP,Commercial,Medicaid,Medicare',
		@metric	= 'BCS-Breast Cancer Screening'

		Medicaid
Medicare
--------------------*/

--	Declare variables 
DECLARE @PopulationTable TABLE ( Name NVARCHAR(MAX) )


if ( @client is null ) 
	select @Client = max(Client) from cgf.ResultsByMember

IF ( @endseeddate IS NULL )
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember
		WHERE IsDenominator = 1
			AND client = @Client

IF ( @metric IS NULL ) 
	SELECT @metric =  'CCS-Cervical Cancer Screening'

IF ( @PopulationDesc IS NULL )
BEGIN 
	INSERT INTO @PopulationTable 
	SELECT TOP 1 rbm.PopulationDesc
		FROM CGF.ResultsByMember rbm
		WHERE IsDenominator = 1
			AND client = @Client
			AND rbm.MeasureMetricDesc = @Metric
END 
ELSE 
BEGIN 
	INSERT INTO @PopulationTable 
	SELECT Name FROM [dbo].[fnSplit](@PopulationDesc,',')
END 

INSERT INTO cgf_rep.ReportVariableLog
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
	Var3Name = '@PopulationDesc',
	Var3Val = @PopulationDesc,
	Var4Name = '@metric',
	Var4Val = @metric


SELECT  Curr.Client,
		Curr.PopulationDesc,
		curr.ProviderMedicalGroupID,
		curr.MedicalGroupName,
		curr.MeasureMetricDesc,
		EndSeedDate = @endseeddate,
		CurrentDenominator = curr.ISDenominator,
		CurrentCompliance = curr.Compliance,
		PreviousYrDenominator = PrevYear.ISDenominator ,
		PreviousYrCompliance = PrevYear.Compliance 
FROM (SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
			MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
			rbm.client, 
			rbm.EndSeedDate,
			rbm.MeasureMetricDesc,
			rbm.PopulationDesc,
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
			--AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
			AND ISNULL(rbm.PopulationDesc,'Not Defined') IN (SELECT Name FROM @PopulationTable)
			AND rbm.EndSeedDate = @endseeddate
			AND rbm.MeasureMetricDesc = @Metric
		GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0),
			CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
			rbm.client,
			rbm.EndSeedDate,
			rbm.MeasureMetricDesc,
			rbm.PopulationDesc
		) Curr
		LEFT JOIN (SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
						MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
						rbm.client, 
						rbm.EndSeedDate,
						rbm.MeasureMetricDesc,
						rbm.PopulationDesc,
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
						--AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
						AND ISNULL(rbm.PopulationDesc,'Not Defined') IN (SELECT Name FROM @PopulationTable)
						AND rbm.EndSeedDate = DATEADD(year,-1,@endseeddate)
						AND rbm.MeasureMetricDesc = @Metric
					GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0),
						CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END,
						rbm.client,
						rbm.EndSeedDate,
						rbm.MeasureMetricDesc,
						rbm.PopulationDesc
			) PrevYear
				ON curr.ProviderMedicalGroupID = PrevYear.ProviderMedicalGroupID
				AND curr.MedicalGroupName = PrevYear.MedicalGroupName
				AND curr.Client = PrevYear.Client
				AND curr.PopulationDesc = PrevYear.PopulationDesc
				AND curr.MeasureMetricDesc = PrevYear.MeasureMetricDesc
	ORDER BY curr.MedicalGroupName

--GO

--exec [CGF_REP].[rptProviderList_DataSet2]

GO
