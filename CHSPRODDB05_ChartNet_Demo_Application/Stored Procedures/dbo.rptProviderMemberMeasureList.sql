SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	rptProviderMemberMeasureList
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

Process:	
Test Script: 
ToDo:		

*/

--/*
CREATE PROC [dbo].[rptProviderMemberMeasureList]
@client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL,
@providerid VARCHAR(50) = NULL
AS
--*/

/*--------------------
DECLARE  @client VARCHAR(100)		= 'HPSJ',
	@endseeddate DATETIME			= 'Dec 31 2016 12:00AM',
	@providerid VARCHAR(50)			= '1011617'

--------------------*/

if @client is null 
	select TOP 1 @Client = Client
		FROM (SELECT Client, cnt = COUNT(*)
				FROM cgf.ResultsByMember_sum
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
	Var3Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate,
	Var3Name = '@providerid',
	Var3Val = @providerid


SELECT rbm.ProviderID,
		p.ProviderFullName,
		MedicalGroupName = pmg.MedicalGroupName,
		ProviderAddress1 = p.Address1,
		ProviderAddress2 = p.Address2,
		ProviderCity = p.City,
		ProviderState = p.State,
		ProviderZip = p.Zip,
		mbr.client,
		dr.EndSeedDate,
		dr.MeasureSet,
		cm.Measure,
		cm.MeasureDesc,
		cm.MeasureMetricDesc,
		rbm.CustomerMemberID,
		mbr.MemberID,
		mbr.ihds_member_id,
		MemberFullName= mbr.NameLast + CASE WHEN mbr.NameFirst IS NOT NULL THEN ', ' + mbr.NameFirst ELSE '' END,
		mbr.DateOfBirth,
		Mbr.Gender,
		MemberAddress1 = mbr.Address1,
		MemberAddress2 = mbr.Address2,
		MemberCity = mbr.City,
		MemberState = mbr.State,
		MemberZip = mbr.ZipCode,
		IsNumerator = CASE WHEN rbm.IsNumerator = 1 THEN 'Compliant' ELSE 'Non Compliant' END,
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
		LEFT JOIN dbo.ProviderMedicalGroup pmg
			ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGroupID
	WHERE rbm.IsDenominator = 1 
		AND mbr.Client = @client
		and dr.EndSeedDate = @endseeddate
		AND p.ProviderID = @providerid



GO
