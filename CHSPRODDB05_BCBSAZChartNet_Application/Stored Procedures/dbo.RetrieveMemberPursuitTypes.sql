SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RetrieveMemberPursuitTypes] @MemberID int
AS 
WITH    Results
          AS (SELECT    MS.HEDISMeasure,
                        MS.HEDISMeasureDescription,
                        PROV.NameLast,
                        PROV.NameFirst,
						PS.ProviderSiteID,
						PS.CustomerProviderSiteID,
                        PS.ProviderSiteName,
                        PE.PursuitEventID,
                        P.PursuitID,
                        ROW_NUMBER() OVER (PARTITION BY MS.MeasureID ORDER BY PriorityOrder, P.PursuitID, PursuitEventID) AS PriorityOrder,
                        'Measure: ' + CHAR(13) + CHAR(10) + MS.HedisMeasure +
                        CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                        'Event Date: ' + CHAR(13) + CHAR(10) +
                        ISNULL(CONVERT(varchar(512), PE.EventDate, 101), 'N/A') +
                        CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                        'Provider: ' + CHAR(13) + CHAR(10) +
                        LTRIM(RTRIM(PROV.CustomerProviderID)) + ' - ' +
                        LTRIM(RTRIM(PROV.NameEntityFullName)) + CHAR(13) +
                        CHAR(10) + CHAR(13) + CHAR(10) + 'Site: ' + CHAR(13) +
                        CHAR(10) +
                        ISNULL(LTRIM(RTRIM(PS.CustomerProviderSiteID)) + ' - ',
                               '') + LTRIM(RTRIM(PS.ProviderSiteName)) +
                        CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                        RTRIM(PS.Address1) + CHAR(13) + CHAR(10) +
                        ISNULL(NULLIF(RTRIM(PS.Address2), '') + CHAR(13) +
                               CHAR(10), '') + ISNULL(RTRIM(PS.City) + ', ' +
                                                      RTRIM(PS.[State]) + '  ' +
                                                      RTRIM(PS.Zip), '') AS Tooltip
              FROM      dbo.Measure MS
                        JOIN dbo.PursuitEvent PE ON MS.MeasureID = PE.MeasureID
                        JOIN dbo.Pursuit P ON PE.PursuitID = P.PursuitID
                        JOIN dbo.Providers PROV ON P.ProviderID = PROV.ProviderID
                        JOIN dbo.ProviderSite PS ON P.ProviderSiteID = PS.ProviderSiteID
              WHERE     P.MemberID = @MemberID
             ),
        MeasureCount
          AS (SELECT    HEDISMeasure,
                        COUNT(*) AS CountPursuits
              FROM      Results AS t
              GROUP BY  HEDISMeasure
             )
    SELECT  t.*,
            CONVERT(bit, CASE WHEN MC.CountPursuits > 1 THEN 1
                              ELSE 0
                         END) AS IsMulti
    FROM    Results AS t
            INNER JOIN MeasureCount AS MC ON t.HEDISMeasure = MC.HEDISMeasure



GO
