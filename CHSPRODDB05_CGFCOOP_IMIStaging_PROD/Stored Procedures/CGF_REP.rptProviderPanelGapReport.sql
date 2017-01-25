SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************************************************
Procedure:	[CGF_REP].[rptProviderPanelGapReport]
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
	
		exec [CGF_REP].[rptProviderPanelGapReport]
			@Client = 'CGFTest'
			, @endseeddate = '20141231'
			, @ProviderId = 9969807
			, @MeasureDesc = 'CIS-Childhood Immunization Status'
			, @MeasureDesc = 'ABA-Adult BMI Assessment'
			, @MeasureDesc = 'AAB-Avoidance of Antibiotic Therapy for Adults with Acute Bronchitis,AAP-Adults'' Access to Preventive/Ambulatory Health Services,ABA-Adult BMI Assessment'


SELECT DISTINCT MeasureDesc
		FROM CGF.ResultsByMember rbm
		WHERE IsDenominator = 1
			AND rbm.EndSeedDate = '20141231'
			AND rbm.Client = 'CGFTest'


ToDo:		

*/

--/*
CREATE PROC [CGF_REP].[rptProviderPanelGapReport]
	@Client			varchar(100) = NULL,
	@EndSeedDate	datetime = NULL,
	@ProviderId		varchar(50) = NULL,
	@MeasureDesc	varchar(MAX) = NULL 
AS

--	INSERT INTO Thomas_TEMP (field_1) SELECT @MeasureDesc
--	SELECT * FROM Thomas_TEMP 
--	TRUNCATE TABLE Thomas_TEMP 
--AAB-Avoidance of Antibiotic Therapy for Adults with Acute Bronchitis,AAP-Adults'' Access to Preventive/Ambulatory Health Services,ABA-Adult BMI Assessment

--*/

/*--------------------
DECLARE  @Client VARCHAR(100),
	@endseeddate DATETIME,
	@ProviderId VARCHAR(50)
--------------------*/

DECLARE @MeasureTable TABLE ( MeasureDesc NVARCHAR(MAX) )

IF @Client IS NULL 
	SELECT TOP 1 @Client = Client
		FROM (SELECT Client, cnt = COUNT(*)
				FROM cgf.ResultsByMember_sum
				GROUP BY Client
				) a
		ORDER BY cnt DESC

IF @EndSeedDate IS NULL
	SELECT @EndSeedDate = MAX(endseeddate) 
		FROM CGF.ResultsByMember_sum 
		WHERE IsDenominator = 1
			AND client = @Client

IF @ProviderId IS NULL
	SELECT TOP 1
		@ProviderId = rbm.providerid
		FROM CGF.ResultsByMember rbm
		WHERE IsDenominator = 1
			AND rbm.providerid is not null
			AND rbm.EndSeedDate = @EndSeedDate
			AND rbm.Client = @Client

IF ( @MeasureDesc IS NULL )
	INSERT INTO @MeasureTable
	SELECT DISTINCT MeasureDesc
		FROM CGF.ResultsByMember rbm
		WHERE IsDenominator = 1
			AND rbm.EndSeedDate = @EndSeedDate
			AND rbm.Client = @Client
ELSE 
	INSERT INTO @MeasureTable
	SELECT Name FROM [dbo].[fnSplit](@MeasureDesc,',')



	INSERT INTO cgf_rep.ReportVariableLog
	(RunDate ,
	ProcName ,
	Var1Name ,
	Var1Val ,
	Var2Name,
	Var2Val,
	Var3Name,
	Var3Val)
	--,
	--Var4Name,
	--Var4Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @Client,
	Var2Name = '@EndSeedDate',
	Var2Val = @EndSeedDate,
	Var3Name = '@ProviderId',
	Var3Val = @ProviderId
	--,
	--Var4Name = '@MeasureDesc',
	--Var4Val = @MeasureDesc

/*
	
	SELECT * FROM CGF_REP.ReportVariableLog WHERE ProcName = 'rptProviderPanelGapReport' order by rowid desc 


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
	Var1Val = @Client,
	Var2Name = '@EndSeedDate',
	Var2Val = @EndSeedDate,
	Var3Name = '@ProviderId',
	Var3Val = @ProviderId,
	Var4Name = '@MeasureDesc',
	Var4Val = @MeasureDesc
*/

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
		INNER JOIN @MeasureTable t
			--ON RIGHT(rbm.measuremetricdesc,LEN(rbm.MeasureMetricDesc)-4) = t.MeasureDesc
			ON cm.MeasureDesc = t.MeasureDesc
	WHERE rbm.IsDenominator = 1 
		AND mbr.Client = @Client
		and dr.EndSeedDate = @EndSeedDate
		AND p.ProviderID = @ProviderId
		AND rbm.measuremetricdesc <> 'TLM-Total Membership'
		AND rbm.IsNumerator = 0
	ORDER BY rbm.CustomerMemberID
	--ORDER BY mbr.NameLast + CASE WHEN mbr.NameFirst IS NOT NULL THEN ', ' + mbr.NameFirst ELSE '' END


/*


		exec [CGF_REP].[rptProviderPanelGapReport]
			@Client = 'CGFTest'
			, @endseeddate = '20141231'
			, @ProviderId = 9969807
			, @MeasureDesc = 'AAB-Avoidance of Antibiotic Therapy for Adults with Acute Bronchitis,AAP-Adults'' Access to Preventive/Ambulatory Health Services,ABA-Adult BMI Assessment'



*/
GO
