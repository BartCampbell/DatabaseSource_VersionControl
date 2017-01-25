SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Report].[GetExclusionsMRR]
(
 @ProductLine varchar(20) = NULL,
 @Product varchar(20) = NULL,
 @MeasureID int = NULL,
 @MetricID int = NULL,
 @AbstractionStatusID int = NULL
)
AS
BEGIN

    SET NOCOUNT ON

    SELECT DISTINCT
            mms.ProductLine,
            mms.Product,
            ms.HEDISMeasure,
            mt.HEDISSubMetricCode + ' - ' + mt.HEDISSubMetricDescription AS HEDISSubMetricDescription,
            p.PursuitNumber,
            m.CustomerMemberID,
            m.NameLast,
            m.NameFirst,
            m.DateOfBirth AS DOB,
            CASE WHEN mmms.ExclusionCount > 0 OR mmms.Exclusion = 1 THEN 'Exclusion: ' + mmms.ExclusionReason
                 WHEN mmms.SampleVoidCount > 0 OR mmms.SampleVoid = 1 THEN 'Sample Void: ' + mmms.SampleVoidReason
                 WHEN mmms.ReqExclCount > 0 OR mmms.ReqExclusion = 1 THEN 'Required Exclusion: ' + mmms.ReqExclReason
                 ELSE ''
            END AS ExclusionDescription,
            (SELECT TOP 1
                    MAX(LogDate)
             FROM   dbo.PursuitEventStatusLog AS tPVSL WITH(NOLOCK)
                    INNER JOIN dbo.AbstractionStatus AS tAST WITH(NOLOCK) ON tPVSL.AbstractionStatusID = tAST.AbstractionStatusID AND
                                                              tAST.IsCompleted = 1
             WHERE  tPVSL.PursuitEventID = pe.PursuitEventID AND
										tPVSL.AbstractionStatusChanged = 1
            ) AS AbstractionDate,
            ISNULL(a.AbstractorName, '') AS Abstractor,
			aas.[Description] AS AbstractionStatus,
            mms.SampleDrawOrder,
            mms.SampleType
    FROM    dbo.MemberMeasureMetricScoring mmms WITH(NOLOCK)
            INNER JOIN dbo.MemberMeasureSample mms WITH(NOLOCK) ON mmms.MemberMeasureSampleID = mms.MemberMeasureSampleID
            INNER JOIN dbo.Pursuit p WITH(NOLOCK) ON p.MemberID = mms.MemberID
            INNER JOIN dbo.PursuitEvent pe WITH(NOLOCK) ON pe.PursuitID = p.PursuitID AND pe.EventDate = mms.EventDate AND pe.MeasureID = mms.MeasureID
            INNER JOIN dbo.Measure ms WITH(NOLOCK) ON ms.MeasureID = mms.MeasureID
            LEFT JOIN dbo.HEDISSubMetric mt WITH(NOLOCK) ON mt.HEDISSubMetricID = mmms.HEDISSubMetricID
            LEFT JOIN dbo.Member m WITH(NOLOCK) ON m.MemberID = mms.MemberID
            LEFT JOIN dbo.AbstractionReview ar WITH(NOLOCK) ON ar.PursuitEventID = pe.PursuitEventID
            LEFT JOIN dbo.Reviewer r WITH(NOLOCK) ON r.ReviewerID = p.ReviewerID
            LEFT JOIN dbo.Abstractor a WITH(NOLOCK) ON a.AbstractorID = p.AbstractorID
			LEFT JOIN dbo.AbstractionStatus AS aas WITH(NOLOCK) ON pe.AbstractionStatusID = aas.AbstractionStatusID
    WHERE   (mmms.ExclusionCount > 0 OR mmms.SampleVoidCount > 0 OR mmms.ReqExclCount > 0 ) 
	AND     mmms.DenominatorCount > 0
    AND	    ((@ProductLine IS NULL) OR (m.ProductLine = @ProductLine) OR (m.ProductLine LIKE @ProductLine)) 
	AND     ((@Product IS NULL) OR (m.Product = @Product) OR (m.Product LIKE @Product))
	AND     ((@MeasureID IS NULL) OR (pe.MeasureID = @MeasureID))
	AND     ((@MetricID IS NULL) OR (mt.HEDISSubMetricID = @MetricID)) 
    AND		((@AbstractionStatusID IS NULL) OR (aas.AbstractionStatusID = @AbstractionStatusID))
    ORDER BY productline,
            product,
            HEDISMeasure,
            HEDISSubMetricDescription,
            SampleDrawOrder

END

GO
GRANT EXECUTE ON  [Report].[GetExclusionsMRR] TO [Reporting]
GO
