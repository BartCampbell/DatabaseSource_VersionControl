SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	rptMemberInfo
Author:		Leon Dowling
Copyright:	© 2013
Date:		2013.01.01
Purpose:	
Parameters:	
Depends On:	
Calls:		
Called By:	
Returns:	
Notes:		
Process:	
Test Script:	exec [rptMemberInfo] 
					@ServiceDate = '20121201',
					@IHDS_Member_ID = 371295

327011
321395
223359
230938
202127
277748
923970
920534
923792
919791

ToDo:		
*************************************************************************************/
--/*
CREATE PROC [dbo].[rptMemberInfo] 

@ServiceDate DATETIME = '20121201',
@IHDS_Member_ID INT ,
@RepID INT = 1

AS
--*/
/*-------------------------------------------------------------
DECLARE @ServiceDate DATETIME = '20131201'
DECLARE @IHDS_Member_ID INT = 226538
DECLARE @RepID INT = 1
--*/-------------------------------------------------------------


IF @ServiceDate IS NULL 
	SET @ServiceDate = LEFT(CONVERT(VARCHAR(8),DATEADD(month,-3,GETDATE()),112),6)+'01'
ELSE
	SET @ServiceDate = LEFT(CONVERT(VARCHAR(8),@ServiceDate,112),6) + '01'

DECLARE @vcMMStart VARCHAR(8) = CONVERT(VARCHAR(8),DATEADD(MOnth,-11,@ServiceDate),112)
DECLARE @vcMMEnd   VARCHAR(8) = CONVERT(VARCHAR(8),@ServiceDate,112)
DECLARE @vcMMCurrent VARCHAR(8) = LEFT(CONVERT(VARCHAR(8),DATEADD(month,-1,GETDATE()),112),6)+'01'

DECLARE @vcServiceBegin VARCHAR(8) = CONVERT(VARCHAR(8),DATEADD(MOnth,-11,@ServiceDate),112)
DECLARE @vcServiceEnd VARCHAR(8) = CONVERT(VARCHAR(8),DATEADD(MOnth,1,@ServiceDate)-1,112)


