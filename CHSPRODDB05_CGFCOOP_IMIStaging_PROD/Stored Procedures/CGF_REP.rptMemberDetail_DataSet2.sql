SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--/*
CREATE PROC [CGF_REP].[rptMemberDetail_DataSet2]
@client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL,
@customermemberid VARCHAR(50) = NULL,
@GapsOnly BIT = 0,
@IHDSMemberID INT = NULL
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100),
	@endseeddate DATETIME,
	@measuremetricdesc VARCHAR(200),
	@customermemberid VARCHAR(50)

SELECT @client = 'DHMP', 
	@endseeddate = MAX(EndSeedDate) ,
	@measuremetricdesc = MAX(rbm.MeasureMEtricDesc),
	@customermemberid = MAX(rbm.CustomerMemberID)
	FROM CGF.ResultsByMember rbm
--------------------*/


if @client is null 
	select @Client = max(Client) from cgf.ResultsByMember_sum

IF @endseeddate IS NULL
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember_sum 
		WHERE IsDenominator = 1
			AND client = @Client

IF @customermemberid IS NULL
	AND @IHDSMemberID IS NULL 
	SELECT @customermemberid = MAX(rbm.CustomerMemberID)
		FROM CGF.ResultsByMember rbm
		WHERE IsDenominator = 1
			AND Client = @Client 
			AND EndSeedDate = @EndSeedDate

IF @IHDSMemberID IS NULL 
	SELECT @IHDSMemberID = MAX(ihds_member_id)
		FROM Member
		WHERE Client = @client
			AND CustomerMemberID = @customermemberid

IF @customermemberid IS NULL 
	SELECT @customermemberid = MAX(CustomerMemberID)
		FROM dbo.Member
		WHERE Client = @client
			AND ihds_member_id = @IHDSMemberID

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
	Var3Name = '@customermemberid',
	Var3Val = @customermemberid,
	Var4Name = '@GapsOnly',
	Var4Val = @GapsOnly


SELECT 
		mbr.client,
		dr.EndSeedDate,
		dr.MeasureSet,
		cm.Measure,
		cm.MeasureDesc,
		cm.MeasureMetricDesc,
		rbm.CustomerMemberID,
		rbm.IHDSMemberID,
		mbr.MemberID,
		FullName= LTRIM(mbr.NameLast) + CASE WHEN mbr.NameFirst IS NOT NULL THEN ', ' + mbr.NameFirst ELSE '' END,
		mbr.DateOfBirth,
		Mbr.Gender,
		FullAddress = RTRIM(mbr.Address1) + ' ' + RTRIM(mbr.City) + ', ' + RTRIM(mbr.State) + ' ' + mbr.ZipCode,
		rbm.IsNumerator ,
		rbm.IsDenominator
	FROM CGF.ResultsByMember rbm
		INNER JOIN CGF.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
			--AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM CGF.dataruns GROUP BY EndSeedDate)
			
		INNER JOIN CGf.Measures m
			ON rbm.MeasureXrefGuid = m.MeasureXrefGuid
		INNER JOIN CGf.MeasureMetrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
		INNER JOIN Member mbr
			ON rbm.IHDSMemberID = mbr.IHDS_Member_ID
	WHERE rbm.IsDenominator = 1 
		AND 1 = CASE WHEN @GapsOnly = 0 THEN 1
					WHEN rbm.IsNumerator = 0 THEN 1 
					ELSE 0
					END
		AND mbr.Client = @client
		and dr.EndSeedDate = @endseeddate
		AND rbm.CustomerMemberID = @customermemberid
		AND rbm.IHDSMemberID = @IHDSMemberID
	ORDER BY cm.MeasureMetricDesc
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptMemberDetail_DataSet2] TO [db_ViewProcedures]
GO
