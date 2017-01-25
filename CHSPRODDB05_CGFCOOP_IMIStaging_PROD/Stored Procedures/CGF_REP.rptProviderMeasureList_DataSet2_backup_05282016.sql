SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	[CGF_REP].[rptProviderMeasureList_DataSet2]
Author:		Leon Dowling
Copyright:	© 2014
Date:		2014.01.01
Purpose:	
Parameters: 
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		
Update Log:
9/14/2015 - update for null client and add client null prov logic
Process:	
Test Script: 
ToDo:		

*/

--/*
CREATE PROC [CGF_REP].[rptProviderMeasureList_DataSet2_backup_05282016]
@client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL,
@measuremetricdesc VARCHAR(200) = 'CDC-HbA1C Test', 
@providerid VARCHAR(50) = NULL
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100),
	@endseeddate DATETIME,
	@measuremetricdesc VARCHAR(200),
	@providerid VARCHAR(50)

--------------------*/

if @client is null 
	select TOP 1 @Client = Client
		FROM (SELECT Client, cnt = COUNT(*)
				FROM cgf.ResultsByMember_sum
				WHERE MeasureMetricDesc = @measuremetricdesc
				GROUP BY Client
				) a
		ORDER BY cnt DESC

IF @endseeddate IS NULL
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember_sum 
		WHERE IsDenominator = 1
			AND client = @Client

IF @ProviderID IS NULL
	SELECT TOP 1
		@providerid = rbm.providerid
		FROM CGF.ResultsByMember rbm
		WHERE IsDenominator = 1
			and rbm.providerid is not null
			and rbm.MeasureMetricDesc = @measuremetricdesc
			AND rbm.EndSeedDate = @endseeddate
			AND rbm.Client = @client

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
	Var3Name = '@measuremetricdesc',
	Var3Val = @measuremetricdesc,
	Var4Name = '@providerid',
	Var4Val = @providerid


SELECT rbm.ProviderID,
		p.ProviderFullName,
		mbr.client,
		dr.EndSeedDate,
		dr.MeasureSet,
		cm.Measure,
		cm.MeasureDesc,
		cm.MeasureMetricDesc,
		rbm.CustomerMemberID,
		mbr.MemberID,
		mbr.ihds_member_id,
		FullName= mbr.NameLast + CASE WHEN mbr.NameFirst IS NOT NULL THEN ', ' + mbr.NameFirst ELSE '' END,
		mbr.DateOfBirth,
		Mbr.Gender,
		mbr.Address1,
		mbr.Address2,
		mbr.City,
		mbr.State,
		mbr.ZipCode,
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
		INNER JOIN provider p
			ON rbm.ProviderID = p.ProviderID
		INNER JOIN CGF.metrics mt
			ON rbm.MetricXrefGuid = mt.MetricXrefGuid
			AND mt.IsShown = 1
	WHERE rbm.IsDenominator = 1 
		AND mbr.Client = @client
		and dr.EndSeedDate = @endseeddate
		AND cm.MeasureMetricDesc = @measuremetricdesc
		AND p.ProviderID = @providerid


GO
