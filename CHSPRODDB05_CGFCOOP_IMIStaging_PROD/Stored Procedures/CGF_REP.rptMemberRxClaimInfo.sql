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

Process:	
Test Script: 

	exec [CGF_REP].[rptMemberRxClaimInfo] 
			@ServiceDate = '20151231'
			, @IHDS_Member_ID = null -- 314148 
			, @NameFirst='HELENA'
			, @CustomerMemberID = 'MCMED93795021A'
			, @CustomerMemberID = 'MCCOM30100109978'
 
ToDo:	

SELECT 
	TOP 10 pc.Memberid ,pc.DateDispensed, pc.CustomerMemberID, * 
	FROM dbo.PharmacyClaim pc
		INNER JOIN member m
			ON m.MemberID = pc.MemberID
	WHERE CONVERT(VARCHAR(8),pc.DateDispensed,112) BETWEEN '20150101' AND '20151231'

	select CONVERT(VARCHAR(8),getdate(),112) 

	MCCOM30100813152|01


SELECT ihds_member_id 
	FROM dbo.Member
	WHERE memberid = 8830823


select distinct right(CustomerMemberID,2) from member


*************************************************************************************/
--/*
CREATE PROC [CGF_REP].[rptMemberRxClaimInfo] 
(
	@ServiceDate		datetime = NULL,
	@IHDS_Member_ID		int	= NULL,
	@CustomerMemberID	varchar(100) = NULL, 
	@Mthsback			int = 12,
	@Client				nvarchar(30) = NULL,
	@NameFirst			varchar(100) = NULL,
	@NameLast			varchar(100) = NULL
)

AS
--*/
/*-------------------------------------------------------------
DECLARE @ServiceDate DATETIME = '20141231'
DECLARE @IHDS_Member_ID INT = 261183
DECLARE @Mthsback INT =12

--*/-------------------------------------------------------------


IF @ServiceDate IS NULL 
	SET @ServiceDate = LEFT(CONVERT(VARCHAR(8),DATEADD(month,-3,GETDATE()),112),6)+'01'
ELSE
	SET @ServiceDate = LEFT(CONVERT(VARCHAR(8),@ServiceDate,112),6) + '01'

DECLARE @vcServiceBegin VARCHAR(8) = CONVERT(VARCHAR(8),DATEADD(MOnth,(-1*(@Mthsback-1)),@ServiceDate),112)
DECLARE @vcServiceEnd VARCHAR(8) = CONVERT(VARCHAR(8),DATEADD(MOnth,1,@ServiceDate)-1,112)

IF ISNULL(@NameFirst,'') = '' SET @NameFirst = NULL 
IF ISNULL(@NameLast,'') = '' SET @NameLast = NULL 

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

SELECT ParamServiceDate = @ServiceDate,
		ParamIHDS_Member_ID = @IHDS_Member_ID,
		ParamMthsBack = @Mthsback,
		m.CustomerMemberID,
		FullName = LTRIM(RTRIM(m.NameLast)) + CASE WHEN m.NameFirst IS NOT NULL THEN ', ' + LTRIM(RTRIM(m.NameFirst)) ELSE '' END,
		pc.DateDispensed,
		pc.ClaimNumber,
		DrugName = RTRIM(pc.DrugName),
		pc.NDC,
		pc.DaysSupply,
		pc.Quantity,
		pc.RefillNumber
		--, m.ihds_member_id
		--, m.NameFirst, m.NameLast
	FROM dbo.PharmacyClaim pc
		INNER JOIN member m
			ON m.MemberID = pc.MemberID
		INNER JOIN #MemberList ml
			ON ml.MemberID = m.MemberID
	WHERE CONVERT(VARCHAR(8),pc.DateDispensed,112) BETWEEN @vcServiceBegin AND @vcServiceEnd
	AND (m.client = @Client OR (@Client IS NULL AND m.client LIKE '%%'))
		--AND (m.NameFirst = @NameFirst OR (@NameFirst IS NULL AND m.NameFirst LIKE '%%'))
		--AND (m.NameLast = @NameLast OR (@NameLast IS NULL AND m.NameLast LIKE '%%'))
	ORDER BY pc.DateDispensed desc


GO
