SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/29/2015
-- Description:	Returns the detail-level results for the RRU measures.
-- =============================================
CREATE PROCEDURE [Report].[GetRRUDetailResults]
    (
      @DataRunID INT,
      @PopulationID INT = NULL ,
      @MetricID INT = NULL ,
      @MeasureID INT = NULL ,
      @ProductLineID INT = NULL
    )
AS
    BEGIN

        DECLARE @MeasureYear SMALLINT;
        SELECT  @MeasureYear = YEAR(MMS.DefaultSeedDate)
        FROM    Measure.MeasureSets AS MMS
                INNER JOIN Batch.DataRuns AS BDR ON MMS.MeasureSetID = BDR.MeasureSetID
        WHERE   BDR.DataRunID = @DataRunID;

        IF OBJECT_ID('tempdb..#RRUAgeBands') IS NOT NULL
            DROP TABLE #RRUAgeBands;

        WITH    RRUAgeBands ( Measure, FromAge, ToAge, Abbrev )
                  AS ( SELECT   'RDI' ,
                                18 ,
                                44 ,
                                '1844'
                       UNION
                       SELECT   'RDI' ,
                                45 ,
                                54 ,
                                '4554'
                       UNION
                       SELECT   'RDI' ,
                                55 ,
                                64 ,
                                '5564'
                       UNION
                       SELECT   'RDI' ,
                                65 ,
                                75 ,
                                '6575'
                       UNION
                       SELECT   'RCA' ,
                                18 ,
                                44 ,
                                '1844'
                       UNION
                       SELECT   'RCA' ,
                                45 ,
                                54 ,
                                '4554'
                       UNION
                       SELECT   'RCA' ,
                                55 ,
                                64 ,
                                '5564'
                       UNION
                       SELECT   'RCA' ,
                                65 ,
                                75 ,
                                '6575'
                       UNION
                       SELECT   'RCO' ,
                                42 ,
                                44 ,
                                '4244'
                       UNION
                       SELECT   'RCO' ,
                                45 ,
                                64 ,
                                '4564'
                       UNION
                       SELECT   'RCO' ,
                                65 ,
                                74 ,
                                '6574'
                       UNION
                       SELECT   'RCO' ,
                                75 ,
                                255 ,
                                '75+'
                       UNION
                       SELECT   'RAS' ,
                                5 ,
                                17 ,
                                '0517'
                       UNION
                       SELECT   'RAS' ,
                                18 ,
                                44 ,
                                '1844'
                       UNION
                       SELECT   'RAS' ,
                                45 ,
                                54 ,
                                '4554'
                       UNION
                       SELECT   'RAS' ,
                                55 ,
                                64 ,
                                '5564'
                       UNION
                       SELECT   'RHY' ,
                                18 ,
                                44 ,
                                '1844'
                       UNION
                       SELECT   'RHY' ,
                                45 ,
                                54 ,
                                '4554'
                       UNION
                       SELECT   'RHY' ,
                                55 ,
                                64 ,
                                '5564'
                       UNION
                       SELECT   'RHY' ,
                                65 ,
                                85 ,
                                '6585'
                     )
            SELECT  *
            INTO    #RRUAgeBands
            FROM    RRUAgeBands;

        CREATE UNIQUE CLUSTERED INDEX IX_#RRUAgeBands ON #RRUAgeBands (Measure, FromAge, ToAge);
        CREATE UNIQUE NONCLUSTERED INDEX IX_#RRUAgeBands2 ON #RRUAgeBands (Measure, Abbrev);

        IF OBJECT_ID('tempdb..#RRUBaseResults') IS NOT NULL
            DROP TABLE #RRUBaseResults;

        SELECT  RMD.BatchID ,
                RMD.BitProductLines ,
                RMD.DataRunID ,
                RMD.DataSetID ,
                RMD.DataSourceID ,
                RMD.DSEntityID ,
                RMD.DSMemberID ,
                RMD.EnrollGroupID ,
                RMD.EntityID ,
                RMD.ExclusionTypeID ,
                RMD.IsDenominator ,
                RMD.IsExclusion ,
                RMD.IsIndicator ,
                RMD.IsNumerator ,
                RMD.IsNumeratorAdmin ,
                RMD.IsNumeratorMedRcd ,
                RMD.KeyDate ,
                MM.Abbrev AS Measure ,
                MM.MeasureGuid ,
                RMD.MeasureID ,
                RMD.MeasureXrefID ,
                MX.Abbrev AS Metric ,
                RMD.MetricID ,
                RMD.MetricXrefID ,
                RMD.PayerID ,
                RMD.PopulationID ,
                RMD.ResultRowGuid ,
                RMD.ResultRowID ,
                RRU.Age ,
                RRU.CostEMInpatient ,
                RRU.CostEMInpatientCapped ,
                RRU.CostEMOutpatient ,
                RRU.CostEMOutpatientCapped ,
                RRU.CostImaging ,
                RRU.CostImagingCapped ,
                RRU.CostInpatient ,
                RRU.CostInpatientCapped ,
                RRU.CostLab ,
                RRU.CostLabCapped ,
                RRU.CostPharmacy ,
                RRU.CostPharmacyCapped ,
                RRU.CostProcInpatient ,
                RRU.CostProcInpatientCapped ,
                RRU.CostProcOutpatient ,
                RRU.CostProcOutpatientCapped ,
                RRU.DaysAcuteInpatient ,
                RRU.DaysAcuteInpatientNotSurg ,
                RRU.DaysAcuteInpatientSurg ,
                RRU.DaysNonacuteInpatient ,
                RRU.DemoWeight ,
                RRU.FreqAcuteInpatient ,
                RRU.FreqAcuteInpatientNotSurg ,
                RRU.FreqAcuteInpatientSurg ,
                RRU.FreqED ,
                RRU.FreqNonacuteInpatient ,
                RRU.FreqPharmG1 ,
                RRU.FreqPharmG2 ,
                RRU.FreqPharmN1 ,
                RRU.FreqPharmN2 ,
                RRU.FreqProcCABG ,
                RRU.FreqProcCAD ,
                RRU.FreqProcCardiacCath ,
                RRU.FreqProcCAS ,
                RRU.FreqProcCAT ,
                RRU.FreqProcEndarter ,
                RRU.FreqProcPCI ,
                RRU.Gender ,
                RRU.HClinCondWeight ,
                RRU.MM ,
                RRU.MMP ,
                NRRC.Abbrev AS RiskCtgy ,
                RRU.RiskCtgyID ,
                RRU.TotalWeight
        INTO    #RRUBaseResults
        FROM    Result.MeasureDetail AS RMD WITH(NOLOCK)
                INNER JOIN Measure.Metrics AS MX WITH(NOLOCK) ON RMD.MetricID = MX.MetricID
                INNER JOIN Measure.Measures AS MM WITH(NOLOCK) ON RMD.MeasureID = MM.MeasureID
                INNER JOIN Measure.MeasureClasses AS MMC WITH(NOLOCK) ON MM.MeasClassID = MMC.MeasClassID
                                                            AND MMC.Abbrev = 'RRU'
                LEFT OUTER JOIN Result.MeasureDetail_RRU AS RRU WITH(NOLOCK) ON RMD.ResultRowGuid = RRU.SourceRowGuid
                                                              AND RMD.BatchID = RRU.BatchID
                                                              AND RMD.DataRunID = RRU.DataRunID
                                                              AND RMD.DataSetID = RRU.DataSetID
                                                              AND RMD.DSMemberID = RRU.DSMemberID
                LEFT OUTER JOIN Ncqa.RRU_RiskCategories AS NRRC WITH(NOLOCK) ON RRU.RiskCtgyID = NRRC.RiskCtgyID
        WHERE   RMD.DataRunID = @DataRunID
                AND RMD.PopulationID = @PopulationID
                AND ( @MetricID IS NULL
                      OR MX.MetricID = @MetricID
                    )
                AND ( @MeasureID IS NULL
                      OR MM.MeasureID = @MeasureID
                    )

        CREATE UNIQUE CLUSTERED INDEX IX_#RRUBaseResults ON #RRUBaseResults (ResultRowID);
        CREATE NONCLUSTERED INDEX IX_#RRUBaseResults2 ON #RRUBaseResults (Measure, RiskCtgy, Age, Gender);

        IF OBJECT_ID('tempdb..#RRUIdssBase') IS NOT NULL
            DROP TABLE #RRUIdssBase;

        WITH    MeasureStrata
                  AS ( SELECT   RAB.Abbrev AS AgeBand ,
                                RAB.FromAge ,
                                RAB.ToAge ,
                                MG.Gender ,
                                LOWER(MG.Abbrev) AS GenderAbbrev ,
                                MM.Abbrev AS Measure ,
								MM.Descr AS MeasureDescr,
                                MM.MeasureID ,
                                NRRC.Abbrev AS RiskCtgy ,
                                NRRC.RiskCtgyID
                       FROM     Measure.Measures AS MM WITH(NOLOCK)
                                INNER JOIN #RRUAgeBands AS RAB WITH(NOLOCK) ON MM.Abbrev = RAB.Measure
                                INNER JOIN Batch.DataRuns AS BDR WITH(NOLOCK) ON MM.MeasureSetID = BDR.MeasureSetID
                                                              AND BDR.DataRunID = @DataRunID
                                INNER JOIN Measure.MeasureClasses AS MMC WITH(NOLOCK) ON MM.MeasClassID = MMC.MeasClassID
                                INNER JOIN Member.Genders AS MG WITH(NOLOCK) ON MG.Gender BETWEEN 0 AND 1
                                CROSS JOIN Ncqa.RRU_RiskCategories AS NRRC WITH(NOLOCK)
                       WHERE    MMC.Abbrev = 'RRU'
                     )
            SELECT  t.ResultRowGuid ,
                    t.DataRunID ,
                    t.DSMemberID ,
                    MS.Measure ,
					MS.MeasureDescr,
                    MS.MeasureID ,
                    MS.RiskCtgy ,
                    MS.RiskCtgyID ,
                    MS.AgeBand ,
                    MS.Gender ,
                    MS.GenderAbbrev ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.CostInpatientCapped), 0),
                                       0)) AS CostInpatientCapped ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.CostEMInpatientCapped), 0),
                                       0)) AS CostEMInpatientCapped ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.CostEMOutpatientCapped), 0),
                                       0)) AS CostEMOutpatientCapped ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.CostProcInpatientCapped),
                                              0), 0)) AS CostProcInpatientCapped ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.CostProcOutpatientCapped),
                                              0), 0)) AS CostProcOutpatientCapped ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.CostPharmacyCapped), 0), 0)) AS CostPharmacyCapped ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.CostImagingCapped), 0), 0)) AS CostImagingCapped ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.CostLabCapped), 0), 0)) AS CostLabCapped ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqProcCABG), 0), 0)) AS FreqProcCABG ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqProcCAD), 0), 0)) AS FreqProcCAD ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqProcCardiacCath), 0),
                                       0)) AS FreqProcCardiacCath ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqProcCAT), 0), 0)) AS FreqProcCAT ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqProcCAS), 0), 0)) AS FreqProcCAS ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqProcEndarter), 0), 0)) AS FreqProcEndarter ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqED), 0), 0)) AS FreqED ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.DaysAcuteInpatientNotSurg),
                                              0), 0)) AS DaysAcuteInpatientNotSurg ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqAcuteInpatientNotSurg),
                                              0), 0)) AS FreqAcuteInpatientNotSurg ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.DaysAcuteInpatientSurg), 0),
                                       0)) AS DaysAcuteInpatientSurg ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqAcuteInpatientSurg), 0),
                                       0)) AS FreqAcuteInpatientSurg ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.DaysNonacuteInpatient), 0),
                                       0)) AS DaysNonacuteInpatient ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqNonacuteInpatient), 0),
                                       0)) AS FreqNonacuteInpatient ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqProcPCI), 0), 0)) AS FreqProcPCI ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.MM), 0), 0)) AS MM ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.MMP), 0), 0)) AS MMP ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqPharmG1), 0), 0)) AS FreqPharmG1 ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqPharmG2), 0), 0)) AS FreqPharmG2 ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqPharmN1), 0), 0)) AS FreqPharmN1 ,
                    CONVERT(INT, ROUND(ISNULL(SUM(t.FreqPharmN2), 0), 0)) AS FreqPharmN2 ,
                    CONVERT(INT, ROUND(ISNULL(SUM(CONVERT(INT, t.IsDenominator)),
                                              0), 0)) AS IsDenominator ,
                    CONVERT(INT, ROUND(ISNULL(SUM(CONVERT(INT, t.IsIndicator)),
                                              0), 0)) AS IsIndicator ,
                    IDENTITY( INT, 1, 1 ) AS RowID
            INTO    #RRUIdssBase
            FROM    #RRUBaseResults AS t
                    RIGHT OUTER JOIN MeasureStrata AS MS ON t.Gender = MS.Gender
                                                            AND t.Measure = MS.Measure
                                                            AND t.MeasureID = MS.MeasureID
                                                            AND t.RiskCtgy = MS.RiskCtgy
                                                            AND t.RiskCtgyID = MS.RiskCtgyID
                                                            AND t.Age BETWEEN MS.FromAge AND MS.ToAge
                                                            AND t.IsDenominator = 1
            GROUP BY MS.Measure ,
					MS.MeasureDescr,
                    MS.MeasureID ,
                    MS.RiskCtgy ,
                    MS.RiskCtgyID ,
                    MS.AgeBand ,
                    MS.Gender ,
                    MS.GenderAbbrev,
					t.ResultRowGuid,
					t.DataRunID,
					t.DSMemberID,
					t.ResultRowGuid
            ORDER BY MS.Measure ,
                    MS.RiskCtgyID ,
                    MS.AgeBand ,
                    MS.Gender DESC

        SELECT  Measure ,
				MeasureDescr AS [Measure Description],
				--MeasureID,
                t.ResultRowGuid AS [Record ID] ,
                RDSMK.CustomerMemberID AS [Member ID] ,
                RDSMK.DisplayID AS [IMI Member ID] ,
                RDSMK.NameLast AS [Member Last Name] ,
                RDSMK.NameFirst AS [Member First Name] ,
                RDSMK.DOB AS [Member DOB] ,
                Member.ConvertGenderToMF(RDSMK.Gender) AS [Member Gender] ,
                RDSMK.SsnDisplay AS [Member SSN] ,
                CostInpatientCapped AS [Cost - Inpatient] ,
                CostEMInpatientCapped [Cost - E & M, Inpatient] ,
                CostEMOutpatientCapped AS [Cost - E & M, Outpatient] ,
                CostProcInpatientCapped AS [Cost - Procedure, Inpatient] ,
                CostProcOutpatientCapped AS [Cost - Procedure, Outpatient] ,
                CostPharmacyCapped AS [Cost - Pharmacy] ,
                CostImagingCapped AS [Cost - Imaging] ,
                CostLabCapped AS [Cost - Lab] ,
                FreqProcCABG AS [Frequency - Procedure, CABG] ,
                FreqProcCAD AS [Frequency - Procedure, CAD] ,
                FreqProcCardiacCath AS [Frequency - Cardiac Cath] ,
                FreqProcCAT AS [Frequency - CAT] ,
                FreqProcCAS AS [Frequency - CAS] ,
                FreqProcEndarter AS [Frequency - Endarter] ,
                FreqProcPCI AS [Frequency - PCI] ,
                FreqED AS [Frequency - ED] ,
                DaysAcuteInpatientNotSurg AS [Days - Inpatient, Medicine] ,
                FreqAcuteInpatientNotSurg AS [Qty - Inpatient, Medicine] ,
                DaysAcuteInpatientSurg AS [Days - Inpatient, Surgery] ,
                FreqAcuteInpatientSurg AS [Qty - Inpatient, Surgery] ,
                DaysNonacuteInpatient AS [Days - Inpatient, Nonacute] ,
                FreqNonacuteInpatient AS [Qty - Inpatient, Nonacute] ,
                MM AS [Mbr Months - Med] ,
                MMP AS [Mbr Months - Pharm] ,
                FreqPharmG1 AS [Frequency - Pharm, Generic Only] ,
                FreqPharmG2 AS [Frequency - Pharm, Generic/Name Brand Available] ,
                FreqPharmN1 AS [Frequency - Pharm, Name Brand Only] ,
                FreqPharmN2 AS [Frequency - Pharm, Name Brand/Generic Available] ,
                IsDenominator AS Denominator ,
                IsIndicator AS Exclusions
        FROM    #RRUIdssBase AS t
                INNER JOIN Result.DataSetMemberKey AS RDSMK WITH(NOLOCK) ON RDSMK.DataRunID = t.DataRunID
                                                              AND RDSMK.DSMemberID = t.DSMemberID
        ORDER BY [Measure] ,
                [Member Last Name] ,
                [Member First Name] ,
                [Member DOB];
				

    END

GO
GRANT VIEW DEFINITION ON  [Report].[GetRRUDetailResults] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetRRUDetailResults] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetRRUDetailResults] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetRRUDetailResults] TO [Reports]
GO
