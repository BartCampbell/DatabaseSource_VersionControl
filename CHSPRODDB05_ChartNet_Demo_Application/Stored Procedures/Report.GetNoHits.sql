SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Report].[GetNoHits]
(
 @ProductLine varchar(20) = NULL,
 @Product varchar(20) = NULL,
 @MeasureID int = NULL,
 @AbstractionStatusID int = NULL,
 @ChartStatusValueID int = NULL,
 @AbstractionComplete bit = 0,
 @AbstractorID int = NULL,
 @AbstractionDateStart datetime = NULL,
 @AbstractionDateEnd datetime = NULL,
 @MemberID int = NULL,
 @MemberName varchar(100) = NULL,
 @ProviderNPI char(10) = NULL,
 @ProviderTIN varchar(11) = NULL,
 @ChartAttached bit = 0,
 @ProviderSiteID int = NULL,
 @ProviderSiteName varchar(75) = NULL,
 @ProviderID int = NULL,
 @ProviderName varchar(25) = NULL,
 @ChartStatusDetailID int = NULL,
 @ProviderSiteNameID int = NULL,
 @ProviderNameID int = NULL
)
AS
BEGIN

    SET NOCOUNT ON

    SET @ProviderSiteName = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteName,
                                                              '*', '%'), '?',
                                                           '_'), '%%%', '%'),
                                           '%%', '%'), '%');
    SET @ProviderName = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderName,
                                                              '*', '%'), '?',
                                                       '_'), '%%%', '%'), '%%',
                                       '%'), '%');

	-- if parent and child chosen, parent is null
    IF @ChartStatusDetailID IS NOT NULL
        SET @ChartStatusValueID = NULL

    SELECT DISTINCT
            mms.ProductLine AS ProductLine,
            mms.Product AS Product,
            ms.HEDISMeasure,
			mms.EventDate,
            ab.[Description] AS AbstractionStatus,
            ISNULL(ChartStatus.Title + ': ', '') + cs.Title AS ChartStatus,
            CASE WHEN ab.IsCompleted = 1 THEN 'Y' ELSE 'N' END AS Complete,
            CASE WHEN ci.PursuitEventChartImageID IS NOT NULL THEN 'Y'
                 ELSE 'N'
            END AS ChartAttached,
            p.PursuitNumber,
            ps.CustomerProviderSiteID,
            ps.ProviderSiteName,
            CASE WHEN ps.Address2 IS NOT NULL AND
                      ps.Address2 <> '' THEN ps.Address1 + ' - ' + ps.Address2
                 ELSE ps.Address1
            END AS SiteAddress,
            ps.City,
            ps.[State],
            ps.Zip,
            ps.Phone,
            ps.Fax AS ProviderSiteFax,
            ps.Contact AS ProviderSiteContact,
            pr.CustomerProviderID,
            pr.NPI,
            pr.TaxID AS TIN,
            pr.NameEntityFullName AS ProviderName,
            m.CustomerMemberID AS CustomerMemberID,
            m.NameLast + ISNULL(', ' + m.NameFirst, '') + ISNULL(' ' +
                                                              m.NameMiddleInitial,
                                                              '') AS MemberName,
            m.DateOfBirth AS DOB,
            m.Gender AS Gender,
            PVSL.LogDate AS AbstractionDate,
            ISNULL(a.AbstractorName, '') AS Abstractor,
            mt.HEDISSubMetricCode + ' - ' + mt.HEDISSubMetricDescription AS MetricDescription,
            CASE WHEN incompletePursuits.IncompleteCount > 0 THEN 'N'
                 ELSE 'Y'
            END AS AllPursuitsExhausted
    FROM    dbo.MemberMeasureMetricScoring mmms WITH(NOLOCK)
            INNER JOIN dbo.MemberMeasureSample mms WITH(NOLOCK) ON mmms.MemberMeasureSampleID = mms.MemberMeasureSampleID
            INNER JOIN dbo.Pursuit p WITH(NOLOCK) ON p.MemberID = mms.MemberID
            INNER JOIN dbo.PursuitEvent pe WITH(NOLOCK) ON pe.PursuitID = p.PursuitID AND
                                          pe.EventDate = mms.EventDate AND
                                          pe.MeasureID = mms.MeasureID
            INNER JOIN dbo.Measure ms WITH(NOLOCK) ON ms.MeasureID = mms.MeasureID
            INNER JOIN dbo.AbstractionStatus ab WITH(NOLOCK) ON ab.AbstractionStatusID = pe.AbstractionStatusID
            INNER JOIN dbo.ProviderSite ps WITH(NOLOCK) ON ps.ProviderSiteID = p.ProviderSiteID
            INNER JOIN dbo.Providers pr WITH(NOLOCK) ON pr.ProviderID = p.ProviderID
            INNER JOIN dbo.HEDISSubMetric mt WITH(NOLOCK) ON mt.HEDISSubMetricID = mmms.HEDISSubMetricID
            INNER JOIN dbo.Member m WITH(NOLOCK) ON m.MemberID = mms.MemberID
            LEFT OUTER JOIN dbo.ChartStatusValue cs WITH(NOLOCK) ON cs.ChartStatusValueID = pe.ChartStatusValueID
            LEFT OUTER JOIN dbo.Abstractor a WITH(NOLOCK) ON a.AbstractorID = p.AbstractorID
            OUTER APPLY (SELECT TOP 1
                                *
                         FROM   dbo.PursuitEventChartImage tci WITH(NOLOCK)
                         WHERE  tci.PursuitEventID = pe.PursuitEventID
                        ) AS ci
            OUTER APPLY (SELECT TOP 1
                                LogDate
                         FROM   dbo.PursuitEventStatusLog AS tPVSL WITH(NOLOCK)
                                INNER JOIN dbo.AbstractionStatus AS tAST WITH(NOLOCK) ON tPVSL.AbstractionStatusID = tAST.AbstractionStatusID AND
                                                              tAST.IsCompleted = 1
                         WHERE  tPVSL.PursuitEventID = pe.PursuitEventID AND
										tPVSL.AbstractionStatusChanged = 1
                         ORDER BY LogDate DESC
                        ) AS PVSL
            OUTER APPLY (SELECT Title
                         FROM   dbo.ChartStatusValue WITH(NOLOCK)
                         WHERE  ChartStatusValueID = cs.ParentID
                        ) AS ChartStatus
            OUTER APPLY (SELECT COUNT(p1.PursuitID) AS IncompleteCount
                         FROM   dbo.MemberMeasureMetricScoring mmms1 WITH(NOLOCK)
                                INNER JOIN dbo.MemberMeasureSample mms1 WITH(NOLOCK) ON mmms1.MemberMeasureSampleID = mms1.MemberMeasureSampleID
                                INNER JOIN dbo.Pursuit p1 WITH(NOLOCK) ON p1.MemberID = mms1.MemberID
                                INNER JOIN dbo.PursuitEvent pe1 WITH(NOLOCK) ON pe1.PursuitID = p1.PursuitID AND
                                                              pe1.EventDate = mms1.EventDate AND
                                                              pe1.MeasureID = mms1.MeasureID
                                INNER JOIN dbo.AbstractionStatus ab1 WITH(NOLOCK) ON ab1.AbstractionStatusID = pe1.AbstractionStatusID
                         WHERE  p1.MemberID = m.MemberID -- same member
                                AND
                                mms1.MeasureID = ms.MeasureID -- same measure
                                AND
                                p1.PursuitID != p.PursuitID -- different pursuit
                                AND
                                ab1.IsCompleted = 0 -- not completed
                        ) AS incompletePursuits
    WHERE   mmms.HybridHitCount = 0 AND
            mmms.ExclusionCount = 0 AND
            mmms.ReqExclCount = 0 AND
            mmms.SampleVoidCount = 0 AND
            ((@ProductLine IS NULL) OR
             (m.ProductLine = @ProductLine) OR
             (m.ProductLine LIKE '%' + @ProductLine + '%')
            ) AND
            ((@Product IS NULL) OR
             (m.Product = @Product) OR
             (m.Product LIKE '%' + @Product + '%')
            ) AND
            ((@MeasureID IS NULL) OR
             (pe.MeasureID = @MeasureID)
            ) AND
            ((@AbstractionStatusID IS NULL) OR
             (ab.AbstractionStatusID = @AbstractionStatusID)
            ) AND
            ((@AbstractionComplete IS NULL) OR
             (ab.IsCompleted = @AbstractionComplete)
            ) AND
            ((@ChartAttached IS NULL) OR
             ((ci.PursuitEventChartImageID IS NULL AND
               @ChartAttached = 0
              ) OR
              (ci.PursuitEventChartImageID IS NOT NULL AND
               @ChartAttached = 1
              )
             )
            ) AND
            ((@ProviderSiteID IS NULL) OR
             (ps.ProviderSiteID = @ProviderSiteID)
            ) AND
            ((@ProviderSiteName IS NULL) OR
             (ps.ProviderSiteName = @ProviderSiteName) OR
             (ps.ProviderSiteName LIKE '%' + @ProviderSiteName + '%')
            ) AND
            ((@ProviderID IS NULL) OR
             (pr.ProviderID = @ProviderID)
            ) AND
            ((@ProviderName IS NULL) OR
             (pr.NameEntityFullName = @ProviderName) OR
             (pr.NameEntityFullName LIKE '%' + @ProviderName + '%') OR
             (pr.NameLast = @ProviderName) OR
             (pr.NameLast LIKE '%' + @ProviderName + '%')
            ) AND
            ((@AbstractorID IS NULL) OR
             (p.AbstractorID = @AbstractorID) OR
             (p.AbstractorID IS NULL AND
              @AbstractorID = -1
             )
            ) AND
            ((@AbstractionDateStart IS NULL) OR
             (@AbstractionDateStart <= PVSL.LogDate)
            ) AND
            ((@AbstractionDateEnd IS NULL) OR
             (PVSL.LogDate < DATEADD(DAY, 1, @AbstractionDateEnd))
            ) AND
            ((@MemberID IS NULL) OR
             (m.CustomerMemberID = @MemberID)
            ) AND
            ((@MemberName IS NULL) OR
             (LOWER(m.NameLast + ', ' + m.NameFirst) = LOWER(@MemberName))
            ) AND
            ((@ProviderNPI IS NULL) OR
             (@ProviderNPI = pr.NPI)
            ) AND
            ((@ProviderTIN IS NULL) OR
             (@ProviderTIN = pr.TaxID)
            ) AND
            ((@ChartStatusValueID IS NULL) OR
             (( pe.ChartStatusValueID IN (
              SELECT    ChartStatusValueID
              FROM      dbo.ChartStatusValue WITH(NOLOCK)
              WHERE     ParentID = @ChartStatusValueID) OR
              pe.ChartStatusValueID = @ChartStatusValueID)
             )
            ) AND
            ((@ChartStatusDetailID IS NULL) OR
             (pe.ChartStatusValueID = @ChartStatusDetailID)
            ) AND
            ((@ProviderSiteNameID IS NULL) OR
             (ps.ProviderSiteID = @ProviderSiteNameID)
            ) AND
            ((@ProviderNameID IS NULL) OR
             (pr.ProviderID = @ProviderNameID)
            )
    ORDER BY ProductLine,
            Product,
            HEDISMeasure,
            PursuitNumber,
            MemberName,
            DOB,
            Gender

END
GO
GRANT EXECUTE ON  [Report].[GetNoHits] TO [Reporting]
GO
