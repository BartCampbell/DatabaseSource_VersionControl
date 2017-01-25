SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************************************************
Procedure:	repHighCostMember
Author:		Leon Dowling
Copyright:	© 2014
Date:		2014.08.27
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

select top 10 * from repHighClaimCost

drop table repHighClaimCost

EXEC [repHighCostMember] 
	@ServiceStartDate  = NULL,
	@ServiceEndDate	   = NULL,
	@PaidStartDate     = NULL,
	@PaidEndDate       = NULL,
	@RepType           = 'LOB',
	@LOB			   = NULL,
	@PlaceOfService    = NULL,
	@TypeOfService     = NULL,
	@ServicingProvSpecialty = NULL,
	@VisitType		   = NULL

*/

--/*
CREATE PROC [dbo].[repHighCostMember]

@ServiceStartDate VARCHAR(8) = NULL,
@ServiceEndDate VARCHAR(8) = NULL,
@PaidStartDate VARCHAR(8) = NULL,
@PaidEndDate VARCHAR(8) = NULL,
@RepType VARCHAR(10) = NULL,
@LOB VARCHAR(50) = NULL,
@PlaceOfService VARCHAR(50) = NULL,
@TypeOfService VARCHAR(50) = NULL,
@ServicingProvSpecialty VARCHAR(100) = NULL,
@VisitType VARCHAR(20) = NULL

AS
--*/
/*-----------------------------------------------------
DECLARE @ServiceStartDate VARCHAR(8) = NULL
DECLARE	@ServiceEndDate VARCHAR(8) = NULL
DECLARE @PaidStartDate VARCHAR(8) = NULL
DECLARE @PaidEndDate VARCHAR(8) = null
DECLARE @RepType VARCHAR(10) = 'LOB'
DECLARE @LOB VARCHAR(50) = NULL
DECLARE @PlaceOfService VARCHAR(50) = NULL
DECLARE @TypeOfService VARCHAR(50) = NULL
DECLARE @ServicingProvSpecialty VARCHAR(100) = NULL
DECLARE @VisitType VARCHAR(20) = NULL
------------------------------------------------------*/

IF @ServiceEndDate IS NULL 
BEGIN
	SELECT @ServiceEndDate = CONVERT(VARCHAR(8),DATEADD(MONTH,-3,CONVERT(DATETIME,LEFT(CONVERT(VARCHAR(8),GETDATE(),112),6)+'01'))-1,112)
	SELECT @ServiceStartDate = CONVERT(VARCHAR(8),DATEADD(MONTH,-15,CONVERT(DATETIME,LEFT(CONVERT(VARCHAR(8),GETDATE(),112),6)+'01')),112)
END

IF @ServiceStartDate IS NULL 
	SELECT @ServiceStartDate = CONVERT(VARCHAR(8),DATEADD(MONTH,-11,CONVERT(DATETIME,LEFT(@ServiceEndDate,6)+'01')),112)

/*
high cost members - Members with any encounter (defined as the aggregation of claims with the same date of service and seq member ID) 
WITH a total net paid of $10,000 for MCD and $20,000 for all other LOBs (programs) 
OR Members with total claims cost of $50,000 and over (All LOBs) for a rolling 12 month period.  
*/

IF OBJECT_ID('repHighClaimCost') IS NOT NULL
	drop table repHighClaimCost

