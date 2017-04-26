SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get HEDIS Summary for Export
-- =============================================
/* Sample Executions
hs_getSummary
*/
CREATE PROCEDURE [dbo].[hs_getSummary]
AS
BEGIN
	SELECT COUNT(DISTINCT suspect_pk) Members,YEAR(dt_insert) HYear,MONTH(dt_insert) HMonth FROM tblHEDIS_feedback 
	GROUP BY YEAR(dt_insert),MONTH(dt_insert)
	ORDER BY YEAR(dt_insert),MONTH(dt_insert)

	--Provider Overall Summary
	SELECT TOP 10 P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname,Round(CAST(SUM(CASE WHEN FD.is_confirmed=1 THEN 1 ELSE 0 END) AS Float)/CAST(COUNT(*) AS FLOAT),2) Score,COUNT(DISTINCT S.Suspect_PK) Members,MAX(MMM.MembershipTotal) MembershipTotal
		FROM tblProvider P
		INNER JOIN tblSuspect S ON S.Provider_PK=P.Provider_PK
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		CROSS APPLY (SELECT T.feedback_pk FROM tblHEDIS_feedback T WHERE T.suspect_pk=S.suspect_pk) F
		CROSS APPLY (SELECT COUNT(*) MembershipTotal FROM tblSuspect MM WHERE MM.Provider_PK=P.Provider_PK) MMM
		INNER JOIN tblHEDIS_feedback_detail FD ON FD.feedback_pk = F.feedback_pk
	GROUP BY P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname
	ORDER BY Score
	
	SELECT COUNT(*) Total FROM tblSuspect
END



GO
