SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetDDENumeratorEvents]
    (
      @DataRunID INT = NULL ,
      @PopulationID INT = NULL ,
      @ProductLineID INT = NULL
    )
AS
    BEGIN

---------------------------------------------------------------------------------------

        --SELECT  MeasureSetDescr
        --FROM    Result.DataSetRunKey
        --WHERE   DataRunID = @DataRunID;

---------------------------------------------------------------------------------------

        DECLARE @MapTypeN INT;
        SELECT  @MapTypeN = MapTypeID
        FROM    Measure.MappingTypes
        WHERE   Descr = 'Numerator';

        DECLARE @BitProductLines BIGINT;
        SELECT  @BitProductLines = BitValue
        FROM    Product.ProductLines
        WHERE   ProductLineID = @ProductLineID;

        SELECT  RDSRK.MeasureSetDescr AS [Data Run] ,
                RDSPK.Descr AS [Population] ,
                MM.Abbrev AS Measure ,
                MX.Abbrev AS Metric ,
                MX.Descr AS [Metric Description] ,
                RDSMK.CustomerMemberID AS [Member ID] ,
                RDSMK.DisplayID AS [IMI Member ID] ,
                RDSMK.NameLast AS [Last Name] ,
                RDSMK.NameFirst AS [First Name] ,
                RDSMK.DOB AS [Date of Birth] ,
                Member.ConvertGenderToMF(RDSMK.Gender) AS [Gender] ,
                RDSMGK.RegionName AS [Region] ,
                RDSMGK.SubRegionName AS [Sub Region] ,
                RDSMGK.MedGrpName AS [Medical Group] ,
                RMD.KeyDate AS [Key Event Date] ,
                RMD.IsDenominator AS Denominator ,
                RMD.IsNumerator AS Numerator ,
                RMVD.ResultRowID AS [IMI Reference Number] ,
                CONVERT(VARCHAR(32), RMVD.BatchID) + '-'
                + CONVERT(VARCHAR(32), RMVD.DSEventID) AS [Event Reference Number] ,
                RMVD.EventDescr AS [Event] ,
                ISNULL(RMVD.EndDate, RMVD.BeginDate) AS [Date of Service] ,
                RMVD.CodeType AS [Code Type] ,
                RMVD.Code ,
                COALESCE(CodingECTs.[Description],
                         CodingNDCs.GenericName + ISNULL(' ('
                                                         + CodingNDCs.Category
                                                         + ')', ''),
                         CodingNDCs.BrandName + ISNULL(' ('
                                                       + CodingNDCs.Category
                                                       + ')', '')) AS [Code Description]
        FROM    Result.MeasureDetail AS RMD WITH ( NOLOCK )
                INNER JOIN Measure.Measures AS MM WITH ( NOLOCK ) ON MM.MeasureID = RMD.MeasureID
                INNER JOIN Measure.Metrics AS MX WITH ( NOLOCK ) ON MX.MetricID = RMD.MetricID
                INNER JOIN Result.DataSetMemberKey AS RDSMK WITH ( NOLOCK ) ON RDSMK.DataRunID = RMD.DataRunID
                                                              AND RDSMK.DSMemberID = RMD.DSMemberID
                INNER JOIN Result.DataSetRunKey AS RDSRK WITH ( NOLOCK ) ON RDSRK.DataRunID = RMD.DataRunID
                INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH ( NOLOCK ) ON RDSPK.DataRunID = RMD.DataRunID
                                                              AND RDSPK.PopulationID = RMD.PopulationID
		/*LEFT OUTER JOIN Log.Entities AS LE
				ON LE.BatchID = RMD.BatchID AND
					LE.DataRunID = RMD.DataRunID AND
					LE.DSEntityID = RMD.SourceNumerator AND
					LE.DSMemberID = RMD.DSMemberID
		LEFT OUTER JOIN Log.EntityBase AS LEB
				ON LEB.BatchID = LE.BatchID AND
					LEB.DataRunID = LE.DataRunID AND
					LEB.DSMemberID = LE.DSMemberID AND
					LEB.EntityBaseID = LE.EntityBaseID*/
                LEFT OUTER JOIN Result.MeasureEventDetail AS RMVD WITH ( NOLOCK ) ON RMVD.BatchID = RMD.BatchID
                                                              AND RMVD.DataRunID = RMD.DataRunID
                                                              AND RMVD.DSMemberID = RMD.DSMemberID
                                                              AND RMVD.KeyDate = RMD.KeyDate
                                                              AND RMVD.MeasureID = RMD.MeasureID
                                                              AND RMVD.MetricID = RMD.MetricID
                                                              AND RMVD.ResultTypeID = RMD.ResultTypeID
                                                              AND RMVD.MapTypeID = @MapTypeN
                OUTER APPLY ( SELECT TOP 1
                                        tNCE.*
                              FROM      Ncqa.CodingECTs AS tNCE
                              WHERE     tNCE.Measure = MM.Abbrev
                                        AND tNCE.Code = RMVD.Code
                                        AND RMVD.CodeType <> 'NDC'
                              ORDER BY  tNCE.MeasureYear DESC
                            ) AS CodingECTs
                OUTER APPLY ( SELECT TOP 1
                                        tNCN.*
                              FROM      Ncqa.CodingNDCs AS tNCN
                              WHERE     tNCN.Measure = MM.Abbrev
                                        AND tNCN.Code = RMVD.Code
                                        AND RMVD.CodeType = 'NDC'
                              ORDER BY  tNCN.MeasureYear DESC
                            ) AS CodingNDCs
                LEFT OUTER JOIN Result.DataSetMemberProviderKey AS RDSMPK ON RDSMPK.DataRunID = RMD.DataRunID
                                                              AND RDSMPK.DSMemberID = RMD.DSMemberID
                LEFT OUTER JOIN Result.DataSetMedicalGroupKey AS RDSMGK ON RDSMGK.DataRunID = RDSMPK.DataRunID
                                                              AND RDSMGK.MedGrpID = RDSMPK.MedGrpID
        WHERE   ( MM.Abbrev = 'DDE' )
                AND ( MX.IsParent = 0 )
                AND ( RMD.IsDenominator = 1 )
                AND ( RMD.DataRunID = @DataRunID )
                AND ( RMD.BitProductLines & @BitProductLines > 0 );

    END

GO
GRANT EXECUTE ON  [Report].[GetDDENumeratorEvents] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetDDENumeratorEvents] TO [Reports]
GO
