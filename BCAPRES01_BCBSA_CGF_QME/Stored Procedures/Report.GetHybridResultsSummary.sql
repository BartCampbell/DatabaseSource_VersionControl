SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetHybridResultsSummary] (@DataRunID int)
AS
BEGIN
    IF @DataRunID IS NOT NULL
        BEGIN;	
            SELECT  RMD.*,
					BSS.SysSampleID, 
					BSS.PayerID AS SysSamplePayerID, 
					PP.Abbrev AS SysSamplePayer, 
					MNG.Descr AS EnrollGroup
            INTO    #HybridResults
            FROM    Result.MeasureDetail AS RMD
					INNER JOIN Result.SystematicSamples AS RSS
							ON RSS.DataRunID = RMD.DataRunID AND
								RSS.DataSetID = RMD.DataSetID AND
								RSS.DSMemberID = RMD.DSMemberID AND
								RSS.SysSampleRefID = RMD.SysSampleRefID --Only linked really needed
					INNER JOIN Batch.SystematicSamples AS BSS
							ON BSS.SysSampleID = RSS.SysSampleID
					LEFT OUTER JOIN Product.Payers AS PP
							ON PP.PayerID = BSS.PayerID
					LEFT OUTER JOIN Member.EnrollmentGroups AS MNG
							ON MNG.EnrollGroupID = RMD.EnrollGroupID
            WHERE   RMD.DataRunID = @DataRunID AND
                    RMD.ResultTypeID = 3;

            CREATE UNIQUE CLUSTERED INDEX IX_#HybridResults ON #HybridResults (PopulationID, MeasureID, MetricID, DSMemberID, KeyDate, ResultTypeID, ResultRowID);

            SELECT  RMD.*, MM.Abbrev AS Measure
            INTO    #AdminResults
            FROM    Result.MeasureDetail AS RMD
                    INNER JOIN Measure.Measures AS MM ON MM.MeasureID = RMD.MeasureID AND
                                                         MM.IsHybrid = 1
            WHERE   RMD.DataRunID = @DataRunID AND
                    RMD.ResultTypeID = 1;

            CREATE UNIQUE CLUSTERED INDEX IX_#AdminResults ON #AdminResults (PopulationID, MeasureID, MetricID, DSMemberID, KeyDate, ResultTypeID, ResultRowID);

            SELECT  MIN(RDSPK.PopulationNum) AS [Population],
					MIN(RMD.SysSampleID) AS [Systematic Sample ID],
					ISNULL(MIN(RMD.SysSamplePayer) + CASE WHEN COUNT(DISTINCT RMD.EnrollGroupID) = 1 THEN ' - ' + MIN(RMD.EnrollGroup) ELSE '' END, 'All') AS [Systematic Sample Description],
                    MIN(MM.Abbrev) AS Measure,
                    MIN(MX.Abbrev) AS Metric,
                    MIN(MX.Descr) AS [Metric Description],
                    SUM(CONVERT(int, RMD.IsDenominator)) AS [MRSS: Denominator],
                    SUM(CONVERT(int, CASE WHEN RMD.IsDenominator = 1 AND
                                               (MX.Abbrev <> 'CDC3' OR
                                                MX.Abbrev = 'CDC3' AND
                                                RMD.IsIndicator = 0
                                               ) AND
											   ISNULL(RMD.IsSupplementalNumerator, 0) = 0
											   THEN RMD.IsNumeratorAdmin
                                          ELSE 0
                                     END)) AS [MRSS: Compliant, Admin],
                    SUM(CONVERT(int, CASE WHEN RMD.IsDenominator = 1 AND
                                               (MX.Abbrev <> 'CDC3' OR
                                                MX.Abbrev = 'CDC3' AND
                                                RMD.IsIndicator = 0
                                               ) THEN RMD.IsNumeratorMedRcd
                                          ELSE 0
                                     END)) AS [MRSS: Compliant, MRR],
					SUM(CONVERT(int, CASE WHEN RMD.IsDenominator = 1 AND
                                               (MX.Abbrev <> 'CDC3' OR
                                                MX.Abbrev = 'CDC3' AND
                                                RMD.IsIndicator = 0
                                               ) AND
											   ISNULL(RMD.IsSupplementalNumerator, 0) = 1
											   THEN RMD.IsNumeratorAdmin
                                          ELSE 0
                                     END)) AS [MRSS: Compliant, Supplemental],
                    SUM(CONVERT(int, CASE WHEN RMD.IsDenominator = 1 AND
                                               (MX.Abbrev <> 'CDC3' OR
                                                MX.Abbrev = 'CDC3' AND
                                                RMD.IsIndicator = 0
                                               ) THEN RMD.IsNumerator
                                          ELSE 0
                                     END)) AS [MRSS: Compliant, Hybrid],
                    dbo.Score(SUM(CONVERT(int, RMD.IsDenominator)),
                              SUM(CONVERT(int, CASE WHEN RMD.IsDenominator = 1 AND
                                                         (MX.Abbrev <> 'CDC3' OR
                                                          MX.Abbrev = 'CDC3' AND
                                                          RMD.IsIndicator = 0
                                                         )
                                                    THEN RMD.IsNumerator
                                                    ELSE 0
                                               END))) AS [MRSS: Score],
                    Ncqa.LowerConfidenceInterval(SUM(CONVERT(int, RMD.IsDenominator)),
                                                 SUM(CONVERT(int, CASE
                                                              WHEN RMD.IsDenominator = 1 AND
                                                              (MX.Abbrev <> 'CDC3' OR
                                                              MX.Abbrev = 'CDC3' AND
                                                              RMD.IsIndicator = 0
                                                              )
                                                              THEN RMD.IsNumerator
                                                              ELSE 0
                                                              END))) AS [MRSS: Lower Confidence],
                    Ncqa.UpperConfidenceInterval(SUM(CONVERT(int, RMD.IsDenominator)),
                                                 SUM(CONVERT(int, CASE
                                                              WHEN RMD.IsDenominator = 1 AND
                                                              (MX.Abbrev <> 'CDC3' OR
                                                              MX.Abbrev = 'CDC3' AND
                                                              RMD.IsIndicator = 0
                                                              )
                                                              THEN RMD.IsNumerator
                                                              ELSE 0
                                                              END))) AS [MRSS: Upper Confidence],
                    COUNT(DISTINCT RMD.ResultRowID) AS [FSS: Denominator*],
                    SUM(CONVERT(int, CASE WHEN (MX.Abbrev <> 'CDC3' OR
                                                MX.Abbrev = 'CDC3' AND
                                                RMD.IsIndicator = 0
                                               ) AND
											   ISNULL(RMD.IsSupplementalNumerator, 0) = 0
											   THEN RMD.IsNumeratorAdmin
                                          ELSE 0
                                     END)) AS [FSS: Compliant, Admin*],
                    SUM(CONVERT(int, CASE WHEN (MX.Abbrev <> 'CDC3' OR
                                                MX.Abbrev = 'CDC3' AND
                                                RMD.IsIndicator = 0
                                               ) THEN RMD.IsNumeratorMedRcd
                                          ELSE 0
                                     END)) AS [FSS: Compliant, MRR*],
					SUM(CONVERT(int, CASE WHEN (MX.Abbrev <> 'CDC3' OR
                                                MX.Abbrev = 'CDC3' AND
                                                RMD.IsIndicator = 0
                                               ) AND
											   ISNULL(RMD.IsSupplementalNumerator, 0) = 1
											   THEN RMD.IsNumeratorAdmin
                                          ELSE 0
                                     END)) AS [FSS: Compliant, Supplemental*],
                    SUM(CONVERT(int, CASE WHEN (MX.Abbrev <> 'CDC3' OR
                                                MX.Abbrev = 'CDC3' AND
                                                RMD.IsIndicator = 0
                                               ) THEN RMD.IsNumerator
                                          ELSE 0
                                     END)) AS [FSS: Compliant, Hybrid*],
                    SUM(FSS.IsDenominatorFSS) AS [FSS: Denominator (Reported)],
                    SUM(FSS.IsNumeratorFSSAdmin) AS [FSS: Compliant, Admin (Reported)],
					SUM(FSS.IsNumeratorFSSSupplemental) AS [FSS: Compliant, Supplemental (Reported)],
                    CASE WHEN COUNT(DISTINCT RMD.ResultRowID) = SUM(FSS.IsDenominatorFSS)
                         THEN 'Pass'
                         ELSE 'Fail'
                    END AS [FSS: Validation],
                    SUM(CONVERT(int, CASE WHEN MXT.Abbrev = 'A'
                                          THEN RMD.IsExclusion
                                          ELSE 0
                                     END)) AS [Exclusion: Admin Exclusion],
                    SUM(CONVERT(int, CASE WHEN MXT.Abbrev = 'X'
                                          THEN RMD.IsExclusion
                                          ELSE 0
                                     END)) AS [Exclusion: General/Measure-specific],
                    SUM(CONVERT(int, CASE WHEN MXT.Abbrev = 'V'
                                          THEN RMD.IsExclusion
                                          ELSE 0
                                     END)) AS [Exclusion: Valid Data Error],
                    SUM(CONVERT(int, CASE WHEN MXT.Abbrev = 'H'
                                          THEN RMD.IsExclusion
                                          ELSE 0
                                     END)) AS [Exclusion: Health Plan Employee],
                    SUM(CONVERT(int, CASE WHEN MXT.Abbrev = 'F'
                                          THEN RMD.IsExclusion
                                          ELSE 0
                                     END)) AS [Exclusion: False Positive Diagnosis],
                    SUM(CONVERT(int, RMD.IsExclusion)) AS [Exclusion: Total]
            FROM    #HybridResults AS RMD WITH (NOLOCK)
                    INNER JOIN Measure.Measures AS MM WITH (NOLOCK) ON MM.MeasureID = RMD.MeasureID
                    INNER JOIN Measure.Metrics AS MX WITH (NOLOCK) ON MX.MetricID = RMD.MetricID
                    INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH (NOLOCK) ON RDSPK.DataRunID = RMD.DataRunID AND
                                                              RDSPK.PopulationID = RMD.PopulationID
                    LEFT OUTER JOIN Measure.ExclusionTypes AS MXT WITH (NOLOCK) ON MXT.ExclusionTypeID = RMD.ExclusionTypeID
                    OUTER APPLY (
									SELECT COUNT(*) AS IsDenominatorFSS,
											SUM(CONVERT(bigint, CASE WHEN ISNULL(tFSS.IsSupplementalNumerator, 0) = 0 THEN tFSS.IsNumerator ELSE 0 END)) AS IsNumeratorFSSAdmin,
											SUM(CONVERT(bigint, CASE WHEN ISNULL(tFSS.IsSupplementalNumerator, 0) = 1 THEN tFSS.IsNumerator ELSE 0 END)) AS IsNumeratorFSSSupplemental
									 FROM   #AdminResults AS tFSS WITH (NOLOCK, INDEX (1))
									 WHERE  (tFSS.DataRunID = RMD.DataRunID) AND
											(tFSS.IsDenominator = 1) AND
											(tFSS.ResultTypeID = 1) AND
											(tFSS.MeasureID = RMD.MeasureID) AND
											(tFSS.MetricID = RMD.MetricID) AND
											(tFSS.DSMemberID = RMD.DSMemberID) AND
											(tFSS.PopulationID = RMD.PopulationID) AND
											(tFSS.PayerID = RMD.PayerID) AND
											(tFSS.BitProductLines &
											 RMD.BitProductLines > 0) AND
											(
												(tFSS.DSEntityID = RMD.DSEntityID) OR
												(tFSS.Measure NOT IN ('FPC', 'MRP','PPC')) OR
												(tFSS.Measure IN ('FPC', 'PPC') AND RMD.KeyDate BETWEEN DATEADD(dd, -30, tFSS.KeyDate) AND DATEADD(dd, 30, tFSS.KeyDate)) OR
												(tFSS.Measure IN ('MRP') AND RMD.KeyDate BETWEEN DATEADD(dd, -14, tFSS.KeyDate) AND DATEADD(dd, 14, tFSS.KeyDate))
											)
									) AS FSS
            WHERE   (RMD.DataRunID = @DataRunID) AND
                    (RMD.ResultTypeID = 3)
            GROUP BY RMD.PopulationID,
					RMD.SysSampleID,
                    RMD.MeasureID,
                    RMD.MetricID
            ORDER BY [Population],
					[Systematic Sample Description],
                    Measure,
					[Systematic Sample ID],
                    Metric
            OPTION  (FORCE ORDER);

        END;

END;

GO
GRANT EXECUTE ON  [Report].[GetHybridResultsSummary] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetHybridResultsSummary] TO [Reports]
GO
