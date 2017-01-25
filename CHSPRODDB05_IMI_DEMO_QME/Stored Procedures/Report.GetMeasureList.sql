SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetMeasureList]
(
 @MeasureSetID int = NULL,
 @MeasureSetTypeID smallint = NULL,
 @MeasurementYear smallint = NULL,
 @SortByDomain bit = NULL,
 @SortByHybrid bit = NULL,
 @SortByMeasureSet bit = NULL
 )
AS
BEGIN

    DECLARE @MeasureSets table
(
 MeasureSetID int NOT NULL,
 PRIMARY KEY (MeasureSetID)
);
    DECLARE @NDCMeasures table
(
 MeasureID int NOT NULL,
 MeasureSetID int NOT NULL,
 PRIMARY KEY (MeasureID)
);

    INSERT  INTO @MeasureSets
            SELECT  MeasureSetID
            FROM    Measure.MeasureSets AS MMS WITH (NOLOCK)
            WHERE   ((@MeasureSetID IS NULL) OR
                     (MMS.MeasureSetID = @MeasureSetID)
                    ) AND
                    ((@MeasurementYear IS NULL) OR
                     ((@MeasurementYear = -1) AND
                      (YEAR(MMS.DefaultSeedDate) IN (
                       SELECT DISTINCT TOP 1
                                YEAR(tMMS.DefaultSeedDate)
                       FROM     Measure.MeasureSets AS tMMS WITH (NOLOCK)
                       WHERE    (YEAR(tMMS.DefaultSeedDate) <= YEAR(GETDATE()) +
                                 CASE WHEN MONTH(GETDATE()) BETWEEN 1 AND 6
                                      THEN -1
                                      ELSE 0
                                 END)
                       ORDER BY 1 DESC))
                     ) OR
                     (YEAR(MMS.DefaultSeedDate) = @MeasurementYear)
                    ) AND
                    ((@MeasureSetTypeID IS NULL) OR
                     ((MMS.MeasureSetTypeID IN (1, 2)) AND
                      (@MeasureSetTypeID = -1)
                     )
                    );

    DECLARE @ProductLineC bigint; --Commercial
    DECLARE @ProductLineD bigint; --Medicaid
    DECLARE @ProductLineR bigint; --Medicare
    DECLARE @ProductLineS bigint; --SNP
    DECLARE @ProductLineM bigint; --Marketplace

    SELECT  @ProductLineC = BitValue
    FROM    Product.ProductLines
    WHERE   Abbrev = 'C';
    SELECT  @ProductLineD = BitValue
    FROM    Product.ProductLines
    WHERE   Abbrev = 'D';
    SELECT  @ProductLineR = BitValue
    FROM    Product.ProductLines
    WHERE   Abbrev = 'R';
    SELECT  @ProductLineS = BitValue
    FROM    Product.ProductLines
    WHERE   Abbrev = 'S';
    SELECT  @ProductLineM = BitValue
    FROM    Product.ProductLines
    WHERE   Abbrev = 'M';

    DECLARE @CaptureNDCs bit;

    IF OBJECT_ID('tempdb..#NDCMeasures') IS NOT NULL
        DROP TABLE #NDCMeasures;

    INSERT  INTO @NDCMeasures
            SELECT DISTINCT
                    MMV.MeasureID,
                    MM.MeasureSetID
            FROM    @MeasureSets AS t
                    CROSS APPLY Measure.GetMeasureEvents(DEFAULT, DEFAULT,
                                                         t.MeasureSetID) AS MMV
                    INNER JOIN Measure.Measures AS MM WITH (NOLOCK) ON MM.MeasureID = MMV.MeasureID AND
                                                              MM.IsEnabled = 1
                    INNER JOIN Measure.EventOptions AS MVO WITH (NOLOCK) ON MVO.EventID = MMV.EventID
                    INNER JOIN Measure.EventCriteriaCodes AS MVCC WITH (NOLOCK) ON MVCC.EventCritID = MVO.EventCritID
                    INNER JOIN Measure.Events AS MV WITH (NOLOCK) ON MV.EventID = MMV.EventID
                    INNER JOIN Measure.MeasureSets AS MMS WITH (NOLOCK) ON MMS.MeasureSetID = MM.MeasureSetID AND
                                                              MMS.MeasureSetID = MV.MeasureSetID AND
                                                              MMS.MeasureSetID = t.MeasureSetID AND
                                                              MMS.IsEnabled = 1
            WHERE   (MVCC.CodeTypeID IN (SELECT CodeTypeID
                                         FROM   Claim.CodeTypes WITH (NOLOCK)
                                         WHERE  CodeType = 'N'));

    WITH    MeasureProductLines
              AS (SELECT    SUM(PPL.BitValue) AS BitProductLines,
                            MMPL.MeasureID
                  FROM      Measure.MeasureProductLines AS MMPL
                            INNER JOIN Product.ProductLines AS PPL ON MMPL.ProductLineID = PPL.ProductLineID
                  GROUP BY  MMPL.MeasureID
                 )
        SELECT  MMS.Descr AS [Measure Set],
                ISNULL(MMCP.Descr + ': ', '') + MMC.Descr AS [Domain],
                MM.Abbrev AS Measure,
                MM.Descr AS [Measure Description],
                REPLACE(Product.ConvertBitProductLinesToDescrs(MPL.BitProductLines),
                        ' :: ', ', ') AS [Product Lines],
                CASE WHEN MM.IsHybrid = 1 THEN 'Y'
                     ELSE 'N'
                END AS Hybrid,
                CASE WHEN NDC.MeasureID IS NOT NULL THEN 'Y'
                     ELSE 'N'
                END AS NDC,
                CASE WHEN MPL.BitProductLines & @ProductLineC > 0 THEN 'Y'
                     ELSE 'N'
                END AS Commercial,
                CASE WHEN MPL.BitProductLines & @ProductLineD > 0 THEN 'Y'
                     ELSE 'N'
                END AS Medicaid,
                CASE WHEN MPL.BitProductLines & @ProductLineR > 0 THEN 'Y'
                     ELSE 'N'
                END AS Medicare,
                CASE WHEN MPL.BitProductLines & @ProductLineS > 0 THEN 'Y'
                     ELSE 'N'
                END AS SNP,
                CASE WHEN MPL.BitProductLines & @ProductLineM > 0 THEN 'Y'
                     ELSE 'N'
                END AS Marketplace,
				MM.CertDate AS [Date Certified]
        FROM    Measure.Measures AS MM WITH (NOLOCK)
                CROSS APPLY (SELECT TOP 1
                                    tMX.MetricID
                             FROM   Measure.Metrics AS tMX WITH (NOLOCK)
                             WHERE  tMX.MeasureID = MM.MeasureID AND
                                    tMX.IsEnabled = 1
                            ) AS MX
                LEFT OUTER JOIN @NDCMeasures AS NDC ON NDC.MeasureID = MM.MeasureID
                INNER JOIN Measure.MeasureClasses AS MMC WITH (NOLOCK) ON MM.MeasClassID = MMC.MeasClassID
                LEFT OUTER JOIN Measure.MeasureClasses AS MMCP WITH (NOLOCK) ON MMC.ParentID = MMCP.MeasClassID
                INNER JOIN Measure.MeasureSets AS MMS WITH (NOLOCK) ON MM.MeasureSetID = MMS.MeasureSetID
                INNER JOIN MeasureProductLines AS MPL WITH (NOLOCK) ON MM.MeasureID = MPL.MeasureID
        WHERE   (MMS.MeasureSetID IN (SELECT    MeasureSetID
                                      FROM      @MeasureSets)) AND
                (MM.IsEnabled = 1) AND
                (MMS.IsEnabled = 1)
        ORDER BY CASE WHEN @SortByMeasureSet = 1 THEN MMS.Descr
                 END ASC,
                CASE WHEN @SortByDomain = 1 THEN MMCP.MeasClassID
                END ASC,
                CASE WHEN @SortByDomain = 1 THEN MMC.MeasClassID
                END ASC,
                CASE WHEN @SortByHybrid = 1 THEN MM.IsHybrid
                END DESC,
                MM.Abbrev ASC

END
GO
GRANT EXECUTE ON  [Report].[GetMeasureList] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureList] TO [Reports]
GO
