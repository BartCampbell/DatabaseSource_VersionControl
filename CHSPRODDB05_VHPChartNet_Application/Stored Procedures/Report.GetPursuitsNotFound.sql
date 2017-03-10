SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Report].[GetPursuitsNotFound]
(
 @ProductLine varchar(20) = NULL,
 @Product varchar(20) = NULL,
 @MeasureID int = NULL,
 @AbstractionStatusID int = NULL,
 @ChartStatusValueID int = NULL,
 @AbstractorID int = NULL,
 @ProviderSiteID int = NULL,
 @ProviderID int = NULL,
 @ProviderNPI char(10) = NULL,
 @ProviderTIN varchar(11) = NULL,
 @ProviderSiteName varchar(75) = NULL,
 @ProviderName varchar(25) = NULL,
 @AbstractionDateStart datetime = NULL,
 @AbstractionDateEnd datetime = NULL,
 @ChartStatusDetailID int = NULL,
 @ProviderSiteNameID int = NULL,
 @ProviderNameID int = NULL,
 @PursuitNumber varchar(30) = NULL
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

    SELECT 
            MIN(mms.ProductLine) AS ProductLine,
            MIN(mms.Product) AS Product,
            MIN(ms.HEDISMeasure) AS HEDISMeasure,
            MIN(mms.EventDate) AS EventDate,
            MIN(p.PursuitNumber) AS PursuitNumber,
            MIN(ps.ProviderSiteID) AS ProviderSiteID,
            MIN(ps.CustomerProviderSiteID) AS CustomerProviderSiteID,
            MIN(ps.ProviderSiteName) AS ProviderSiteName,
            MIN(CASE WHEN ps.Address2 IS NOT NULL AND
                      ps.Address2 <> '' THEN ps.Address1 + ' - ' + ps.Address2
                 ELSE ps.Address1
            END) AS ProviderSiteAddress,
            MIN(ps.City) AS ProviderSiteAddressCity,
            MIN(ps.County) AS ProviderSiteAddressCounty,
            MIN(ps.[State]) AS ProviderSiteAddressState,
            MIN(ps.Zip) AS ProviderSiteAddressZip,
            MIN(ps.Phone) AS ProviderSitePhone,
            MIN(pr.CustomerProviderID) AS CustomerProviderID,
            MIN(pr.NameEntityFullName) AS ProviderName,
            MIN(ps.Fax) AS ProviderSiteFax,
            MIN(ps.Contact) AS ProviderSiteContact,
            MIN(pr.NPI) AS NPI,
            MIN(pr.TaxID) AS TIN,
            MIN(m.CustomerMemberID) AS MemberID,
            MIN(m.NameLast + ISNULL(', ' + m.NameFirst, '') + ISNULL(' ' +
                                                              m.NameMiddleInitial,
                                                              '')) AS MemberName,
            MIN(m.DateOfBirth) AS DOB,
            MIN(m.Gender) AS Gender,
            MIN(ab.[Description]) AS AbstractionStatus,
            MIN(CONVERT(varchar, PVSL.LogDate, 101)) AS AbstractionDate,
            MIN(ISNULL(a.AbstractorName, '')) AS Abstractor,
            MIN(ISNULL(ChartStatus.Title + ': ', '') + cs.Title) AS ChartStatus,
            CASE WHEN MIN(CONVERT(int, mmms.HybridHit)) = 1 OR
                      MIN(mmms.HybridHitCount) >= 1 THEN 'Y'
                 ELSE 'N'
            END AS Numerator,
            CASE WHEN MAX(CONVERT(int, mmms.Exclusion)) = 1 OR
                      MAX(CONVERT(int, mmms.SampleVoid)) = 1 OR
                      MAX(mmms.ExclusionCount) >= 1 OR
                      MAX(mmms.SampleVoidCount) >= 1 THEN 'Y'
                 ELSE 'N'
            END AS Exclusion
    FROM    MemberMeasureMetricScoring mmms
            INNER JOIN MemberMeasureSample mms ON mmms.MemberMeasureSampleID = mms.MemberMeasureSampleID
            INNER JOIN Pursuit p ON p.MemberID = mms.MemberID
            INNER JOIN PursuitEvent pe ON pe.PursuitID = p.PursuitID AND pe.EventDate = mms.EventDate AND pe.MeasureID = mms.MeasureID
            INNER JOIN Measure ms ON ms.MeasureID = mms.MeasureID
            INNER JOIN AbstractionStatus ab ON ab.AbstractionStatusID = pe.AbstractionStatusID
            INNER JOIN ProviderSite ps ON ps.ProviderSiteID = p.ProviderSiteID
            INNER JOIN Providers pr ON pr.ProviderID = p.ProviderID
            INNER JOIN HEDISSubMetric mt ON mt.HEDISSubMetricID = mmms.HEDISSubMetricID
            INNER JOIN Member m ON m.MemberID = mms.MemberID
            INNER JOIN ChartStatusValue cs ON cs.ChartStatusValueID = pe.ChartStatusValueID
            INNER JOIN Abstractor a ON a.AbstractorID = p.AbstractorID
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
                         FROM   ChartStatusValue
                         WHERE  ChartStatusValueID = cs.ParentID
                        ) AS ChartStatus
    WHERE   ((cs.Title LIKE '%Not Found%') OR
             (ChartStatus.Title LIKE '%Not Found%')
            ) AND
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
            ((@ProviderSiteName IS NULL) OR
             (ps.ProviderSiteName = @ProviderSiteName) OR
             (ps.ProviderSiteName LIKE '%' + @ProviderSiteName + '%')
            ) AND
            ((@ProviderName IS NULL) OR
             (pr.NameEntityFullName = @ProviderName) OR
             (pr.NameEntityFullName LIKE '%' + @ProviderName + '%') OR
             (pr.NameLast = @ProviderName) OR
             (pr.NameLast LIKE '%' + @ProviderName + '%')
            ) AND
            ((@AbstractionDateStart IS NULL) OR
             (@AbstractionDateStart <= PVSL.LogDate)
            ) AND
            ((@AbstractionDateEnd IS NULL) OR
             (PVSL.LogDate < DATEADD(DAY, 1, @AbstractionDateEnd))
            ) AND
            ((@AbstractorID IS NULL) OR
             (p.AbstractorID = @AbstractorID) OR
             (p.AbstractorID IS NULL AND
              @AbstractorID = -1
             )
            ) AND
            ((@ProviderSiteID IS NULL) OR
             (ps.ProviderSiteID = @ProviderSiteID)
            ) AND
            ((@ProviderID IS NULL) OR
             (pr.ProviderID = @ProviderID)
            ) AND
            ((@ProviderNPI IS NULL) OR
             (pr.NPI = @ProviderNPI)
            ) AND
            ((@ProviderTIN IS NULL) OR
             (pr.TaxID = @ProviderTIN)
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
            ) AND
            ((@PursuitNumber IS NULL) OR
             (LOWER(p.PursuitNumber) = LOWER(@PursuitNumber))
            )
    GROUP BY mms.MemberMeasureSampleID,
            pe.PursuitEventID,
            p.PursuitID
    ORDER BY ProductLine,
            Product,
            HEDISMeasure,
            AbstractionDate DESC,
            PursuitNumber 

END
GO
GRANT EXECUTE ON  [Report].[GetPursuitsNotFound] TO [Reporting]
GO