--IF @RepID = 1
SELECT  ParamServicedate = @ServiceDate ,
		ParamIHDSMemberID = @IHDS_Member_ID,

		MbrInfo.ihds_member_id,
		FullName = RTRIM(NameLast) + CASE WHEN ISNULL(MbrInfo.NameFirst,'') <> '' THEN ', ' + MbrInfo.NameFirst ELSE '' END,
		MbrInfo.NameLast,
		MbrInfo.NameFirst,
		MbrInfo.DateOfBirth,
		MbrInfo.Gender,
		MbrInfo.Address1,
		MbrInfo.Address2,
		MbrInfo.City,
		MbrInfo.State,
		MbrInfo.ZipCode,
		MbrInfo.PhoneHome,
		MbrInfo.PhoneMobile,
		MbrInfo.PhoneWork,
		PCPName = MbrInfo.PCPName,
		MbrInfo.member_month_first,
		Ed_visit = ISNULL(MedClm.Edvisit,0),
		IP_Admit = ISNULL(MedClm.IPAdmit,0),
		IP_Days = ISNULL(MedClm.IPDays,0),
		ALOS = ISNULL(MedClm.ALOS,0.0),
		Office_visits = ISNULL(MedClm.OfficeVisit,0),
		ClaimCount = ISNULL(MedClm.ClaimCount,0),
		TotalScripts = ISNULL(RxClm.TotalScripts,0),
		LastOfficeVisit = MedClm.LastOfficeVisit,
		LastEDVisit = MedClm.LastEDVisit,
		LastIPAdmit = MedClm.LastIPAdmit,
		MaxClaimTotalNetPayment = MaxClmAmt.MaxClaimTotalNetPayment
		--TotalGaps = ISNULL(CGF.TotalGaps,0),
		--Mara.ConcurrentRisk,
		--Mara.ProspectiveRisk,
		--Mara.InPatientProspectiveRisk 
	FROM (
			SELECT m.MemberID,
				m.ihds_member_id,
				m.NameLast,
				m.NameFirst,
				m.DateOfBirth,
				m.Gender,
				m.Address1,
				m.Address2,
				m.City,
				m.State,
				m.ZipCode,
				m.PhoneHome,
				m.PhoneMobile,
				m.PhoneWork,
				pcp.PCPName,
				mm.member_month_first
			FROM Member m
				LEFT JOIN (SELECT mmf.MemberID,
								member_month_first = SUM(mmf.member_month_first),
								MaxCharDate = MAX(mmf.MonthDate)
							FROM dbo.Brxref_MemberMonth mmf
							WHERE MonthDate BETWEEN @vcMMStart AND @vcMMEnd
							GROUP BY mmf.MemberID
							) mm
					ON m.MemberID = mm.MemberID
				LEFT JOIN (	SELECT mp.MemberID,
									mp.ProviderID,
									PCPName = RTRIM(p.NameLast) + CASE WHEN ISNULL(p.NameFirst,'') <> '' THEN ', ' + p.NameFirst ELSE '' END
								FROM dbo.MemberProvider mp
									INNER JOIN (SELECT mp.MemberID, MaxDateEffective= MAX(DateEffective)
													FROM dbo.MemberProvider mp
														INNER JOIN dbo.fnDateTable(@vcServiceBegin,@vcServiceEnd,'Month') d
															ON CONVERT(VARCHAR(8),d.Date,112) BETWEEN CONVERT(VARCHAR(8),mp.DateEffective,112) AND ISNULL(CONVERT(VARCHAR(8),mp.DateTerminated,112),'20981231')
													GROUP BY mp.MemberID
												) maxprov
										ON mp.MemberID = MaxProv.MemberID
										AND mp.DateEffective = MaxProv.MaxDateEffective
									INNER JOIN dbo.Provider p
										ON mp.ProviderID = p.ProviderID
							) pcp
					ON m.MemberID = pcp.MemberID
			WHERE m.ihds_member_id = @IHDS_Member_ID
		) MbrInfo
		LEFT JOIN (SELECT c.MemberID,
						EdVisit = SUM(xref_cli.EDVisit),
						IPAdmit = SUM(xref_cli.IPAdmit),
						IPDays = SUM(xref_cli.IPDays),
						ALOS = SUM(xref_cli.IPDays)/SUM(xref_cli.IPAdmit),
						OfficeVisit = SUM(xref_cli.OfficeVisits),
						ClaimCount = COUNT(DISTINCT cli.ClaimID),
						LastOfficeVisit = MAX(CASE WHEN xref_cli.OfficeVisits = 1 THEN cli.DateServiceBegin END),
						LastEDVisit = MAX(CASE WHEN xref_cli.EDVisit = 1 THEN cli.DateServiceBegin END),
						LastIPAdmit = MAX(CASE WHEN xref_cli.IPAdmit = 1 THEN c.DateAdmitted END),
						TotalPaidAmt = SUM(cli.AmountNetPayment)
					FROM dbo.ClaimLineItem cli
						INNER JOIN dbo.BrXref_ClaimLineItem xref_cli
							ON xref_cli.ClaimLineItemID = cli.ClaimLineItemID
						INNER JOIN Claim c
							ON c.ClaimID = cli.ClaimID
					WHERE CONVERT(VARCHAR(8),cli.DateServiceBegin,112) BETWEEN @vcServiceBegin AND @vcServiceEnd
					GROUP BY c.MemberID
				) MedClm
			ON MbrInfo.MemberID = MedClm.MemberID
		LEFT JOIN (SELECT MemberId,
						MaxClaimTotalNetPayment = MAX(ClaimTotalNetPayment)
						FROM (SELECT c.MemberID, 
								cli.ClaimID,
								ClaimTotalNetPayment = SUM(cli.AmountNetPayment)
								FROM dbo.ClaimLineItem cli
									INNER JOIN Claim c
										ON c.ClaimID = cli.ClaimID
								WHERE CONVERT(VARCHAR(8),cli.DateServiceBegin,112) BETWEEN @vcServiceBegin AND @vcServiceEnd
								GROUP BY c.MemberID, 
									cli.ClaimID
							) a
						GROUP BY a.MemberID
						) MaxClmAmt
			ON mbrinfo.MemberID = MaxClmAmt.MemberID
		LEFT JOIN (SELECT pc.MemberID,
						TotalScripts = COUNT(*)
					FROM PharmacyClaim pc
					WHERE CONVERT(VARCHAR(8),DateDispensed,112) BETWEEN @vcServiceBegin AND @vcServiceEnd
					GROUP BY pc.MemberID
					) RxClm
			ON MbrInfo.MemberID = RxClm.MemberID
	--LEFT JOIN (SELECT 
	--				cf.member_key,
	--				TotalGaps = SUM(cf.IsDenominator) - SUM(cf.IsNumerator)
	--			FROM STFRAN_IHDS_DW01.dbo.CGF_Fact cf
	--				INNER JOIN STFRAN_IHDS_DW01.dbo.member_dim md
	--					ON cf.member_key = md.member_key
	--					AND md.ihds_member_id = @IHDS_Member_ID
	--				INNER JOIN STFRAN_IHDS_DW01.dbo.cgf_header_dim ch
	--					ON cf.CGF_header_key = ch.CGF_header_key
	--				INNER JOIN STFRAN_IHDS_DW01.dbo.client_dim cd 
	--					ON cf.client_key = cd.client_key
	--				INNER JOIN STFRAN_IHDS_DW01.dbo.service_date_dim sdd
	--					ON cf.service_date_key = sdd.service_date_key
	--					AND sdd.service_char_full_date = @vcCGFEndDate
	--			GROUP BY cf.member_key
	--		) CGF
	--	ON MbrInfo.Member_key = CGF.Member_key
	--LEFT JOIN (SELECT mmf.Member_key,
	--				ConcurrentRisk = AVG(mmf.ConcurrentTotalScore),
	--				ProspectiveRisk = AVG(mmf.ProspectiveTotalScore),
	--				InPatientProspectiveRisk = AVG(mmf.ProspectiveIPScore)
	--			FROM dbo.mara_month_fact mmf
	--				INNER JOIN member_dim md
	--					ON mmf.member_key = md.member_key
	--					AND md.ihds_member_id = @IHDS_Member_ID
	--				INNER JOIN dbo.service_date_dim sdd
	--					ON mmf.service_date_key = sdd.service_date_key
	--					AND sdd.service_char_full_date = @vcMMEnd
	--			GROUP BY mmf.Member_key
	--		) Mara
	--	ON MbrInfo.Member_key = Mara.Member_key

