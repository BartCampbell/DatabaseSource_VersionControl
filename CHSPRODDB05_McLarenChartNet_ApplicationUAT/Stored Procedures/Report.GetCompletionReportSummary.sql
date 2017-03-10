SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Raasch, Mark
-- Create date: 10/29/2014
-- Description:	Returns the detail for completion report summary report
-- =============================================
CREATE PROCEDURE [Report].[GetCompletionReportSummary]
(
 @ProductLine varchar(20) = NULL,
 @Product varchar(20) = NULL,
 @MeasureID int = NULL,
 @AbstractionDateEnd datetime = NULL
)
AS
BEGIN

    SET NOCOUNT ON

    SELECT DISTINCT TOP 2100
            mms.productline AS ProductLine,
            mms.Product AS Product,
            ms.HEDISMeasure AS Measure,
            ms.hedismeasuredescription AS MeasureDescription,
            COUNT(DISTINCT pe.PursuitEventID) AS TotalPursuits,
			-- Changed to counting when LogDate is not null
            COUNT(DISTINCT CASE WHEN PVSL.LogDate IS NOT NULL
                                THEN pe.PursuitEventID
                           END) AS CompletedPursuits
    FROM    MemberMeasureMetricScoring mmms
            INNER JOIN MemberMeasureSample mms ON mmms.MemberMeasureSampleID = mms.MemberMeasureSampleID
            INNER JOIN Member m ON m.MemberID = mms.MemberID
            INNER JOIN Pursuit p ON p.MemberID = mms.MemberID
            INNER JOIN PursuitEvent pe ON (p.PursuitID = pe.PursuitID AND
                                         mms.MeasureID = pe.MeasureID AND
                                         mms.EventDate = pe.EventDate) OR	
										 pe.MemberMeasureSampleID = mms.MemberMeasureSampleID
            INNER JOIN Measure ms ON ms.MeasureID = MMS.MeasureID
            LEFT JOIN AbstractionStatus ab ON ab.AbstractionStatusID = pe.AbstractionStatusID
            LEFT JOIN HEDISSubMetric mt ON mt.HEDISSubMetricID = mmms.HEDISSubMetricID
            OUTER APPLY (SELECT TOP 1
                                LogDate
                         FROM   dbo.PursuitEventStatusLog AS tPVSL WITH(NOLOCK)
                                INNER JOIN dbo.AbstractionStatus AS tAST WITH(NOLOCK) ON tPVSL.AbstractionStatusID = tAST.AbstractionStatusID AND
                                                              tAST.IsCompleted = 1
                         WHERE  (tPVSL.PursuitEventID = pe.PursuitEventID) AND
										tPVSL.AbstractionStatusChanged = 1 AND
                                --Moved date WHERE criteria to OUTER APPLY subquery and changed operator "<=" to "<"
                                                ((@AbstractionDateEnd IS NULL) OR
                                                 (tPVSL.LogDate < DATEADD(DAY, 1, @AbstractionDateEnd)))
                         ORDER BY LogDate DESC
                        ) AS PVSL
		--WHERE  ((@ProductLine IS NULL) OR (m.ProductLine = @ProductLine) OR (m.ProductLine LIKE '%' + @ProductLine + '%')) AND
		--		((@Product IS NULL) OR (m.Product = @Product) OR (m.Product LIKE '%' + @Product + '%')) AND
		--		((@MeasureID IS NULL) OR (pe.MeasureID = @MeasureID)) 
    GROUP BY ms.HEDISMeasure,
            mms.ProductLine,
            mms.Product,
            ms.HEDISMeasureDescription
    ORDER BY mms.ProductLine,
            mms.Product,
            ms.HEDISMeasure
END

GO
GRANT EXECUTE ON  [Report].[GetCompletionReportSummary] TO [Reporting]
GO
