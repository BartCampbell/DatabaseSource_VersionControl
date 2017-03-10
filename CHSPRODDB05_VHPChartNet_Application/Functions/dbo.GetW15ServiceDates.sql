SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetW15ServiceDates]
(	
	@MemberID int
)
RETURNS TABLE 
AS
RETURN 
(
	WITH VisitReqs(Descr, SortOrder, HlthHistoryFlag, PhysHealthDevFlag, MentalHlthDevFlag, PhysExamFlag, HlthEducFlag) AS
	(
		SELECT	'Health History', 1, 1, 0, 0, 0, 0
		UNION
		SELECT	'Physical Developmental History', 2, 0, 1, 0, 0, 0
		UNION
		SELECT	'Mental Developmental History', 3, 0, 0, 1, 0, 0
		UNION
		SELECT	'Physical Exam', 4, 0, 0, 0, 1, 0
		UNION
		SELECT	'Health Education/Anticipatory Guidence', 5, 0, 0, 0, 0, 1
	),
	ServiceDates AS 
	(
	SELECT  R.Descr,
			R.SortOrder,
			ISNULL('' + 
						CONVERT(varchar(max), 
						(
							SELECT	COUNT(*)
							FROM	dbo.GetW15WellVisits(@MemberID) AS t
							WHERE	(t.PhysHealthDevFlag = 1 AND r.PhysHealthDevFlag = 1 OR r.PhysHealthDevFlag = 0) AND
									(t.MentalHlthDevFlag = 1 AND r.MentalHlthDevFlag = 1 OR r.MentalHlthDevFlag = 0) AND
									(t.PhysExamFlag = 1 AND r.PhysExamFlag = 1 OR r.PhysExamFlag = 0) AND
									(t.HlthEducFlag = 1 AND r.HlthEducFlag = 1 OR r.HlthEducFlag = 0) AND
									(t.HlthHistoryFlag = 1 AND r.HlthHistoryFlag = 1 OR r.HlthHistoryFlag = 0)
						)) + ' of ' + CONVERT(varchar(MAX), 6) + ' - ', '') +
            STUFF(
					(
							
						CONVERT(varchar(MAX), 
						(
							SELECT	', ' + dbo.ConvertDateToVarchar(t.ServiceDate) + ' (' + t.RecordType + ')' AS [text()]
							FROM	dbo.GetW15WellVisits(@MemberID) AS t
							WHERE	(t.PhysHealthDevFlag = 1 AND r.PhysHealthDevFlag = 1 OR r.PhysHealthDevFlag = 0) AND
									(t.MentalHlthDevFlag = 1 AND r.MentalHlthDevFlag = 1 OR r.MentalHlthDevFlag = 0) AND
									(t.PhysExamFlag = 1 AND r.PhysExamFlag = 1 OR r.PhysExamFlag = 0) AND
									(t.HlthEducFlag = 1 AND r.HlthEducFlag = 1 OR r.HlthEducFlag = 0) AND
									(t.HlthHistoryFlag = 1 AND r.HlthHistoryFlag = 1 OR r.HlthHistoryFlag = 0)
							ORDER BY t.ServiceDate
							FOR XML PATH('')
						))
					), 1, 2, '') AS ServiceDates
    FROM    dbo.Member AS MBR
			CROSS JOIN VisitReqs AS R
	WHERE	MBR.MemberID = @MemberID 
	)
	SELECT TOP 100 PERCENT * FROM ServiceDates WHERE ServiceDates IS NOT NULL ORDER BY 1, 2
)
GO
