SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetClaimCodingSummary]
    (
      @ClaimSrcTypeID TINYINT = NULL ,
      @ClaimTypeID TINYINT = NULL ,
      @CodeTypeGrpID TINYINT = NULL ,
      @CodeTypeID TINYINT = NULL ,
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

        SELECT  RCCS.ClaimMonth ,
                CONVERT(VARCHAR(8), RCCS.ClaimYear)
                + CASE WHEN RCCS.ClaimMonth BETWEEN 1 AND 9 THEN '0'
                       ELSE ''
                  END + CONVERT(VARCHAR(8), RCCS.ClaimMonth) AS ClaimPeriod ,
                CONVERT(VARCHAR(8), RCCS.ClaimYear) + '-'
                + CASE WHEN RCCS.ClaimMonth BETWEEN 1 AND 9 THEN '0'
                       ELSE ''
                  END + CONVERT(VARCHAR(8), RCCS.ClaimMonth) AS ClaimPeriodDisplayNumeric ,
                LEFT(CONVERT(VARCHAR(32), CONVERT(DATETIME, CONVERT(VARCHAR(16), RCCS.ClaimMonth)
                     + '/1/' + CONVERT(VARCHAR(16), RCCS.ClaimYear)), 7), 3)
                + ' ' + CONVERT(VARCHAR(8), RCCS.ClaimYear) AS ClaimPeriodDisplayText ,
                RCCS.ClaimYear ,
                MIN(CCT.CodeType) AS CodeType ,
                MIN(CCT.Abbrev) AS CodeTypeAbbrev ,
                MIN(CCT.Descr) AS CodeTypeDescr ,
                RCCS.CodeTypeID ,
                SUM(RCCS.CountClaimLines) AS CountClaimLines ,
                SUM(RCCS.CountCodes) AS CountCodes ,
                SUM(RCCS.CountMembers) AS CountMembers
        FROM    Result.ClaimCodeSummary AS RCCS WITH ( NOLOCK )
                INNER JOIN Claim.CodeTypes AS CCT WITH ( NOLOCK ) ON CCT.CodeTypeID = RCCS.CodeTypeID
        WHERE   ( RCCS.DataRunID = @DataRunID )
                AND ( RCCS.ClaimYear BETWEEN @MaxYear - @NumberOfYears + 1
                                     AND     @MaxYear )
                AND ( ( @ClaimSrcTypeID IS NULL )
                      OR ( RCCS.ClaimSrcTypeID = @ClaimSrcTypeID )
                    )
                AND ( ( @ClaimTypeID IS NULL )
                      OR ( RCCS.ClaimTypeID = @ClaimTypeID )
                    )
                AND ( ( @CodeTypeGrpID IS NULL )
                      OR ( RCCS.CodeTypeID IN (
                           SELECT   CodeTypeID
                           FROM     Claim.CodeTypeGroupings WITH ( NOLOCK )
                           WHERE    CodeTypeGrpID = @CodeTypeGrpID ) )
                    )
                AND ( ( @CodeTypeID IS NULL )
                      OR ( RCCS.CodeTypeID = @CodeTypeID )
                    )
                AND ( ( @DataSourceID IS NULL )
                      OR ( RCCS.DataSourceID = @DataSourceID )
                    )
        GROUP BY RCCS.ClaimMonth ,
                RCCS.ClaimYear ,
                RCCS.CodeTypeID
        ORDER BY ClaimYear ,
                ClaimMonth ,
                CodeTypeDescr;


    END

GO
GRANT VIEW DEFINITION ON  [Report].[GetClaimCodingSummary] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetClaimCodingSummary] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetClaimCodingSummary] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetClaimCodingSummary] TO [Reports]
GO
