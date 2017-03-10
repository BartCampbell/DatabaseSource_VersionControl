SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ApplySampleVoid]
(
 @HedisMeasure varchar(16) = NULL,
 @MemberID int
)
AS 
BEGIN
    SET NOCOUNT ON;

    --Check Sample Void Exclusions
    IF OBJECT_ID('tempdb..#SampleVoids') IS NOT NULL 
        DROP TABLE #SampleVoids
    
    SELECT  MemberMeasureMetricScoringID,
            VoidCount = CASE 
							WHEN a.PreExclusionAdmin = 1 OR a.PreExclusionValidData = 1 OR a.PreExclusionPlanEmployee = 1
							THEN 1
							WHEN (SELECT   COUNT(*)
                                   FROM     Pursuit b2
                                            INNER JOIN PursuitEvent c2 ON b2.PursuitID = c2.PursuitID
                                            INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                   WHERE    b2.MemberID = b.MemberID AND
											c2.EventDate = b.EventDate AND                                 
                                            (c2.SampleVoidFlag = 1 OR
                                             (c2.SampleVoidReasonCode <> 'N/A' AND
                                              (c2.SampleVoidReasonCode NOT LIKE '%(cbp only%)' OR
                                               c.HedisMeasureInit = 'CBP'))) AND
                                            c2.MeasureID = b.MeasureID) > 0
                             THEN 1
                             ELSE 0
							 END,
            VoidReason = CASE 
							WHEN a.PreExclusionAdmin = 1 
							THEN 'Exclude due to administrative data refresh (Administrative Exclusion)'
							WHEN a.PreExclusionValidData = 1 
							THEN 'Exclude due to valid data error(s)'
							WHEN a.PreExclusionPlanEmployee = 1
							THEN 'Exclude due to member is an organization employee/dependent'
							ELSE
									CONVERT(varchar(200), (SELECT  MIN(c2.SampleVoidReasonCode)
															FROM    Pursuit b2
																	INNER JOIN PursuitEvent c2 ON b2.PursuitID = c2.PursuitID
																	INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
															WHERE   b2.MemberID = b.MemberID AND
																	c2.EventDate = b.EventDate AND                                              
																	(c2.SampleVoidFlag = 1 OR
																	 (c2.SampleVoidReasonCode <> 'N/A' AND
																	  (c2.SampleVoidReasonCode NOT LIKE '%(cbp only%)' OR
																	   c.HedisMeasureInit = 'CBP'))) AND
																	c2.MeasureID = b.MeasureID))
							END
    INTO    #SampleVoids
    FROM    MemberMeasureMetricScoring a
            INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
            INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
    WHERE   ((@HedisMeasure IS NULL) OR
             (HEDISMeasureInit = @HedisMeasure)) AND
            (MemberID = @MemberID);

    UPDATE  MMMS
    SET     SampleVoidCount = ISNULL(VoidCount, 0),
            SampleVoidReason = VoidReason
    FROM    dbo.MemberMeasureMetricScoring AS MMMS
			INNER JOIN dbo.MemberMeasureSample AS MMS
					ON MMMS.MemberMeasureSampleID = MMS.MemberMeasureSampleID                  
            INNER JOIN #SampleVoids AS T ON MMMS.MemberMeasureMetricScoringID = T.MemberMeasureMetricScoringID
	WHERE	(MMS.MemberID = @MemberID);
END
GO
