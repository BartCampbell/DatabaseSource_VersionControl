SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetHybridResultsDetail] ( @DataRunID INT )
AS
    BEGIN

        IF @DataRunID IS NOT NULL
            BEGIN;	
                SELECT  RDSPK.PopulationNum AS [Population] ,
                        CASE WHEN RMD.IsExclusion = 1 THEN 'Exclusion'
                             ELSE 'Numerator Compliance'
                        END AS [Record Type] ,
                        MM.Abbrev AS Measure ,
                        MX.Abbrev AS Metric ,
                        MX.Descr AS [Metric Description] ,
                        RDSMK.CustomerMemberID AS [Member ID] ,
                        RDSMK.DisplayID AS [IMI Member ID] ,
                        RDSMK.NameLast AS [Member Last Name] ,
                        RDSMK.NameFirst AS [Member First Name] ,
                        RDSMK.DOB ,
                        MG.Abbrev AS [Gender] ,
                        RSS.SysSampleOrder AS [Sample Order] ,
                        RSS.IsAuxiliary AS [Is Over Sample] ,
                        RMD.IsDenominator AS [Is MRSS] ,
                        CASE WHEN MX.Abbrev <> 'CDC3'
                                  OR MX.Abbrev = 'CDC3'
                                  AND RMD.IsIndicator = 0
                             THEN RMD.IsNumeratorMedRcd
                             ELSE 0
                        END AS [Compliant, MRR] ,
                        RMD.IsExclusion AS [Exclusion] ,
                        ISNULL(MXT.Descr, '') AS [Exclusion Reason]/*,
				RMD.IsIndicator AS [Supplemental Indicator],
				ISNULL(CASE WHEN RMD.IsIndicator = 1
							THEN CASE MX.Abbrev
									WHEN 'CBP' THEN 'Diabetes Diagnosis'
									WHEN 'CDC3' THEN 'HbA1c Required Exclusion'
									END
							END, '') AS [Supplemental Indicator Reason]*/
                FROM    Result.MeasureDetail AS RMD WITH ( NOLOCK )
                        INNER JOIN Result.SystematicSamples AS RSS ON RSS.SysSampleRefID = RMD.SysSampleRefID
                                                              AND RSS.DataRunID = RMD.DataRunID
                        INNER JOIN Result.DataSetMemberKey AS RDSMK WITH ( NOLOCK ) ON RDSMK.DataRunID = RMD.DataRunID
                                                              AND RDSMK.DSMemberID = RMD.DSMemberID
                        INNER JOIN Measure.Measures AS MM WITH ( NOLOCK ) ON MM.MeasureID = RMD.MeasureID
                        INNER JOIN Measure.Metrics AS MX WITH ( NOLOCK ) ON MX.MetricID = RMD.MetricID
                        INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH ( NOLOCK ) ON RDSPK.DataRunID = RMD.DataRunID AND RDSPK.PopulationID = RMD.PopulationID
                        LEFT OUTER JOIN Measure.ExclusionTypes AS MXT ON MXT.ExclusionTypeID = RMD.ExclusionTypeID
                        LEFT OUTER JOIN Member.Genders AS MG ON MG.Gender = RDSMK.Gender
                WHERE   ( RMD.DataRunID = @DataRunID )
                        AND ( RMD.ResultTypeID = 3 )
                        AND ( ( RMD.IsNumeratorMedRcd = 1 )
                              OR ( RMD.IsExclusion = 1 )
                            )
                ORDER BY [Population] ,
                        Measure ,
                        [Record Type] ,
                        Metric ,
                        [Sample Order];

            END;
    END
GO
GRANT EXECUTE ON  [Report].[GetHybridResultsDetail] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetHybridResultsDetail] TO [Reports]
GO
