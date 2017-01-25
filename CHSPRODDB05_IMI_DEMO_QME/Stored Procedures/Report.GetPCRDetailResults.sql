SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetPCRDetailResults]
(
 @DataRunID int,
 @EnrollGroupID int = NULL,
 @PayerID smallint = NULL,
 @PopulationID int = NULL,
 @ProductLineID int = NULL
 )
AS
BEGIN

    WITH    AgeBands(FromAge, ToAge, Gender, Descr, SortOrder)
              AS (SELECT    18,
                            44,
                            1,
                            '18-44, Male',
                            1
                  UNION
                  SELECT    18,
                            44,
                            0,
                            '18-44, Female',
                            2
                  UNION
                  SELECT    18,
                            44,
                            NULL,
                            '18-44, Total',
                            103
                  UNION
                  SELECT    45,
                            54,
                            1,
                            '45-54, Male',
                            4
                  UNION
                  SELECT    45,
                            54,
                            0,
                            '45-54, Female',
                            5
                  UNION
                  SELECT    45,
                            54,
                            NULL,
                            '45-54, Total',
                            106
                  UNION
                  SELECT    55,
                            64,
                            1,
                            '55-64, Male',
                            7
                  UNION
                  SELECT    55,
                            64,
                            0,
                            '55-64, Female',
                            8
                  UNION
                  SELECT    55,
                            64,
                            NULL,
                            '55-64, Total',
                            109
                  UNION
                  SELECT    65,
                            74,
                            1,
                            '65-74, Male',
                            10
                  UNION
                  SELECT    65,
                            74,
                            0,
                            '65-74, Female',
                            11
                  UNION
                  SELECT    65,
                            74,
                            NULL,
                            '65-74, Total',
                            112
                  UNION
                  SELECT    75,
                            84,
                            1,
                            '75-84, Male',
                            13
                  UNION
                  SELECT    75,
                            84,
                            0,
                            '75-84, Female',
                            14
                  UNION
                  SELECT    75,
                            84,
                            NULL,
                            '75-84, Total',
                            115
                  UNION
                  SELECT    85,
                            255,
                            1,
                            '85+, Male',
                            16
                  UNION
                  SELECT    85,
                            255,
                            0,
                            '85+, Female',
                            17
                  UNION
                  SELECT    85,
                            255,
                            NULL,
                            '85+, Total',
                            118
                  UNION
                  SELECT    18,
                            64,
                            NULL,
                            'PCR-A 18-64, Total',
                            201
                  UNION
                  SELECT    65,
                            255,
                            NULL,
                            'PCR-B 65+, Total',
                            202
                  UNION
                  SELECT    18,
                            255,
                            1,
                            'All Ages, Male',
                            319
                  UNION
                  SELECT    18,
                            255,
                            0,
                            'All Ages, Female',
                            320
                  UNION
                  SELECT    18,
                            255,
                            NULL,
                            'All Ages, Total',
                            321
                 )
        SELECT  MM.Abbrev AS Measure,
                RMD.ResultRowGuid AS [Record ID],
                RDSMK.CustomerMemberID AS [Member ID],
                RDSMK.DisplayID AS [IMI Member ID],
                RDSMK.NameLast AS [Member Last Name],
                RDSMK.NameFirst AS [Member First Name],
                RDSMK.DOB AS [Member DOB],
                Member.ConvertGenderToMF(RDSMK.Gender) AS [Member Gender],
                RDSMK.SsnDisplay AS [Member SSN],
                AB.Descr AS [Age Band],
                RMD.KeyDate AS [Key Event Date],
                IsDenominator AS Denominator,
                IsNumerator AS Numerator,
                ISNULL(PCR.BaseWeight, 0) AS [Base Weight],
                ISNULL(PCR.DemoWeight, 0) [Demographic Weight],
                ISNULL(PCR.DccWeight, 0) [Condition Weight],
                ISNULL(PCR.HClinCondWeight, 0) AS [Comorbid Weight],
                ISNULL(PCR.SurgeryWeight, 0) AS [Surgery Weight],
                ISNULL(PCR.AdjProbability, 0) AS [Adjusted Probability],
                ISNULL(PCR.Variance, 0) AS Variance
        FROM    Result.MeasureDetail AS RMD WITH (NOLOCK)
                INNER JOIN AgeBands AS AB WITH (NOLOCK) ON RMD.Age BETWEEN AB.FromAge AND AB.ToAge AND
                                                           (RMD.Gender = AB.Gender OR
                                                            AB.Gender IS NULL
                                                           ) AND
                                                           AB.Gender IS NULL AND
                                                           AB.SortOrder < 150
                INNER JOIN Result.MeasureDetail_PCR AS PCR WITH (NOLOCK) ON PCR.SourceRowGuid = RMD.ResultRowGuid
                INNER JOIN Product.ProductLines AS PPL WITH (NOLOCK) ON RMD.BitProductLines &
                                                              PPL.BitValue > 0
                INNER JOIN Measure.Measures AS MM WITH (NOLOCK) ON RMD.MeasureID = MM.MeasureID
                INNER JOIN Result.DataSetMemberKey AS RDSMK WITH (NOLOCK) ON RDSMK.DataRunID = RMD.DataRunID AND
                                                              RDSMK.DSMemberID = RMD.DSMemberID
        WHERE   MM.Abbrev = 'PCR' AND
                RMD.DataRunID = @DataRunID AND
				(RMD.PayerID = @PayerID OR @PayerID IS NULL) AND
				(RMD.EnrollGroupID = @EnrollGroupID  OR @EnrollGroupID IS NULL) AND
                RMD.PopulationID = @PopulationID AND
                PPL.ProductLineID = @ProductLineID
        ORDER BY [Member Last Name],
                [Member First Name],
                [Member DOB];

END;

GO
GRANT EXECUTE ON  [Report].[GetPCRDetailResults] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetPCRDetailResults] TO [Reports]
GO
