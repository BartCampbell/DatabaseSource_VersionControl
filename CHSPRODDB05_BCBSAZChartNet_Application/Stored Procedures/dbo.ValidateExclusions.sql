SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ValidateExclusions]
(
 @HedisMeasure varchar(16) = NULL,
 @MemberID int
)
AS 
BEGIN
    SET NOCOUNT ON;

    --Validate Exclusions
	--a) Reverses exclusions for members who are fully compliant.
	--b) Applies CIS exclusion to all metrics, if not compliant for the metric.

    IF OBJECT_ID('tempdb..#ValidateExclusions') IS NOT NULL 
        DROP TABLE #ValidateExclusions
    
    SELECT 
			b.MemberMeasureSampleID,
			MIN(a.ExclusionReason) AS ExclusionReason
    INTO    #ValidateExclusions
    FROM    MemberMeasureMetricScoring a
            INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
            INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
    WHERE   ((@HedisMeasure IS NULL) OR
             (c.HEDISMeasureInit = @HedisMeasure)) AND
            (b.MemberID = @MemberID) AND
			(a.ExclusionCount >= 1) AND
			(a.HybridHitCount = 0)
	GROUP BY b.MemberMeasureSampleID;

    UPDATE  MMMS
    SET     ExclusionCount = CASE WHEN T.MemberMeasureSampleID IS NOT NULL THEN 1 ELSE 0 END,
			ExclusionReason = T.ExclusionReason
    FROM    dbo.MemberMeasureMetricScoring AS MMMS
			INNER JOIN dbo.MemberMeasureSample AS MMS
					ON MMMS.MemberMeasureSampleID = MMS.MemberMeasureSampleID   
			INNER JOIN dbo.HEDISSubMetric AS MX
					ON MMMS.HEDISSubMetricID = MX.HEDISSubMetricID               
            LEFT OUTER JOIN #ValidateExclusions AS T ON MMS.MemberMeasureSampleID = T.MemberMeasureSampleID
	WHERE	((@HedisMeasure IS NULL) OR
             (MX.HEDISMeasureInit = @HedisMeasure)) AND
			 (MMS.MemberID = @MemberID);
END
GO
