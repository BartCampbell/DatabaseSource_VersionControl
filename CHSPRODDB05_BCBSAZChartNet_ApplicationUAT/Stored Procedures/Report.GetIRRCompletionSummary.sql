SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetIRRCompletionSummary]
    (
      @AbstractionDateEnd DATETIME = NULL ,	--Displayed as "Abstraction Date - End:" in SSRS, Sort 7
      @AbstractionDateStart DATETIME = NULL ,	--Displayed as "Abstraction Date - Start:" in SSRS, Sort 6
      @AbstractorID INT = NULL ,				--Displayed as "Abstractor:" in SSRS, Sort 5
      @MeasureComponentID INT = NULL ,			--Displayed as "Component:" in SSRS, Sort 4
      @MeasureID INT = NULL ,					--Displayed as "Measure:" in SSRS, Sort 3
      @Product VARCHAR(20) = NULL ,			--Displayed as "Product:" in SSRS, Sort: 2
      @ProductLine VARCHAR(20) = NULL ,		--Displayed as "Product Line:" in SSRS, Sort: 1
      @RequireDataEntry BIT = 1  		--Displayed as "Require Data Entry:" in SSRS, Sort 8
    )
AS
    BEGIN

        WITH    PursuitEventReviews
                  AS ( SELECT   AR.PursuitEventID ,
                                AR.MeasureComponentID ,
                                SUM(AR.ReviewPointsAvailable) AS ReviewPointsAvailable ,
                                SUM(AR.ReviewPointsAvailable)
                                - SUM(CASE WHEN AR.ReviewPointsAvailable < ISNULL(ARD.Deductions,
                                                              0)
                                           THEN AR.ReviewPointsAvailable
                                           ELSE ISNULL(ARD.Deductions, 0)
                                      END) AS ReviewPointsActual
                       FROM     dbo.AbstractionReview AS AR WITH ( NOLOCK )
                                INNER JOIN dbo.AbstractionReviewStatus AS ART
                                WITH ( NOLOCK ) ON ART.AbstractionReviewStatusID = AR.AbstractionReviewStatusID
                                OUTER APPLY ( SELECT TOP 1
                                                        SUM(tARD.Deductions) AS Deductions
                                              FROM      dbo.AbstractionReviewDetail
                                                        AS tARD WITH ( NOLOCK )
                                              WHERE     tARD.AbstractionReviewID = AR.AbstractionReviewID
                                            ) AS ARD
                       WHERE    ( ART.IsCompleted = 1 )
                       GROUP BY AR.PursuitEventID ,
                                AR.MeasureComponentID
                     ),
                Results
                  AS ( SELECT   A.AbstractorID ,
                                MIN(A.AbstractorName) AS AbstractorName ,
                                ISNULL(COUNT(DISTINCT RVR.PursuitEventID), 0) AS CountReviewed ,
                                ISNULL(COUNT(DISTINCT RV.PursuitEventID), 0) AS CountPursuits ,
                                MC.MeasureComponentID ,
                                MIN(MC.ComponentName) AS MeasureComponentName ,
                                MIN(MC.Title) AS MeasureComponentDescription ,
                                MIN(M.HEDISMeasure) AS Measure ,
                                MIN(M.HEDISMeasureDescription) AS MeasureDescription ,
                                M.MeasureID ,
                                MBR.Product ,
                                MBR.ProductLine ,
                                CASE WHEN ISNULL(COUNT(DISTINCT RV.PursuitEventID),
                                                 0) > 0
                                     THEN CONVERT(DECIMAL(18, 6), ISNULL(COUNT(DISTINCT RVR.PursuitEventID),
                                                              0))
                                          / CONVERT(DECIMAL(18, 6), ISNULL(COUNT(DISTINCT RV.PursuitEventID),
                                                              0))
                                     ELSE CONVERT(DECIMAL(18, 6), 0)
                                END AS ReviewPercentage ,
                                ISNULL(SUM(RVR.ReviewPointsActual), 0) AS ReviewPointsActual ,
                                ISNULL(SUM(RVR.ReviewPointsAvailable), 0) AS ReviewPointsAvailable ,
                                CASE WHEN ISNULL(SUM(RVR.ReviewPointsAvailable),
                                                 0) > 0
                                     THEN CONVERT(DECIMAL(18, 6), ISNULL(SUM(RVR.ReviewPointsActual),
                                                              0))
                                          / CONVERT(DECIMAL(18, 6), ISNULL(SUM(RVR.ReviewPointsAvailable),
                                                              0))
                                     ELSE CONVERT(DECIMAL(18, 6), 0)
                                END AS ReviewPointsPercentage
                       FROM     dbo.Pursuit AS R WITH ( NOLOCK )
                                INNER JOIN dbo.PursuitEvent AS RV WITH ( NOLOCK ) ON RV.PursuitID = R.PursuitID
                                INNER JOIN dbo.Member AS MBR WITH ( NOLOCK ) ON MBR.MemberID = R.MemberID
                                INNER JOIN dbo.MeasureComponent AS MC WITH ( NOLOCK ) ON MC.MeasureID = RV.MeasureID
                                LEFT OUTER JOIN PursuitEventReviews AS RVR
                                WITH ( NOLOCK ) ON RVR.PursuitEventID = RV.PursuitEventID
                                                   AND RVR.MeasureComponentID = MC.MeasureComponentID
                                INNER JOIN dbo.Measure AS M WITH ( NOLOCK ) ON M.MeasureID = RV.MeasureID
                                INNER JOIN dbo.Abstractor AS A WITH ( NOLOCK ) ON A.AbstractorID = R.AbstractorID
                                INNER JOIN dbo.AbstractionStatus AS AST WITH ( NOLOCK ) ON AST.AbstractionStatusID = RV.AbstractionStatusID
                                OUTER APPLY ( SELECT TOP 1
                                                        tMRC.*
                                              FROM      dbo.MedicalRecordComposite
                                                        AS tMRC WITH ( NOLOCK )
                                              WHERE     tMRC.MeasureComponentID = MC.MeasureComponentID
                                                        AND tMRC.PursuitEventID = RV.PursuitEventID
                                              ORDER BY  tMRC.MedicalRecordKey ,
                                                        tMRC.CreatedDate
                                            ) AS MRC
                                OUTER APPLY ( SELECT TOP 1
                                                        LogDate
                                              FROM      dbo.PursuitEventStatusLog
                                                        AS tPVSL WITH ( NOLOCK )
                                                        INNER JOIN dbo.AbstractionStatus
                                                        AS tAST WITH ( NOLOCK ) ON tPVSL.AbstractionStatusID = tAST.AbstractionStatusID
                                                              AND tAST.IsCompleted = 1
                                              WHERE     tPVSL.PursuitEventID = RV.PursuitEventID AND
														tPVSL.AbstractionStatusChanged = 1
                                              ORDER BY  LogDate DESC
                                            ) AS PVSL
                       WHERE    ( AST.IsCompleted = 1 )
                                AND ( MC.EnabledOnWebsite = 1 )
                                AND ( MC.EnabledOnReviews = 1 )
                                AND ( ( @AbstractorID IS NULL )
                                      OR ( A.AbstractorID = @AbstractorID )
                                    )
                                AND ( ( @AbstractionDateStart IS NULL )
                                      OR ( @AbstractionDateStart <= PVSL.LogDate )
                                    )
                                AND ( ( @AbstractionDateEnd IS NULL )
                                      OR ( PVSL.LogDate < DATEADD(DAY, 1,
                                                              @AbstractionDateEnd) )
                                    )
                                AND ( ( @MeasureComponentID IS NULL )
                                      OR ( MC.MeasureComponentID = @MeasureComponentID )
                                    )
                                AND ( ( @MeasureID IS NULL )
                                      OR ( M.MeasureID = @MeasureID )
                                    )
                                AND ( ( @Product IS NULL )
                                      OR ( MBR.Product = @Product )
                                    )
                                AND ( ( @ProductLine IS NULL )
                                      OR ( MBR.ProductLine = @ProductLine )
                                    )
                                AND ( ( @RequireDataEntry IS NULL )
                                      OR ( @RequireDataEntry = 0 )
                                      OR ( @RequireDataEntry = 1
                                           AND MRC.MedicalRecordKey IS NOT NULL
                                         )
                                    )
                       GROUP BY A.AbstractorID ,
                                MC.MeasureComponentID ,
                                M.MeasureID ,
                                MBR.Product ,
                                MBR.ProductLine
                     )
            SELECT  t.ProductLine AS [Product Line] ,
                    t.Product AS Product ,
                    t.AbstractorName AS [Abstractor] ,
                    t.Measure ,
                    t.MeasureDescription AS [Measure Description] ,
                    t.MeasureComponentDescription AS [Measure Component] ,
                    t.CountPursuits AS [Total Pursuits] ,
                    t.CountReviewed AS [Reviewed Pursuits] ,
                    t.ReviewPercentage AS [% Reviewed] ,
                    t.ReviewPointsAvailable AS [Points Available] ,
                    t.ReviewPointsActual AS [Points Actual] ,
                    t.ReviewPointsPercentage AS [% Accuracy]
            FROM    Results AS t
            ORDER BY [Product Line] ,
                    Product ,
                    Abstractor ,
                    Measure ,
                    [Measure Component];
    END		
GO
GRANT EXECUTE ON  [Report].[GetIRRCompletionSummary] TO [Reporting]
GO
