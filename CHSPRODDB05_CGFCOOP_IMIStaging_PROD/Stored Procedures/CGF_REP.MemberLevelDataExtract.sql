SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROC [CGF_REP].[MemberLevelDataExtract]  

@client VARCHAR(100) ,
@endseeddate DATETIME 

AS

SELECT 
		mbr.client,
		dr.EndSeedDate,
		dr.MeasureSet,
		rbm.PopulationDesc,
		cm.Measure,
		cm.MeasureDesc,
		cm.MeasureMetricDesc,
		MemberID = rbm.CustomerMemberID,
		mbr.NameLast,
		mbr.NameFirst,
		mbr.NameMiddleInitial,
		mbr.SSN,
		mbr.DateOfBirth,
		Mbr.Gender,
		mbr.Address1,
		mbr.Address2,
		mbr.City,
		mbr.State,
		mbr.ZipCode,
		Denominator = rbm.IsDenominator,
		Exclusion = rbm.IsExclusion,
		Compliant = rbm.IsNumerator ,
		NonCompliant = CASE WHEN rbm.IsNumerator = 1 THEN 0 ELSE 1 END
	FROM cgf.ResultsByMember rbm
		INNER JOIN cgf.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
		INNER JOIN cgf.Measures m
			ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
		INNER JOIN  cgf.MeasureMetrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
		INNER JOIN Member mbr
			ON rbm.IHDSMemberID = mbr.IHDS_member_id
	WHERE mbr.Client = @client
		AND dr.EndSeedDate = @endseeddate


GO