/*
IF @RepID = 2
	SELECT	TOP 5 cuf.Member_key,
			EDVisitDate = sdd.service_date_full_date,
			d1d.diagnosis_1_desc,
			d1d.diagnosis_1_code
		FROM dbo.claim_utilization_fact cuf
			INNER JOIN member_dim md
				ON cuf.member_key = md.member_key
				AND md.ihds_member_id = @IHDS_Member_ID
			INNER JOIN dbo.service_date_dim sdd
				ON cuf.service_date_key = sdd.service_date_key
				AND sdd.service_char_full_date BETWEEN @vcServiceBegin AND @vcServiceEnd
			INNER JOIN dbo.diagnosis_1_dim d1d
				ON cuf.diagnosis_1_key = d1d.diagnosis_1_key
		WHERE cuf.ED_Visit = 1
		GROUP BY cuf.Member_key,
			sdd.service_date_full_date,
			d1d.diagnosis_1_desc,
			d1d.diagnosis_1_code
		ORDER BY sdd.service_date_full_date DESC
    

IF @RepID = 3
	SELECT	TOP 5 
			cuf.Member_key,
			IPAdmitDate = sdd.service_date_full_date,
			d1d.diagnosis_1_desc,
			d1d.diagnosis_1_code,
			IPDays = SUM(IP_Days)
		FROM dbo.claim_utilization_fact cuf
			INNER JOIN member_dim md
				ON cuf.member_key = md.member_key
				AND md.ihds_member_id = @IHDS_Member_ID
			INNER JOIN dbo.service_date_dim sdd
				ON cuf.service_date_key = sdd.service_date_key
				AND sdd.service_char_full_date BETWEEN @vcServiceBegin AND @vcServiceEnd
			INNER JOIN dbo.diagnosis_1_dim d1d
				ON cuf.diagnosis_1_key = d1d.diagnosis_1_key
		WHERE cuf.IP_Admit = 1
		GROUP BY cuf.Member_key,
			sdd.service_date_full_date,
			d1d.diagnosis_1_desc,
			d1d.diagnosis_1_code
		ORDER BY sdd.service_date_full_date DESC


IF @RepID = 4
	SELECT	TOP 5 
			cuf.Member_key,
			OfficeVisitDate = sdd.service_date_full_date,
			d1d.diagnosis_1_desc,
			d1d.diagnosis_1_code
		FROM dbo.claim_utilization_fact cuf
			INNER JOIN member_dim md
				ON cuf.member_key = md.member_key
				AND md.ihds_member_id = @IHDS_Member_ID
			INNER JOIN dbo.service_date_dim sdd
				ON cuf.service_date_key = sdd.service_date_key
				AND sdd.service_char_full_date BETWEEN @vcServiceBegin AND @vcServiceEnd
			INNER JOIN dbo.diagnosis_1_dim d1d
				ON cuf.diagnosis_1_key = d1d.diagnosis_1_key
		WHERE cuf.Office_Visit = 1
		GROUP BY cuf.Member_key,
			sdd.service_date_full_date,
			d1d.diagnosis_1_desc,
			d1d.diagnosis_1_code
		ORDER BY sdd.service_date_full_date DESC

*/
GO
GRANT VIEW DEFINITION ON  [dbo].[rptMemberInfo] TO [db_ViewProcedures]
GO
