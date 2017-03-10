SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetSupplementalDataNumeratorSummary]
(
 @DataRunID int,
 @PopulationID int = NULL 
 )
AS
BEGIN
       
    DECLARE @ReplacePrefixCustomerMemberID varchar(20) = NULL;

    IF OBJECT_ID('tempdb..#Supplemental') IS NOT NULL
        DROP TABLE #Supplemental;

    SELECT  ResultRowID AS [Reference ID],
            MM.Abbrev AS Measure,
            MM.Descr AS [Measure Description],
            MX.Abbrev AS Metric,
            MX.Descr AS [Metric Description],
            REPLACE(RDSMK.CustomerMemberID,
                    ISNULL(@ReplacePrefixCustomerMemberID, ''), '') AS [Member ID],
            RDSMK.DisplayID AS [IMI Member ID],
            RDSMK.DOB AS [Date Of Birth],
            Member.ConvertGenderToMF(RDSMK.Gender) AS Gender,
            RDSMK.NameFirst AS [Member First Name],
            RDSMK.NameLast AS [Member Last Name],
            BDSS_NUM.Descr AS [Numerator Data Source],
            IDENTITY( int, 1, 1 ) AS [Row ID]
    INTO    #Supplemental
    FROM    Result.MeasureDetail AS RMD
            INNER JOIN Result.DataSetMemberKey AS RDSMK ON RMD.DataRunID = RDSMK.DataRunID AND
                                                           RMD.DSMemberID = RDSMK.DSMemberID
            LEFT OUTER JOIN Batch.DataSetSources AS BDSS_DEN ON RMD.DataSourceID = BDSS_DEN.DataSourceID
            LEFT OUTER JOIN Batch.DataSetSources AS BDSS_NUM ON RMD.SourceNumeratorSrc = BDSS_NUM.DataSourceID
            INNER JOIN Measure.Measures AS MM ON RMD.MeasureID = MM.MeasureID
            INNER JOIN Measure.Metrics AS MX ON RMD.MetricID = MX.MetricID
    WHERE   (BDSS_NUM.IsSupplemental = 1) AND
			(RMD.IsSupplementalNumerator = 1) AND
			(MM.IsEnabled = 1) AND
			(MX.IsEnabled = 1) AND
			(MX.IsShown = 1) AND
            (IsDenominator = 1) AND
            (RMD.ResultTypeID = 1) AND
            (RMD.DataRunID = @DataRunID) AND
            (RMD.PopulationID = @PopulationID)
    ORDER BY Measure,
            Metric,
            [Member Last Name],
            [Member First Name],
            [Member ID];

    SELECT  'All Data Sources'  AS [Numerator Data Source],
			Measure,
            [Measure Description],
            Metric,
            [Metric Description],
            COUNT(*) AS [Record Count],
			1 AS [Sort Order]
    FROM    #Supplemental
    GROUP BY Measure,
            [Measure Description],
            Metric,
            [Metric Description]
	UNION ALL
	SELECT [Numerator Data Source],
			Measure,
            [Measure Description],
            Metric,
            [Metric Description],
            COUNT(*) AS [Record Count],
			2 AS [Sort Order]
    FROM    #Supplemental
    GROUP BY [Numerator Data Source],
			Measure,
            [Measure Description],
            Metric,
            [Metric Description]
    ORDER BY [Sort Order], [Numerator Data Source], Metric;
END;

GO
GRANT VIEW DEFINITION ON  [Report].[GetSupplementalDataNumeratorSummary] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetSupplementalDataNumeratorSummary] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetSupplementalDataNumeratorSummary] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetSupplementalDataNumeratorSummary] TO [Reports]
GO