BEGIn

	BEGIN
		IF OBJECT_ID('tempdb..#EncounterOver10k') IS NOT NULL 
			DROP table #EncounterOver10k

		SELECT c.LineOfBusiness,
				c.MemberID,
				cli.DateServiceBegin,
				TotalAmountNetPayment = SUM(cli.AmountNetPayment)
			INTO #EncounterOver10k
			FROM dbo.ClaimLineItem cli
				INNER JOIN Claim c
					ON c.ClaimID = cli.ClaimID
			WHERE cli.SourceSystem = 'Xcelys'
				AND CONVERT(VARCHAR(8),cli.DateServiceBegin,112) BETWEEN @ServiceStartDate AND @ServiceEndDate
				AND CONVERT(VARCHAR(8),cli.DatePaid,112) >= ISNULL(@PaidStartDate,CONVERT(VARCHAR(8),cli.DatePaid,112))
				AND CONVERT(VARCHAR(8),cli.DatePaid,112) <= ISNULL(@PaidEndDate,CONVERT(VARCHAR(8),cli.DatePaid,112))
			GROUP BY c.LineOfBusiness, c.MemberID, cli.DateServiceBegin
			HAVING SUM(Cli.AmountNetPayment) >= 10000

		IF OBJECT_ID('tempdb..#TotalClaimsOver50K') IS NOT NULL 
			DROP TABLE #TotalClaimsOver50K

		SELECT c.MemberID,
				c.LineOfBusiness,
				TotalAmountNetPayment = SUM(cli.AmountNetPayment)
			INTO #TotalClaimsOver50K
			FROM dbo.ClaimLineItem cli
				INNER JOIN Claim c
					ON c.ClaimID = cli.ClaimID
			WHERE cli.SourceSystem = 'Xcelys'
				AND CONVERT(VARCHAR(8),cli.DateServiceBegin,112) BETWEEN @ServiceStartDate AND @ServiceEndDate
				AND CONVERT(VARCHAR(8),cli.DatePaid,112) >= ISNULL(@PaidStartDate,CONVERT(VARCHAR(8),cli.DatePaid,112))
				AND CONVERT(VARCHAR(8),cli.DatePaid,112) <= ISNULL(@PaidEndDate,CONVERT(VARCHAR(8),cli.DatePaid,112))
			GROUP BY c.MemberID,
				c.LineOfBusiness
			HAVING SUM(Cli.AmountNetPayment) >= 50000

		-- High Cost Members

		IF OBJECT_ID('tempdb..#HighCostMbr') IS NOT NULL 
			DROP TABLE #HighCostMbr

		SELECT MemberID,
				LineOfBusiness,
				Reason= 'MCD Member Encounter over $10K'
			INTO #HighCostMbr
			FROM #EncounterOver10k
			WHERE LineOfBusiness = 'MCD' 

		INSERT INTO #HighCostMbr
		SELECT a.MemberID,
				a.LineOfBusiness,
				Reason= 'Encounter over $20K'
			FROM #EncounterOver10k a
				LEFT JOIN #HighCostMbr hcm
					ON hcm.MemberID = a.MemberID
					AND hcm.LineOfBusiness = a.LineOfBusiness
			WHERE a.TotalAmountNetPayment >= 20000
				AND hcm.MemberID IS NULL 

		INSERT INTO #HighCostMbr
		SELECT a.MemberID,
				a.LineOfBusiness,
				Reason= 'Total Claims over $50K'
			FROM #TotalClaimsOver50K a
				LEFT JOIN #HighCostMbr hcm
					ON hcm.MemberID = a.MemberID
					AND hcm.LineOfBusiness = a.LineOfBusiness
			WHERE hcm.MemberID IS NULL 

	END
	-- Detail LIst

	IF OBJECT_ID('tempdb..#pos') IS NOT NULL 
		DROP TABLE #pos

	SELECT  PLACEOFSERVICE_CD,
			PLACEOFSERVICE_SHORT_DESC
		INTO #pos
		FROM IMICodeStore.dbo.OTHER_PlaceOfService

	IF OBJECT_ID('tempdb..#elig') is not null
		DROP TABLE #elig

	SELECT e.SourceSystem, 
			e.CustomerEligibilityID,
			LineOfBusiness = MAX(e.LineOfBusiness)
		INTO #elig
		FROM Eligibility e
			INNER JOIN #HighCostMbr hcm
				ON e.MemberID = HCM.MemberID
		GROUP BY e.SourceSystem, 
			e.CustomerEligibilityID

	create index fk ON #elig (SourceSystem, CustomerEligibilityID,LineOfBusiness)
	create statistics sp ON #elig (SourceSystem, CustomerEligibilityID,LineOfBusiness)
		
	
	SELECT 
			--RowID = IDENTITY(INT,1,1),
			ClaimLineItemID = CONVERT(INT,Cli.ClaimLineItemID),
			ClaimID = CONVERT(INT,cli.ClaimID),
			MemberID = CONVERT(INT,c.MemberID),
			cli.DateServiceBegin,
			cli.DatePaid,

			LOB= CASE WHEN ISNULL(xc.DHMPLineOfBusiness,'') <> '' THEN c.LineOfBusiness ELSE e.LineOfBusiness END,
			PlaceOfService = c.PlaceOfService,
			PlaceOfServiceDesc = ISNULL(pos.PLACEOFSERVICE_SHORT_DESC,'Undefined'),
			TypeOfService = CASE
								WHEN c.PlaceOfService in ('41', '42')
								THEN 'Ambulance Services'
								WHEN c.PlaceOfService = ('20')--20 urgent --23 ememgency
								THEN 'Urgent Care'
								WHEN c.PlaceOfService = ('23')--20 urgent --23 ememgency
								THEN 'Emergency'
								WHEN c.PlaceOfService = '65'
								THEN 'ESRD Services'
								WHEN c.PlaceOfService = '12'
								THEN 'Home Health'
								WHEN c.PlaceOfService = '34'
								THEN 'Hospice'
								WHEN c.PlaceOfService in ('21', '51', '55', '56', '61')
								THEN 'Inpatient Services'
								WHEN c.PlaceOfService in ('31', '32', '33')
								THEN 'Nursing Facilities'
								WHEN c.PlaceOfService in ('11', '22', '24', '26', '50', '53', '60', '62', '71', '72')
									OR c.PlaceOfService between '90' and '98'
								THEN 'Outpatient Services'
								ELSE 'Other Services'
								END,
			ServicingProvSpecialtyDesc = CASE WHEN ISNULL(c.ServicingProvSpecialtyDesc,'') <> '' THEN c.ServicingProvSpecialtyDesc ELSE 'Unknown Provider Specialty' END,
			VisitType = CASE WHEN c.ClaimType = 'I' THEN 'Institutional' ELSE 'Professional' END,
			HighCostMemberReason = hcm.Reason,
			C.DiagnosisCode1,
			d1d.diagnosis_1_short_category,
		
			Cli.AmountNetPayment,

			Param_ServiceStartDate = @ServiceStartDate ,
			Param_ServiceEndDate = @ServiceEndDate ,
			Param_PaidStartDate= @PaidStartDate ,
			Param_PaidENdDate = @PaidEndDate ,
			m.CustomerMemberID,
			FullName = m.NameLast + ', ' + m.NameFirst

		INTO repHighClaimCost
		FROM dbo.ClaimLineItem cli
			INNER JOIN claim c
				ON c.ClaimID = cli.ClaimID
			INNER JOIN brXref_Claim xc
				ON c.ClaimID = xc.ClaimID
			INNER JOIN Member M
				ON c.MemberID = m.MemberID
			INNER JOIN #highCostMbr hcm
				ON c.MemberID = hcm.MemberID
				AND c.LineOfBusiness = hcm.LineOfBusiness
			LEFT JOIN #pos pos
				ON c.PlaceOfService = pos.PLACEOFSERVICE_CD
			LEFT JOIN DHMP_IHDS_DW01.dbo.diagnosis_1_dim d1d
				ON c.DiagnosisCode1 = d1d.diagnosis_1_code
			LEFT JOIN #elig e
				ON c.SourceSystem = e.SourceSystem
				AND c.CustomerEligibilityID = e.CustomerEligibilityID
		WHERE CONVERT(VARCHAR(8),cli.DateServiceBegin,112) BETWEEN @ServiceStartDate AND @ServiceEndDate
			AND CONVERT(VARCHAR(8),cli.DatePaid,112) >= ISNULL(@PaidStartDate,CONVERT(VARCHAR(8),cli.DatePaid,112))
			AND CONVERT(VARCHAR(8),cli.DatePaid,112) <= ISNULL(@PaidEndDate,CONVERT(VARCHAR(8),cli.DatePaid,112))

