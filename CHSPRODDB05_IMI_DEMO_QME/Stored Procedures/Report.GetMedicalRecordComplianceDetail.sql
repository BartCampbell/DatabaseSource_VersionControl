SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetMedicalRecordComplianceDetail]
    (
      @DataRunID INT ,
      @PopulationID INT = NULL ,
      @MeasureID INT = NULL ,
      @MetricID INT = NULL
    )
AS
    BEGIN

        SELECT  RDSMK.CustomerMemberID AS [Member ID] ,
                RDSMK.DisplayID AS [IMI Member ID] ,
                RDSMK.NameDisplay AS [Member Name] ,
                RDSMK.DOB AS [Date of Birth] ,
                MM.Abbrev AS [Measure] ,
                MM.Descr AS [Measure Description] ,
                MX.Abbrev AS Metric ,
                MX.Descr AS [Metric Description] ,
                RMD.KeyDate AS [Event Date] ,
                RMD.IsDenominator AS [Denominator] ,
                RMD.IsNumeratorAdmin AS [Compliant, Admin] ,
                RMD.IsNumeratorMedRcd AS [Compliant, Med Rcd] ,
                RMD.IsNumerator AS [Compliant, Hybrid]
        FROM    Result.MeasureDetail AS RMD WITH ( NOLOCK )
                INNER JOIN Result.DataSetMemberKey AS RDSMK WITH ( NOLOCK ) ON RMD.DataRunID = RDSMK.DataRunID
                                                              AND RMD.DataSetID = RDSMK.DataSetID
                                                              AND RMD.DSMemberID = RDSMK.DSMemberID
                INNER JOIN Measure.Measures AS MM WITH ( NOLOCK ) ON RMD.MeasureID = MM.MeasureID
                INNER JOIN Measure.Metrics AS MX WITH ( NOLOCK ) ON RMD.MetricID = MX.MetricID
        WHERE   ( RMD.DataRunID = @DataRunID )
                AND ( RMD.PopulationID = @PopulationID )
                AND ( RMD.ResultTypeID = 3 )
                AND ( RMD.IsDenominator = 1 )
                AND ( RMD.IsNumeratorMedRcd = 1 )
                AND ( RMD.IsNumerator = 1 )
                AND ( RMD.IsExclusion = 0 )
                AND ( ( @MeasureID IS NULL )
                      OR ( RMD.MeasureID = @MeasureID )
                    )
                AND ( ( @MetricID IS NULL )
                      OR ( RMD.MetricID = @MetricID )
                    )
        ORDER BY Metric ,
                [Member ID] ,
                [Event Date];  

    END


GO
GRANT VIEW DEFINITION ON  [Report].[GetMedicalRecordComplianceDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMedicalRecordComplianceDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMedicalRecordComplianceDetail] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMedicalRecordComplianceDetail] TO [Reports]
GO
