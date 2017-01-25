SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--/*
CREATE PROC [CGF_REP].[rptMeasureList_DataSet2]
@client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL, 
@measuremetricdesc VARCHAR(200) = 'CDC-HbA1C Test',
@PopulationDesc VARCHAR(50) = NULL
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100),
	@endseeddate DATETIME,
	@measuremetricdesc VARCHAR(200)

SELECT @client = 'DHMP', 
	@endseeddate = MAX(EndSeedDate) ,
	@measuremetricdesc = MAX(rbm.MeasureMEtricDesc)
	FROM CGF.ResultsByMember_Sum rbm
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
	Var2Val ,
	Var3Name,
	Var3Val,
	Var4Name,
	Var4Val)
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate,
	Var3name = '@measuremetricdesc',
	Var3Val = @measuremetricdesc,
	Var4Name = '@PopulationDesc',
	Var4Val = @PopulationDesc


SELECT 
		mbr.client,
		dr.EndSeedDate,
		--dr.MeasureSet,
		--cm.Measure,
		--cm.MeasureDesc,
		cm.MeasureMetricDesc,
		rbm.CustomerMemberID,
		mbr.ihds_member_id,
		FullName= mbr.NameLast + CASE WHEN mbr.NameFirst IS NOT NULL THEN ', ' + mbr.NameFirst ELSE '' END,
		PopulationDesc = ISNULL(rbm.PopulationDesc,'Not Defined'),
		--mbr.DateOfBirth,
		--Mbr.Gender,
		--mbr.Address1,
		--mbr.Address2,
		--mbr.City,
		--mbr.State,
		--mbr.ZipCode,
		rbm.IsNumerator ,
		rbm.IsDenominator
	FROM CGF.ResultsByMember rbm
		INNER JOIN CGF.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
			--AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM CGF.dataruns GROUP BY EndSeedDate)
		INNER JOIN CGF.Measures m
			ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
		INNER JOIN CGF.MeasureMetrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
		INNER JOIN Member mbr
			ON rbm.IHDSMemberID = mbr.IHDS_Member_ID
	WHERE rbm.IsDenominator = 1 
		AND mbr.Client = @client
		and dr.EndSeedDate = @endseeddate
		AND cm.MeasureMetricDesc = @measuremetricdesc
		AND ISNULL(rbm.PopulationDesc,'Not Defined') = ISNULL(@PopulationDesc,ISNULL(rbm.PopulationDesc,'Not Defined'))
	ORDER BY mbr.NameLast + CASE WHEN mbr.NameFirst IS NOT NULL THEN ', ' + mbr.NameFirst ELSE '' END
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptMeasureList_DataSet2] TO [db_ViewProcedures]
GO