END

IF @RepType = 'LOB'
	SELECT MemberID,
			LOB,
		
			AmountNetPayment = SUM(AmountNetPayment),
			Param_ServiceStartDate = MAX(Param_ServiceStartDate),
			Param_ServiceEndDate = MAX(Param_ServiceEndDate),
			Param_PaidStartDate = MAX(Param_PaidStartDate),
			Param_PaidENdDate = MAX(Param_PaidENdDate)
		FROM repHighClaimCost	
		GROUP BY MemberID,
			LOB
ELSE
IF @RepType = 'POS'
	SELECT MemberID,
			PlaceOfServiceDesc,
		
			AmountNetPayment = SUM(AmountNetPayment),
			Param_ServiceStartDate = MAX(Param_ServiceStartDate),
			Param_ServiceEndDate = MAX(Param_ServiceEndDate),
			Param_PaidStartDate = MAX(Param_PaidStartDate),
			Param_PaidENdDate = MAX(Param_PaidENdDate)
		FROM repHighClaimCost	
		GROUP BY MemberID,
			PlaceOfServiceDesc
ELSE
IF @RepType = 'TOS'
	SELECT MemberID,
			TypeOfService,
		
			AmountNetPayment = SUM(AmountNetPayment),
			Param_ServiceStartDate = MAX(Param_ServiceStartDate),
			Param_ServiceEndDate = MAX(Param_ServiceEndDate),
			Param_PaidStartDate = MAX(Param_PaidStartDate),
			Param_PaidENdDate = MAX(Param_PaidENdDate)
		FROM repHighClaimCost	
		GROUP BY MemberID,
			TypeOfService
