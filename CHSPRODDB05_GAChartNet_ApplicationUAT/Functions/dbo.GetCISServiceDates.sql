SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetCISServiceDates]
(	
	@MemberID int
)
RETURNS TABLE 
AS
RETURN 
(
	WITH SourceTypeConversion(SourceType, Descr) AS 
	(
		SELECT 'MR', 'Medical Record'
		UNION ALL
		SELECT 'ADMIN', 'Administrative'
	),
	ServiceDates AS 
	(
	SELECT  MC.HEDISSubMetricComponentCode,
			MC.HEDISSubMetricComponentDesc,
			ISNULL('' + 
						CONVERT(varchar(max), 
						(
							SELECT	COUNT(*)
							FROM	dbo.GetCISImmunizations(@MemberID) AS IM
									INNER JOIN SourceTypeConversion AS t
											ON t.SourceType = IM.SourceType
							WHERE	IM.HEDISSubMetricComponentCode = MC.HEDISSubMetricComponentCode AND
									IM.HEDISSubMetricCode = MC.HEDISSubMetricCode
						)) + ' of ' + CONVERT(varchar(MAX), MC.QuantityNeeded) + ' - ', '') +
            STUFF(
					(
							
						CONVERT(varchar(MAX), 
						(
							SELECT	', ' + dbo.ConvertDateToVarchar(IM.ServiceDate) + ' (' + T.Descr + ')' AS [text()]
							FROM	dbo.GetCISImmunizations(@MemberID) AS IM
									INNER JOIN SourceTypeConversion AS t
											ON t.SourceType = IM.SourceType
							WHERE	IM.HEDISSubMetricComponentCode = MC.HEDISSubMetricComponentCode AND
									IM.HEDISSubMetricCode = MC.HEDISSubMetricCode
							ORDER BY IM.ServiceDate
							FOR XML PATH('')
						))
					), 1, 2, '') AS ServiceDates
    FROM    dbo.GetCISMetricComponents() AS MC 
	)
	SELECT TOP 100 PERCENT * FROM ServiceDates WHERE ServiceDates IS NOT NULL ORDER BY 1, 2
)
GO
