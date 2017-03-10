SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetMemberLevelExtractWithMedicalGroups] ( @DataRunID INT )
AS
    BEGIN

        IF OBJECT_ID('tempdb..#MeasureList') IS NOT NULL
            DROP TABLE #MeasureList;

        SELECT  RMD.MeasureID ,
                MAX(RMD.ResultTypeID) AS ResultTypeID
        INTO    #MeasureList
        FROM    Result.MeasureDetail AS RMD
                INNER JOIN Measure.Measures AS MM ON RMD.MeasureID = MM.MeasureID
                                                     AND MM.Abbrev NOT IN (
                                                     'TLM', 'EBS', 'RDM',
                                                     'ENP', 'LDM', 'WOP' )
        WHERE   ( RMD.DataRunID = @DataRunID )
                AND ( ResultTypeID BETWEEN 1 AND 4 )
        GROUP BY RMD.MeasureID

        
		--SELECT  COUNT(*) AS Cnt
  --      FROM    Result.MeasureDetail_Classic AS RMD
  --              INNER JOIN #MeasureList AS t ON RMD.MeasureID = t.MeasureID
  --                                              AND RMD.ResultTypeID = t.ResultTypeID
  --      WHERE   ( RMD.DataRunID = @DataRunID )
  --              AND ( ( RMD.IsDenominator = 1 )
  --                    OR ( RMD.IsDenominator IS NULL )
  --                  )
					

        ;WITH    ResultTypes
                  AS ( SELECT   1 AS ResultTypeID ,
                                'Administrative Data, EOC-Like Measures' AS Descr
                       UNION
                       SELECT   2 AS ResultTypeID ,
                                'Medical Record, EOC-Like Measures' AS Descr
                       UNION
                       SELECT   3 AS ResultTypeID ,
                                'Hybrid Results, EOC-Like Measures' AS Descr
                       UNION
                       SELECT   4 AS ResultTypeID ,
                                'Administrative Data, UOS-Like Measures' AS Descr
                     )
            SELECT  DO.Descr AS Client ,
                    MMS.Descr AS MeasureSet ,
                    RDSRK.DataRunDescr + ' - ' + REPLACE(RDSRK.MeasureSetDescr,
                                                         MMS.Descr + ' - ', '') AS [DataSet] ,
                    RDSPK.Descr AS [Population] ,
                    REPLACE(Product.ConvertBitProductLinesToDescrs(RMD.BitProductLines),
                            ' :: ', ', ') AS [ProductLines] ,
                    RMCL.TopMeasClassDescr AS [MeasureClass/Domain] ,
                    ISNULL(RMCL.SubMeasClassDescr, '') AS [SubMeasureClass/SubDomain] ,
                    MM.Abbrev AS Measure ,
                    MM.Descr AS MeasureDescription ,
                    MX.Abbrev AS Metric ,
                    MX.Descr AS MetricDescription ,
                    RMD.ResultTypeID AS ResultType ,
                    ISNULL(RT.Descr, 'Other Results') AS ResultTypeDescription ,
                    RDSMK.CustomerMemberID ,
                    RDSMK.DisplayID AS ImiMemberID ,
                    RDSMK.IhdsMemberID AS ReportMemberID ,
                    RDSMK.NameFirst AS MemberFirstName ,
                    RDSMK.NameLast AS MemberLastName ,
                    RDSMK.DOB AS DateOfBirth ,
                    RDSMK.SsnDisplay AS SSN ,
                    RDSMGK.RegionName ,
                    RDSMGK.SubRegionName ,
                    RDSMGK.MedGrpName ,
                    RMD.KeyDate AS [EventDate] ,
                    RMD.IsDenominator AS Denominator ,
                    RMD.IsExclusion AS Exclusion ,
                    RMD.IsNumerator AS Compliant ,
                    CASE RMD.IsNumerator
                      WHEN 1 THEN 0
                      WHEN 0 THEN 1
                    END AS [Non-Compliant] ,
                    RMD.Age AS [Age] ,
                    CASE RMD.Gender
                      WHEN 0 THEN 'F'
                      WHEN 1 THEN 'M'
                    END AS Gender ,
                    RMD.[Days] AS [Days/LOS] ,
                    RMD.Qty AS Quantity ,
                    CASE WHEN MM.Abbrev LIKE 'PCR%'
                         THEN ISNULL(PCR.BaseWeight, 0)
                    END AS PCR_BaseWeight ,
                    CASE WHEN MM.Abbrev LIKE 'PCR%'
                         THEN ISNULL(PCR.DccWeight, 0)
                    END AS PCR_DischargeWeight ,
                    CASE WHEN MM.Abbrev LIKE 'PCR%'
                         THEN ISNULL(PCR.DemoWeight, 0)
                    END AS PCR_DemographicWeight ,
                    CASE WHEN MM.Abbrev LIKE 'PCR%'
                         THEN ISNULL(PCR.HClinCondWeight, 0)
                    END AS PCR_ComorbidWeight ,
                    CASE WHEN MM.Abbrev LIKE 'PCR%'
                         THEN ISNULL(PCR.SurgeryWeight, 0)
                    END AS PCR_SurgeryWeight ,
                    CASE WHEN MM.Abbrev LIKE 'PCR%'
                         THEN ISNULL(PCR.AdjProbability, 0)
                    END AS PCR_AdjustedProbability ,
                    CASE WHEN MM.Abbrev LIKE 'PCR%'
                         THEN ISNULL(PCR.Variance, 0)
                    END AS PCR_Variance
            --INTO    Temp.MemberExtractExport
            FROM    Result.MeasureDetail AS RMD
                    INNER JOIN #MeasureList AS t ON RMD.MeasureID = t.MeasureID
                                                    AND RMD.ResultTypeID = t.ResultTypeID
                    INNER JOIN Batch.DataSets AS DS ON RMD.DataSetID = DS.DataSetID
                    INNER JOIN Batch.DataOwners AS DO ON DS.OwnerID = DO.OwnerID
                    INNER JOIN Measure.Measures AS MM ON RMD.MeasureID = MM.MeasureID
                    INNER JOIN Measure.MeasureSets AS MMS ON MM.MeasureSetID = MMS.MeasureSetID
                    INNER JOIN Measure.Metrics AS MX ON RMD.MetricID = MX.MetricID AND MX.IsShown = 1
                    INNER JOIN Result.MeasureClasses AS RMCL ON MM.MeasClassID = RMCL.MeasClassID
                    LEFT OUTER JOIN ResultTypes AS RT ON RMD.ResultTypeID = RT.ResultTypeID
                    INNER JOIN Result.DataSetMemberKey AS RDSMK ON RMD.DataRunID = RDSMK.DataRunID
                                                              AND RMD.DataSetID = RDSMK.DataSetID
                                                              AND RMD.DSMemberID = RDSMK.DSMemberID
                    INNER JOIN Result.DataSetPopulationKey AS RDSPK ON RDSPK.DataRunID = RMD.DataRunID
                                                              AND RDSPK.PopulationID = RMD.PopulationID
                    LEFT OUTER JOIN Result.DataSetMemberProviderKey AS RDSMPK ON RMD.DataRunID = RDSMPK.DataRunID
                                                              AND RMD.DataSetID = RDSMPK.DataSetID
                                                              AND RMD.DSMemberID = RDSMPK.DSMemberID
                    LEFT OUTER JOIN Result.DataSetMedicalGroupKey AS RDSMGK ON RDSMPK.DataRunID = RDSMGK.DataRunID
                                                              AND RDSMPK.DataSetID = RDSMGK.DataSetID
                                                              AND RDSMPK.MedGrpID = RDSMGK.MedGrpID
                    LEFT OUTER JOIN Result.MeasureDetail_PCR AS PCR ON RMD.DataRunID = PCR.DataRunID
                                                              AND RMD.DataSetID = PCR.DataSetID
                                                              AND RMD.DSMemberID = PCR.DSMemberID
                                                              AND RMD.ResultRowID = PCR.SourceRowID
                    INNER JOIN Result.DataSetRunKey AS RDSRK ON RDSRK.DataRunID = RMD.DataRunID
            WHERE   ( RMD.DataRunID = @DataRunID )
                    AND ( ( RMD.IsDenominator = 1 )
                          OR ( RMD.IsDenominator IS NULL )
                        )
            ORDER BY [Population] ,
                    Measure ,
                    Metric ,
                    ProductLines ,
                    EventDate ,
                    MemberLastName ,
                    MemberFirstName ,
                    DateOfBirth;


    END

GO
GRANT VIEW DEFINITION ON  [Report].[GetMemberLevelExtractWithMedicalGroups] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMemberLevelExtractWithMedicalGroups] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMemberLevelExtractWithMedicalGroups] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMemberLevelExtractWithMedicalGroups] TO [Reports]
GO
