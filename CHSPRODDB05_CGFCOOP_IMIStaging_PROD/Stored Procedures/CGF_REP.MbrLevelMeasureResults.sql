SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MbrLevelMeasureResults] 
AS

SELECT 
		mbr.client,
		dr.EndSeedDate,
		dr.MeasureSet,
		cm.Measure,
		cm.MeasureDesc,
		cm.MeasureMetricDesc,
		rbm.CustomerMemberID,
		mbr.MemberID,
		mbr.DateOfBirth,
		Mbr.Gender,
		mbr.Address1,
		mbr.Address2,
		mbr.City,
		mbr.State,
		mbr.ZipCode,
		rbm.IsNumerator ,
		rbm.IsDenominator
	FROM cgf.ResultsByMember rbm
		INNER JOIN cgf.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
		INNER JOIN cgf.Measures m
			ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
		INNER JOIN  cgf.MeasureMetrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
		INNER JOIN Member mbr
			ON rbm.IHDSMemberID = mbr.IHDS_member_id
	WHERE rbm.IsDenominator = 1 

GO
GRANT VIEW DEFINITION ON  [CGF_REP].[MbrLevelMeasureResults] TO [db_ViewProcedures]
GO
