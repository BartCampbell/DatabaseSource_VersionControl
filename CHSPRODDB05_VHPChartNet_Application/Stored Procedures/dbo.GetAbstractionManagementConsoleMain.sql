SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetAbstractionManagementConsoleMain]
(
 @AbstractorID int = NULL,
 @ReviewerID int = NULL,
 @AppointmentID int = NULL,
 @ProviderSiteID int = NULL,
 @ProviderID int = NULL,
 @ProductLine varchar(20) = NULL,
 @Product varchar(20) = NULL
)
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
FROM	dbo.PursuitEvent AS PE WITH (NOLOCK)
		INNER JOIN dbo.Measure AS M WITH (NOLOCK)
										 ON PE.MeasureID = M.MeasureID
		INNER JOIN dbo.Pursuit AS P WITH (NOLOCK)
										 ON PE.PursuitID = P.PursuitID
		INNER JOIN dbo.ProviderSite AS PS WITH (NOLOCK)
											   ON P.ProviderSiteID = PS.ProviderSiteID
		INNER JOIN dbo.Providers AS Prov WITH (NOLOCK)
											  ON P.ProviderID = Prov.ProviderID
		INNER JOIN dbo.Member AS MBR WITH (NOLOCK)
										  ON P.MemberID = MBR.MemberID
		OUTER APPLY (
					 SELECT TOP 1
							*
					 FROM	dbo.PursuitEventChartImage AS tRVCI
					 WHERE	tRVCI.PursuitEventID = PE.PursuitEventID
					 ORDER BY PursuitEventChartImageID
					) AS RVCI
WHERE	(@AbstractorID IS NULL OR
		 P.AbstractorID = @AbstractorID) AND
		(@ReviewerID IS NULL OR
		 P.ReviewerID = @ReviewerID) AND
		(@AppointmentID IS NULL OR
		 P.AppointmentID = @AppointmentID) AND
		(@ProviderSiteID IS NULL OR
		 PS.ProviderSiteID = @ProviderSiteID) AND
		(@ProviderID IS NULL OR
		 Prov.ProviderID = @ProviderID) AND
		 (@ProductLine IS NULL OR
		 MBR.ProductLine = @ProductLine) AND
		 (@Product IS NULL OR
		 MBR.Product = @Product)
GROUP BY M.HEDISMeasure,
		M.HEDISMeasureDescription
ORDER BY M.HEDISMeasureDescription

GO
