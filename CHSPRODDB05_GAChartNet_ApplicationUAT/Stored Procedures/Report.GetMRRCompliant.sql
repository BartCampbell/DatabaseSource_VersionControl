SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Report].[GetMRRCompliant]
(
 @ProductLine varchar(20) = NULL,
 @Product varchar(20) = NULL,
 @MeasureID int = NULL,
 @AdministrativeHit bit = NULL
)
AS
BEGIN

    SET NOCOUNT ON

    IF @AdministrativeHit IS NULL
        SET @AdministrativeHit = 0;

    SELECT DISTINCT
            mms.ProductLine AS ProductLine,
            mms.Product AS Product,
            ms.HEDISMeasure,
            m.CustomerMemberID AS CustomerMemberID,
            m.NameLast + ISNULL(', ' + m.NameFirst, '') + ISNULL(' ' +
                                                              m.NameMiddleInitial,
                                                              '') AS MemberName,
            m.DateOfBirth AS DOB,
            m.Gender AS Gender,
            mt.HEDISSubMetricCode + ' - ' + mt.HEDISSubMetricDescription AS MetricDescription,
			mms.EventDate,
            m.DateOfBirth,
            CASE WHEN mmms.Denominator = 1 THEN 'Y'
                 ELSE 'N'
            END AS Denominator,
            CASE WHEN mmms.AdministrativeHitCount >= 1 THEN 'Y'
                 ELSE 'N'
            END AS AdministrativeHit,
            CASE WHEN mmms.MedicalRecordHitCount >= 1 THEN 'Y'
                 ELSE 'Y'
            END AS MedicalRecordHit,
            mms.SampleType,
            mms.SampleDrawOrder
    FROM    dbo.MemberMeasureMetricScoring mmms WITH(NOLOCK)
            INNER JOIN dbo.MemberMeasureSample mms WITH(NOLOCK) ON mmms.MemberMeasureSampleID = mms.MemberMeasureSampleID
            INNER JOIN dbo.Pursuit p WITH(NOLOCK) ON p.MemberID = mms.MemberID
            INNER JOIN dbo.PursuitEvent pe WITH(NOLOCK) ON pe.PursuitID = p.PursuitID AND pe.EventDate = mms.EventDate AND pe.MeasureID = mms.MeasureID
            INNER JOIN dbo.Measure ms WITH(NOLOCK) ON ms.MeasureID = mms.MeasureID
            INNER JOIN dbo.AbstractionStatus ab WITH(NOLOCK) ON ab.AbstractionStatusID = pe.AbstractionStatusID
            LEFT JOIN dbo.ProviderSite ps WITH(NOLOCK) ON ps.ProviderSiteID = p.ProviderSiteID
            JOIN dbo.Providers pr WITH(NOLOCK) ON pr.ProviderID = p.ProviderID
            LEFT JOIN dbo.HEDISSubMetric mt WITH(NOLOCK) ON mt.HEDISSubMetricID = mmms.HEDISSubMetricID
            LEFT JOIN dbo.Member m WITH(NOLOCK) ON m.MemberID = mms.MemberID
            LEFT JOIN dbo.AbstractionReview ar WITH(NOLOCK) ON ar.PursuitEventID = pe.PursuitEventID
            LEFT JOIN dbo.ChartStatusValue cs WITH(NOLOCK) ON cs.ChartStatusValueID = pe.ChartStatusValueID
            LEFT JOIN dbo.Abstractor a WITH(NOLOCK) ON a.AbstractorID = p.AbstractorID
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
            OUTER APPLY (SELECT COUNT(DISTINCT p1.PursuitID) AS IncompleteCount
                         FROM   dbo.MemberMeasureMetricScoring mmms1 WITH(NOLOCK)
                                LEFT JOIN dbo.MemberMeasureSample mms1 WITH(NOLOCK) ON mmms1.MemberMeasureSampleID = mms1.MemberMeasureSampleID
                                LEFT JOIN dbo.Pursuit p1 WITH(NOLOCK) ON p1.MemberID = mms1.MemberID
                                LEFT JOIN dbo.PursuitEvent pe1 WITH(NOLOCK) ON pe1.PursuitID = p1.PursuitID
                                LEFT JOIN dbo.Measure ms1 WITH(NOLOCK) ON ms1.MeasureID = mms1.MeasureID
                                LEFT JOIN dbo.AbstractionStatus ab1 WITH(NOLOCK) ON ab1.AbstractionStatusID = pe1.AbstractionStatusID
                         WHERE  p1.MemberID = m.MemberID -- same member
                                AND
                                ms1.MeasureID = ms.MeasureID -- same measure
                                AND
                                p1.PursuitID != p.PursuitID -- different pursuit
                                AND
                                ab1.IsCompleted = 0 -- not completed
                        ) AS incompletePursuits
    WHERE   (mmms.MedicalRecordHitCount >= 1 OR
             mmms.MedicalRecordHit = 1
            ) AND
            (mmms.HybridHitCount >= 1 OR
             mmms.HybridHit = 1
            ) AND
            mmms.Exclusion = 0 AND
            mmms.ReqExclusion = 0 AND
            mmms.SampleVoid = 0 AND
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
            ((@AdministrativeHit = 1) OR
             ((@AdministrativeHit = 0) AND
              ((mmms.AdministrativeHitCount = 0) OR
               (mmms.AdministrativeHit = 0)
              )
             )
            )
    ORDER BY ProductLine,
            Product,
            HEDISMeasure,
            MemberName,
            CustomerMemberID,
            DateOfBirth

END
GO
GRANT EXECUTE ON  [Report].[GetMRRCompliant] TO [Reporting]
GO
