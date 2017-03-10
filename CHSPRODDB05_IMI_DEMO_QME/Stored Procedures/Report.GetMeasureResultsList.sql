SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Report].[GetMeasureResultsList]
(
 @DataRunID int,				--The data run to retrieve
 @PopulationID int = NULL,		--If null, returns all populations.  If specified, only returns the specified population.
 @ProductLineID int = NULL,		--1 = Commercial, 2 = Medicaid, 3 = Medicare, 4 = SNP
 @GroupByPayer bit = 0,			--Allows the Payer and Payer Description field to be grouped
 @GroupByEnrolled bit = 0
 )
AS
BEGIN

    DECLARE @DataSetID int;
    DECLARE @MeasureSetID int;
    DECLARE @SeedDate datetime;
    DECLARE @BitProductLines bigint;

    SELECT  @BitProductLines = BitValue
    FROM    Product.ProductLines
    WHERE   ProductLineID = @ProductLineID;

    SELECT  @DataSetID = DataSetID,
            @MeasureSetID = MeasureSetID,
            @SeedDate = SeedDate
    FROM    Batch.DataRuns
    WHERE   DataRunID = @DataRunID;

    IF OBJECT_ID('tempdb..#Enrolled') IS NOT NULL
        DROP TABLE #Enrolled;

    IF OBJECT_ID('tempdb..#Results') IS NOT NULL
        DROP TABLE #Results;

    IF OBJECT_ID('tempdb..#MeasureDefaultResultType') IS NOT NULL
        DROP TABLE #MeasureDefaultResultType;

    SELECT DISTINCT
            DSMemberID
    INTO    #Enrolled
    FROM    Member.Enrollment AS MN WITH (NOLOCK)
    WHERE   (@GroupByEnrolled = 1) AND
            (DataSetID = @DataSetID) AND
            (@SeedDate BETWEEN BeginDate
                       AND     ISNULL(EndDate, GETDATE()))

    CREATE UNIQUE CLUSTERED INDEX IX_#Enrolled ON #Enrolled (DSMemberID);

    SELECT  *
    INTO    #MeasureDefaultResultType
    FROM    Result.GetDefaultMeasureResultTypes(@DataRunID, DEFAULT);

    --CREATE UNIQUE CLUSTERED INDEX IX_#MeasureDefaultResultType ON #MeasureDefaultResultType (MeasureID, PopulationID);

    SELECT  MIN(RDSPK.PopulationNum) AS PopulationNum,
            MIN(RDSPK.Descr) AS PopulationDescr,
            REPLACE(Product.ConvertBitProductLinesToDescrs(dbo.BitwiseOr(RMD.BitProductLines)),
                    ' :: ', '/') AS ProductLines,
            CASE WHEN @GroupByPayer = 1 THEN MIN(PP.Abbrev)
                 WHEN @GroupByPayer = 0 AND
                      COUNT(DISTINCT RMD.PayerID) = 1 THEN MIN(PP.Abbrev)
                 WHEN @GroupByPayer = 0 AND
                      COUNT(DISTINCT RMD.PayerID) > 1 THEN '(multiple)'
                 ELSE '(n/a)'
            END AS Payer,
            CASE WHEN @GroupByPayer = 1 THEN MIN(PP.Descr)
                 WHEN @GroupByPayer = 0 AND
                      COUNT(DISTINCT RMD.PayerID) = 1 THEN MIN(PP.Descr)
                 WHEN @GroupByPayer = 0 AND
                      COUNT(DISTINCT RMD.PayerID) > 1 THEN '(multiple)'
                 ELSE '(n/a)'
            END AS PayerDescription,
            MIN(MMX.Abbrev) AS Measure,
            MIN(MMX.Descr) AS MeasureDescription,
            MIN(RRT.Descr) AS ResultType,
            MIN(MXX.Abbrev) AS Metric,
            MIN(MXX.Descr) AS MetricDescription,
            CASE WHEN @GroupByEnrolled = 0 THEN NULL
                 WHEN N.DSMemberID IS NOT NULL THEN 1
                 ELSE 0
            END IsEnrolled,
            COUNT(*) AS CountRecords,
            SUM(CONVERT(bigint, IsDenominator)) AS IsDenominator,
            SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 AND
                                          IsExclusion = 0 THEN IsNumerator
                                     WHEN IsDenominator IS NOT NULL THEN 0
                                END)) AS IsNumerator,
            SUM(CONVERT(bigint, IsExclusion)) AS IsExclusion
    INTO    #Results
    FROM    Result.MeasureDetail AS RMD WITH (NOLOCK)
            LEFT OUTER JOIN Result.DataSetPopulationKey AS RDSPK ON RDSPK.DataRunID = RMD.DataRunID AND
                                                              RDSPK.PopulationID = RMD.PopulationID
            INNER JOIN Result.ResultTypes AS RRT ON RRT.ResultTypeID = RMD.ResultTypeID
            INNER JOIN Product.Payers AS PP ON RMD.PayerID = PP.PayerID
            LEFT OUTER JOIN #Enrolled AS N ON RMD.DSMemberID = N.DSMemberID
            INNER JOIN Measure.Metrics AS MX WITH (NOLOCK) ON RMD.MetricID = MX.MetricID AND
                                                              MX.IsShown = 1
            INNER JOIN Measure.MetricXrefs AS MXX WITH (NOLOCK) ON RMD.MetricXrefID = MXX.MetricXrefID
            INNER JOIN Measure.MeasureXrefs AS MMX WITH (NOLOCK) ON RMD.MeasureXrefID = MMX.MeasureXrefID
            INNER JOIN #MeasureDefaultResultType AS t ON t.DataRunID = RMD.DataRunID AND
                                                         t.MeasureID = RMD.MeasureID AND
                                                         t.ResultTypeID = RMD.ResultTypeID
    WHERE   (RMD.DataRunID = @DataRunID) AND
            ((@PopulationID IS NULL) OR
             (RMD.PopulationID = @PopulationID)
            ) AND
            (RMD.BitProductLines & @BitProductLines > 0 OR
             @ProductLineID IS NULL
            )
    GROUP BY RMD.PopulationID,
            RMD.MeasureXrefID,
            RMD.MetricXrefID,
            CASE WHEN @GroupByPayer = 1 THEN RMD.PayerID
            END,
            CASE WHEN @GroupByEnrolled = 0 THEN NULL
                 WHEN N.DSMemberID IS NOT NULL THEN 1
                 ELSE 0
            END

    SELECT  PopulationNum AS [Population],
            PopulationDescr AS [Population Description],
            ProductLines AS [Product Line(s)],
            Payer,
            PayerDescription AS [Payer Description],
            Measure,
            MeasureDescription AS [Measure Description],
            Metric,
            MetricDescription AS [Metric Description],
            ResultType AS [Result Type],
            ISNULL(CONVERT(varchar(8), dbo.ConvertBitToYN(IsEnrolled)),
                   '(n/a)') AS [Enrolled],
            CountRecords AS [Records],
            IsDenominator AS [Denominator],
            IsNumerator AS [Numerator],
            IsExclusion AS [Exclusion],
            CASE WHEN IsDenominator IS NOT NULL
                 THEN ISNULL(ROUND(CONVERT(decimal(36, 12), IsNumerator) /
                                   CONVERT(decimal(36, 12), NULLIF(IsDenominator,
                                                              0)), 4), 0)
            END AS [Score]
    FROM    #Results
    ORDER BY [Population],
            Enrolled DESC,
            Measure,
            Metric,
            Payer;

END



GO
GRANT VIEW DEFINITION ON  [Report].[GetMeasureResultsList] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMeasureResultsList] TO [db_executer]
GO
GRANT ALTER ON  [Report].[GetMeasureResultsList] TO [INTERNAL\brandon.rodman]
GO
GRANT EXECUTE ON  [Report].[GetMeasureResultsList] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureResultsList] TO [Reports]
GO
