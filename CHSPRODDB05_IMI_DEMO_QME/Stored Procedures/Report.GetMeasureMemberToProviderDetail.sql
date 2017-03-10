SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetMeasureMemberToProviderDetail]
(
 @DataRunID int,
 @MeasureID int,
 @MetricID int = NULL,
 @PopulationID int = NULL,
 @ProductLineID int = NULL,
 @ResultTypeID tinyint = NULL
 )
AS
BEGIN
    SET NOCOUNT ON;

    IF @ResultTypeID = 255 OR
        @ResultTypeID IS NULL
        SET @ResultTypeID = 1;

    DECLARE @BitProductLines AS bigint;
    SELECT  @BitProductLines = SUM(BitValue)
    FROM    Product.ProductLines
    WHERE   ((@ProductLineID IS NULL) OR
             (ProductLineID = @ProductLineID)
            );

    SELECT  RMD.ResultRowGuid AS [Record ID],
            RDSPOPK.PopulationNum AS [Population],
            RDSPOPK.Descr AS [Population Description],
            MM.Abbrev AS Measure,
            MM.Descr AS [Measure Description],
            MX.Abbrev AS Metric,
            MX.Descr AS [Metric Description],
            RDSMK.CustomerMemberID AS [Member ID],
            RDSMK.DisplayID AS [IMI Member ID],
            RDSMK.NameLast AS [Member Last Name],
            RDSMK.NameFirst AS [Member First Name],
            RDSMK.DOB AS [Date of Birth],
            Member.ConvertGenderToMF(RMD.Gender) AS Gender,
            RMD.KeyDate AS [Key Event Date],
            RRT.Descr AS [Result Type],
            RMD.IsDenominator AS [Denominator],
            RMD.IsNumerator AS [Numerator],
            RMD.IsExclusion AS Exclusion,
            RDSMPK.RankOrder AS [Priority Order],
            RDSPK.CustomerProviderID AS [Provider ID],
            RDSPK.DisplayID AS [IMI Provider ID],
            RDSPK.ProviderName AS [Provider Name],
            REPLACE(Provider.ConvertBitSpecialtiesToDescr(RDSPK.BitSpecialties),
                    ' :: ', ', ') AS [Provider Specialties],
            ISNULL(NULLIF(REPLACE(Provider.ConvertBitSpecialtiesToDescr(RDSMPK.BitSpecialties),
                                  ' :: ', ', '), ''), '(n/a)') AS [Priority Specialties]
    FROM    Result.MeasureDetail AS RMD WITH (NOLOCK)
            INNER JOIN Measure.Metrics AS MX WITH (NOLOCK) ON MX.MetricID = RMD.MetricID
            INNER JOIN Measure.Measures AS MM WITH (NOLOCK) ON MM.MeasureID = RMD.MeasureID
            INNER JOIN Result.DataSetPopulationKey AS RDSPOPK ON RDSPOPK.DataRunID = RMD.DataRunID AND
                                                              RDSPOPK.PopulationID = RMD.PopulationID
            INNER JOIN Result.ResultTypes AS RRT ON RRT.ResultTypeID = RMD.ResultTypeID
            LEFT OUTER JOIN Result.DataSetMemberKey AS RDSMK WITH (NOLOCK) ON RDSMK.DataRunID = RMD.DataRunID AND
                                                              RDSMK.DSMemberID = RMD.DSMemberID
            LEFT OUTER JOIN Result.DataSetMeasureProviderKey AS RDSMPK WITH (NOLOCK) ON RDSMPK.DataRunID = RMD.DataRunID AND
                                                              RDSMPK.DSMemberID = RMD.DSMemberID AND
                                                              RDSMPK.KeyDate = RMD.KeyDate AND
                                                              RDSMPK.MeasureID = RMD.MeasureID
            LEFT OUTER JOIN Result.DataSetProviderKey AS RDSPK WITH (NOLOCK) ON RDSPK.DataRunID = RDSMPK.DataRunID AND
                                                              RDSPK.DSProviderID = RDSMPK.DSProviderID
    WHERE   (RMD.DataRunID = @DataRunID) AND
            (RMD.IsDenominator = 1 OR
             RMD.IsExclusion = 1
            ) AND
            (RMD.BitProductLines & @BitProductLines > 0 OR
             RMD.BitProductLines = 0 AND
             @BitProductLines = 0 OR
             @ProductLineID IS NULL
            ) AND
            ((@PopulationID IS NULL) OR
             (RMD.PopulationID = @PopulationID)
            ) AND
            ((@MeasureID IS NULL) OR
             (RMD.MeasureID = @MeasureID)
            ) AND
            ((@MetricID IS NULL) OR
             (RMD.MetricID = @MetricID)
            ) AND
            ((@ResultTypeID IS NULL) OR
             (RMD.ResultTypeID = @ResultTypeID)
            )
    ORDER BY [Population],
            [Member Last Name],
            [Member First Name],
            [Date of Birth],
            Gender,
            [Measure],
            [Metric],
            [Key Event Date],
            [Result Type],
            [Priority Order],
            [Provider ID];
END;
	


GO
GRANT VIEW DEFINITION ON  [Report].[GetMeasureMemberToProviderDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMeasureMemberToProviderDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMeasureMemberToProviderDetail] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureMemberToProviderDetail] TO [Reports]
GO
