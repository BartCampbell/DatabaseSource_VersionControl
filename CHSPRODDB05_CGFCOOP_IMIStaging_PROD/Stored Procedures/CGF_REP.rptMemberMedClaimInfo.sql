SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	
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
- 7/18/2015 change diag link to imicodestore
Process:	
Test Script: 
				exec [CGF_REP].[rptMemberMedClaimInfo] 
					@ServiceDate	= '20141231'
					, @CustomerMemberID = '1864618204'
					, @IHDS_Member_ID = NULL 
					, @Mthsback = 12
					, @Client = 'Mcmed'

				exec [CGF_REP].[rptMemberMedClaimInfo] 
					@ServiceDate	= '20151231'
					, @CustomerMemberID = 'MCMED93795021A'
					, @IHDS_Member_ID = 314148
					, @Mthsback = 12
					, @Client = 'Mcmed'
 
				exec [CGF_REP].[rptMemberMedClaimInfo] 
					@ServiceDate	= '20151231'
					, @IHDS_Member_ID = null
					, @Mthsback = 12
					, @NameFirst = 'Todd'

ToDo:		

	SELECT * FROM cgf_rep.ReportVariableLog ORDER BY ROWID DESC 

*************************************************************************************/

--/*
CREATE	PROC [CGF_REP].[rptMemberMedClaimInfo] 
(
	@ServiceDate			datetime = NULL,
	@IHDS_Member_ID			int = null,
	@CustomerMemberID		varchar(100) = NULL, 
	@Mthsback				int = 12,
	@EDVisit				bit = NULL,
	@IPAdmit				bit = NULL,
	@OfficeVisit			bit = NULL,
	@Client					nvarchar(30) = NULL,
	@NameFirst				varchar(100) = NULL,
	@NameLast				varchar(100) = NULL
)
AS
--*/
/*-------------------------------------------------------------
DECLARE @ServiceDate DATETIME = '20141231'
DECLARE @IHDS_Member_ID INT = 261183
DECLARE @Mthsback INT =24
DECLARE @EDVisit BIT = 1
DECLARE @IPAdmit BIT = 0
DECLARE @OfficeVisit BIT  = 0

select * from cgf_rep.ReportVariableLog order by rowid desc

--*/-------------------------------------------------------------

INSERT INTO cgf_rep.ReportVariableLog
(
	RunDate ,
	ProcName ,
	Var1Name ,
	Var1Val ,
	Var2Name,
	Var2Val ,
	Var3Name ,
	Var3Val ,
	Var4Name ,
	Var4Val ,
	Var5Name ,
	Var5Val ,
	Var6Name ,
	Var6Val ,
	Var7Name ,
	Var7Val 
)
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@ServiceDate',
	Var1Val = @ServiceDate,
	Var2Name = '@IHDS_Member_ID',
	Var2Val = @IHDS_Member_ID,
	Var3Name = '@Mthsback',
	Var3Val = @Mthsback,
	Var4Name = '@IPAdmit',
	Var4Val = @IPAdmit,
	Var5Name = '@OfficeVisit',
	Var5Val = @OfficeVisit,
	Var6Name = '@NameFirst',
	Var6Val = @NameFirst,
	Var7Name = '@CustomerMemberID',
	Var7Val = @CustomerMemberID

IF @ServiceDate IS NULL 
	SET @ServiceDate = LEFT(CONVERT(VARCHAR(8),DATEADD(month,-3,GETDATE()),112),6)+'01'
ELSE
	SET @ServiceDate = LEFT(CONVERT(VARCHAR(8),@ServiceDate,112),6) + '01'

IF ISNULL(@NameFirst,'') = '' SET @NameFirst = NULL 
IF ISNULL(@NameLast,'') = '' SET @NameLast = NULL 

DECLARE @vcServiceBegin VARCHAR(8) = CONVERT(VARCHAR(8),DATEADD(MOnth,(-1*(@Mthsback-1)),@ServiceDate),112)
DECLARE @vcServiceEnd VARCHAR(8) = CONVERT(VARCHAR(8),DATEADD(MOnth,1,@ServiceDate)-1,112)

CREATE TABLE #MemberList (MemberID int)

IF (@IHDS_Member_ID IS NOT NULL) 
BEGIN 
	INSERT INTO #MemberList
	SELECT DISTINCT MemberID 
		FROM dbo.Member WHERE ihds_member_id = @IHDS_Member_ID
