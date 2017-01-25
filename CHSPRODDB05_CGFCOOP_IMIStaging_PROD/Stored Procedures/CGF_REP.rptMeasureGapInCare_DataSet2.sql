SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- exec [CGF_REP].[rptMeasuerGapInCare_DataSEt2] 'VERISK','CCS-Cervical Cancer Screening','Denver Health Commercial'

--exec cgf_rep.[rptMeasureGapInCare_DataSet2]

/*
sp_helpindex 'cgf.ResultsByMember'

create index idxDenClientMeasPop on cgf.ResultsByMember (IsDenominator, client, measuremetricdesc, populationdesc) include (DataRunGuid, MetricXrefGuid, isNumerator)
create statistics sp_idxDenClientMeasPop on cgf.ResultsByMember (IsDenominator, client, measuremetricdesc, populationdesc)

select * from cgf_rep.ReportVariableLog WHERE ProcName = 'rptMeasureGapInCare_DataSet2'
*/


--/*

CREATE PROC [CGF_REP].[rptMeasureGapInCare_DataSet2]
@client VARCHAR(100) = NULL,
@measuremetricdesc VARCHAR(200) =  'CDC-HbA1C Test',
@PopulationDesc VARCHAR(50) = NULL
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100),
	@endseeddate DATETIME,
	@measuremetricdesc VARCHAR(200),
	@PopulationDesc VARCHAR(50) 

SELECT @client = 'DHMP', 
	@measuremetricdesc = 'CDC-HbA1C Test'
--------------------*/

insert into cgf_rep.ReportVariableLog
	(RunDate ,
	ProcName ,
	Var1Name ,
	Var1Val ,
	Var2Name,
	Var2Val ,
	Var3Name ,
	Var3Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@measuremetricdesc',
	Var2Val = @measuremetricdesc,
	Var3Name = '@PopulationDesc',
	Var3Val = @PopulationDesc


IF @client  is null 
	SELECT @Client = Max(client)
		FROM cgf.ResultsByMember rbm

SELECT 
		mbr.client,
		dr.EndSeedDate,
		cm.MeasureMetricDesc,
		rbm.PopulationDesc,
		IsNumerator = SUM(rbm.IsNumerator),
		IsDenominator = SUM(rbm.IsDenominator)
	FROM cgf.ResultsByMember rbm 
		INNER JOIN cgf.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
			--AND dr.CreatedDate IN (SELECT MAX(CreatedDate) FROM cgf.dataruns GROUP BY EndSeedDate)
		INNER JOIN cgf.MeasureMEtrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
		INNER JOIN Member mbr
			ON rbm.IHDSMemberId = mbr.ihds_member_id		
	WHERE rbm.IsDenominator = 1 
		AND mbr.Client = ISNULL(@Client,mbr.Client)
		AND RTRIM(cm.MeasureMetricDesc) = RTRIM(ISNULL(@measuremetricdesc,cm.MeasureMetricDesc))
		AND RTRIM(rbm.PopulationDesc) = RTRIM(ISNULL(@PopulationDesc,rbm.PopulationDesc))
		--AND ISNULL(rbm.PopulationDesc,'Not Defined') = RTRIM(ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined')))
	GROUP BY mbr.client,
		dr.EndSeedDate,
		cm.MeasureMetricDesc,
		rbm.PopulationDesc



GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptMeasureGapInCare_DataSet2] TO [db_ViewProcedures]
GO