ELSE
IF @RepType = 'ProvSpec'
	SELECT MemberID,
			ServicingProvSpecialtyDesc,
		
			AmountNetPayment = SUM(AmountNetPayment),
			Param_ServiceStartDate = MAX(Param_ServiceStartDate),
			Param_ServiceEndDate = MAX(Param_ServiceEndDate),
			Param_PaidStartDate = MAX(Param_PaidStartDate),
			Param_PaidENdDate = MAX(Param_PaidENdDate)
		FROM repHighClaimCost	
		GROUP BY MemberID,
			ServicingProvSpecialtyDesc
ELSE
IF @RepType = 'VisitType'
	SELECT MemberID,
			VisitType,

			AmountNetPayment = SUM(AmountNetPayment),
			Param_ServiceStartDate = MAX(Param_ServiceStartDate),
			Param_ServiceEndDate = MAX(Param_ServiceEndDate),
			Param_PaidStartDate = MAX(Param_PaidStartDate),
			Param_PaidENdDate = MAX(Param_PaidENdDate)
		FROM repHighClaimCost	
		GROUP BY MemberID,
			VisitType
ELSE
IF @RepType = 'Member'
	SELECT MemberID,
			LOB,
			PlaceOfServiceDesc,
			TypeOfService,
			ServicingProvSpecialtyDesc,
			VisitType,
			CustomerMemberID,
			FullName ,
			AmountNetPayment = SUM(AmountNetPayment),
			Param_ServiceStartDate = MAX(Param_ServiceStartDate),
			Param_ServiceEndDate = MAX(Param_ServiceEndDate),
			Param_PaidStartDate = MAX(Param_PaidStartDate),
			Param_PaidENdDate = MAX(Param_PaidENdDate)
		FROM repHighClaimCost 
		WHERE LOB = ISNULL(@LOB,LOB)
			ANd PlaceOfServiceDesc = ISNULL(@PlaceOfService,PlaceOfServiceDesc)
			ANd TypeOfService = ISNULL(@TypeOfService,TypeOfService)
			AND ServicingProvSpecialtyDesc = ISNULL(@ServicingProvSpecialty,ServicingProvSpecialtyDesc)
			AND VisitType = ISNULL(@VisitType,VisitType)
		GROUP BY MemberID,
			LOB,
			PlaceOfServiceDesc,
			TypeOfService,
			ServicingProvSpecialtyDesc,
			VisitType,
			CustomerMemberID,
			FullName

GO
GRANT VIEW DEFINITION ON  [dbo].[repHighCostMember] TO [db_ViewProcedures]
GO