END 
ELSE 
BEGIN 
	IF (@CustomerMemberID IS NOT NULL) 
		INSERT INTO #MemberList
		SELECT DISTINCT MemberID 
			FROM dbo.Member 
			WHERE CustomerMemberID LIKE @CustomerMemberID + '%'
	ELSE 
		IF (@NameLast IS NOT NULL OR @NameLast IS NOT null)
		BEGIN 
			INSERT INTO #MemberList
			SELECT DISTINCT MemberID 
				FROM dbo.Member
				WHERE (client = @Client OR (@Client IS NULL AND client LIKE '%%'))
				AND (NameFirst = @NameFirst OR (@NameFirst IS NULL AND NameFirst LIKE '%%'))
				AND (NameLast = @NameLast OR (@NameLast IS NULL AND NameLast LIKE '%%'))
		END 
END 


SELECT m.CustomerMemberID,
		FullName = LTRIM(RTRIM(m.NameLast)) + CASE WHEN m.NameFirst IS NOT NULL THEN ', ' + LTRIM(RTRIM(m.NameFirst)) ELSE '' END,
		--c.CustomerClaimID,
		CustomerClaimID = c.CustomerClaimID, 
			--CASE 
			--	WHEN (@Client = 'CovCal') THEN c.PayerClaimID
			--	ELSE SUBSTRING(c.PayerClaimID,14,LEN(c.PayerClaimID))
			--END,
		c.DateServiceBegin,
		p.CustomerProviderID,
		p.ProviderFullName,
		c.DiagnosisCode1,
		ShortDescription = diag.ICD9_DIAG_CD_DESC,
		c.PlaceOfService,
		ClaimType = CASE WHEN c.ClaimType= 'I' THEN 'Institutional' ELSE 'Professional' END,
		cli.AmountNetPayment,
		cli.ServiceCount,
		cli.IPAdmit,
		cli.IPDays,
		cli.EDVisit,
		cli.OfficeVisits
		
	FROM claim c
		INNER JOIN member m
			ON m.MemberID = c.MemberID
		INNER JOIN #MemberList ml
			ON ml.MemberID = m.MemberID
		INNER JOIN (SELECT cli.ClaimID,
							AmountNetPayment = SUM(cli.AmountNetPayment),
							ServiceCount= COUNT(*),
							OfficeVisits = SUM(xrf.OfficeVisit),
							IPAdmit = SUM(xrf.IPAdmit),
							IPDays = SUM(Xrf.IPDays),
							EDVisit = SUM(xrf.EDVisit)
						FROM dbo.ClaimLineItem cli
							INNER JOIN claim c 
								ON c.ClaimID = cli.ClaimID
								AND CONVERT(VARCHAR(8),c.DateServiceBegin,112) BETWEEN @vcServiceBegin AND @vcServiceEnd
							INNER JOIN dbo.BrXref_ClaimLineItem xrf
								ON xrf.ClaimLineItemID = cli.ClaimLineItemID
							INNER JOIN #MemberList ml
								ON ml.MemberID = c.MemberID
						WHERE 1 = CASE WHEN ISNULL(@IPAdmit,0) = 0 THEN 1
										WHEN xrf.IPAdmit = 1 THEN 1
										ELSE 0 END
								AND 1 = CASE WHEN ISNULL(@EDVisit,0) = 0 THEN 1
										WHEN xrf.EDVisit = 1 THEN 1
										ELSE 0 END
								AND 1 = CASE WHEN ISNULL(@OfficeVisit,0) = 0 THEN 1
										WHEN xrf.OfficeVisit = 1 THEN 1
										ELSE 0 END
						GROUP BY cli.ClaimID) cli
			ON c.ClaimID = cli.ClaimID
		LEFT JOIN 	IMICodeStore.dbo.CCS_Diag_ICD9 diag
			ON REPLACE(c.DiagnosisCode1,'.','') = diag.ICD9_DIAG_CD
		left JOIN dbo.Provider p
			--ON c.ServicingProviderID = p.ProviderID
			ON c.ihds_prov_id_servicing = p.ihds_prov_id

	WHERE CONVERT(VARCHAR(8),c.DateServiceBegin,112) BETWEEN @vcServiceBegin AND @vcServiceEnd
		AND (m.client = @Client OR (@Client IS NULL AND m.client LIKE '%%'))
		AND (m.NameFirst = @NameFirst OR (@NameFirst IS NULL AND m.NameFirst LIKE '%%'))
		AND (m.NameLast = @NameLast OR (@NameLast IS NULL AND m.NameLast LIKE '%%'))
	ORDER BY c.DateServiceBegin DESC 





GO
