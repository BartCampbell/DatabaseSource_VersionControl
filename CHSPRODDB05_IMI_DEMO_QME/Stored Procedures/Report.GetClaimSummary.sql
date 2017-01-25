SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetClaimSummary]
    (
      @ClaimSrcTypeID TINYINT = NULL ,
      @ClaimTypeID TINYINT = NULL ,
      @DataRunID INT ,
      @DataSourceID INT = NULL ,
      @NumberOfYears TINYINT = 255
    )
AS
    BEGIN

        DECLARE @MaxYear SMALLINT;
        SELECT  @MaxYear = YEAR(SeedDate)
        FROM    Result.DataSetRunKey WITH ( NOLOCK )
        WHERE   DataRunID = @DataRunID;

        SELECT  RCLS.ClaimMonth ,
                CONVERT(VARCHAR(8), RCLS.ClaimYear)
                + CASE WHEN RCLS.ClaimMonth BETWEEN 1 AND 9 THEN '0'
                       ELSE ''
                  END + CONVERT(VARCHAR(8), RCLS.ClaimMonth) AS ClaimPeriod ,
                CONVERT(VARCHAR(8), RCLS.ClaimYear) + '-'
                + CASE WHEN RCLS.ClaimMonth BETWEEN 1 AND 9 THEN '0'
                       ELSE ''
                  END + CONVERT(VARCHAR(8), RCLS.ClaimMonth) AS ClaimPeriodDisplayNumeric ,
                LEFT(CONVERT(VARCHAR(32), CONVERT(DATETIME, CONVERT(VARCHAR(16), RCLS.ClaimMonth)
                     + '/1/' + CONVERT(VARCHAR(16), RCLS.ClaimYear)), 7), 3)
                + ' ' + CONVERT(VARCHAR(8), RCLS.ClaimYear) AS ClaimPeriodDisplayText ,
                MIN(CCT.Abbrev) AS ClaimTypeAbbrev ,
                MIN(CCT.Descr) AS ClaimTypeDescr ,
                RCLS.ClaimTypeID ,
                RCLS.ClaimYear ,
                SUM(RCLS.CountClaimLines) AS CountClaimLines ,
                SUM(RCLS.CountMembers) AS CountMembers
        FROM    Result.ClaimLineSummary AS RCLS WITH ( NOLOCK )
                INNER JOIN Claim.ClaimTypes AS CCT ON CCT.ClaimTypeID = RCLS.ClaimTypeID
        WHERE   ( RCLS.DataRunID = @DataRunID )
                AND ( RCLS.ClaimYear BETWEEN @MaxYear - @NumberOfYears + 1
                                     AND     @MaxYear )
                AND ( ( @ClaimSrcTypeID IS NULL )
                      OR ( RCLS.ClaimSrcTypeID = @ClaimSrcTypeID )
                    )
                AND ( ( @ClaimTypeID IS NULL )
                      OR ( RCLS.ClaimTypeID = @ClaimTypeID )
                    )
                AND ( ( @DataSourceID IS NULL )
                      OR ( RCLS.DataSourceID = @DataSourceID )
                    )
        GROUP BY RCLS.ClaimMonth ,
                RCLS.ClaimTypeID ,
                RCLS.ClaimYear
        ORDER BY ClaimYear ,
                ClaimMonth ,
                ClaimTypeDescr;

    END
GO
GRANT EXECUTE ON  [Report].[GetClaimSummary] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetClaimSummary] TO [Reports]
GO
