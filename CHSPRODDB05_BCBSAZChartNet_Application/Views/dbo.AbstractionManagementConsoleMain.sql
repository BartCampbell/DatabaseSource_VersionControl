SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[AbstractionManagementConsoleMain]
AS
SELECT	M.HEDISMeasure AS PursuitEventDestination,
		M.HEDISMeasure,
		M.HEDISMeasure + ' - ' + M.HEDISMeasureDescription AS HEDISMeasureDescription,
		COUNT(PE.PursuitEventID) AS Pursuits,
		Abstraction_Ready = SUM(CASE WHEN PE.AbstractionStatusID IN (1) THEN 1
									 ELSE 0
								END),
		Abstraction_Pending = SUM(CASE WHEN PE.AbstractionStatusID IN (10)
									   THEN 1
									   ELSE 0
								  END),
		Abstraction_NoLongerNeeded = SUM(CASE WHEN PE.AbstractionStatusID IN (
												   25) THEN 1
											  ELSE 0
										 END),
		Abstraction_Complete = SUM(CASE	WHEN PE.AbstractionStatusID IN (20)
										THEN 1
										ELSE 0
								   END),
		Abstraction_Other = SUM(CASE WHEN PE.AbstractionStatusID IN (1, 10, 20,
															  25) THEN 0
									 ELSE 1
								END),
		Abstraction_Reviewed = SUM(CASE	WHEN P.ReviewerID IS NOT NULL THEN 1
										ELSE 0
								   END),
		Abstraction_Assigned = SUM(CASE	WHEN P.AbstractorID IS NOT NULL THEN 1
										ELSE 0
								   END),
		Abstraction_NotAssigned = SUM(CASE WHEN P.AbstractorID IS NULL THEN 1
										   ELSE 0
									  END),
		Abstraction_Scanned = SUM(CASE WHEN RVCI.PursuitEventChartImageID IS NOT NULL
									   THEN 1
									   ELSE 0
								  END),
		Abstraction_NotScanned = SUM(CASE WHEN RVCI.PursuitEventChartImageID IS NULL
										  THEN 1
										  ELSE 0
									 END),
		Abstraction_Found = SUM(CASE WHEN PE.ChartStatusValueID IN (1) THEN 1
									 ELSE 0
								END),
		Abstraction_NotFound = SUM(CASE	WHEN PE.ChartStatusValueID IN (1)
										THEN 0
										ELSE 1
								   END)
FROM	dbo.PursuitEvent AS PE
		OUTER APPLY (
					 SELECT TOP 1
							*
					 FROM	dbo.PursuitEventChartImage AS tRVCI
					 WHERE	tRVCI.PursuitEventID = PE.PursuitEventID
					 ORDER BY PursuitEventChartImageID
					) AS RVCI
		INNER JOIN dbo.Measure AS M
			ON PE.MeasureID = M.MeasureID
		INNER JOIN dbo.Pursuit AS P
			ON P.PursuitID = PE.PursuitID
GROUP BY M.HEDISMeasure,
		M.HEDISMeasureDescription;



GO
