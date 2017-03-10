SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Report].[GetAbstractionNotes]
(
 @ProductLine varchar(20) = NULL,
 @Product varchar(20) = NULL,
 @MeasureID int = NULL,
 @MetricID int = NULL,
 @AbstractionStatusID int = NULL,
 @ChartStatusValueID int = NULL,
 @ProviderSiteName varchar(75) = NULL,
 @ProviderID int = NULL,
 @ProviderName varchar(25) = NULL,
 @ProviderSiteID int = NULL,
 @AbstractorID int = NULL,
 @AbstractionDateStart datetime = NULL,
 @AbstractionDateEnd datetime = NULL,
 @NoteCategoryID int = NULL,
 @NoteCreatedOnDateStart datetime = NULL,
 @NoteCreatedOnDateEnd datetime = NULL,
 @ChartStatusDetailID int = NULL,
 @ProviderSiteNameID int = NULL,
 @ProviderNameID int = NULL,
 @PursuitNumber varchar(30) = NULL,
 -----------------------------------------------
 @FilterOnUserName bit = 0,
 @UserName nvarchar(128) = NULL
)
AS
BEGIN

    SET NOCOUNT ON

    SET @ProviderSiteName = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteName,
                                                              '*', '%'), '?',
                                                           '_'), '%%%', '%'),
                                           '%%', '%'), '%');
    SET @ProviderName = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderName,
                                                              '*', '%'), '?',
                                                       '_'), '%%%', '%'), '%%',
                                       '%'), '%');

	-- if parent and child chosen, parent is null
    IF @ChartStatusDetailID IS NOT NULL
        SET @ChartStatusValueID = NULL

    SELECT DISTINCT
            mms.ProductLine AS ProductLine,
            mms.Product AS Product,
            ms.HEDISMeasure,
            p.PursuitNumber,
            ps.CustomerProviderSiteID AS ProviderSiteID,
            ps.ProviderSiteName,
            pr.CustomerProviderID AS ProviderID,
            pr.NameEntityFullName AS ProviderName,
            m.CustomerMemberID AS MemberID,
            m.NameLast + ISNULL(', ' + m.NameFirst, '') + ISNULL(' ' +
                                                              m.NameMiddleInitial,
                                                              '') AS MemberName,
            CONVERT(varchar, m.DateOfBirth, 101) AS DOB,
            ab.[Description] AS AbstractionStatus,
            ISNULL(ChartStatus.Title + ': ', '') + cs.Title AS ChartStatus,
            ISNULL(penc2.Title + ': ', '') + penc.Title AS NoteCategory,
            PVSL.LogDate AS AbstractionDate,
            ISNULL(a.AbstractorName, '') AS Abstractor,
            pen.CreateUser AS NoteCreatedBy, -- user created note
            pen.CreateDate AS NoteCreatedOn, -- date note created
            REPLACE(REPLACE(pen.NoteText, CHAR(13), ''), CHAR(10), '') AS AbstractionNote,
            pen.UpdateUser AS NoteUpdatedBy,
            pen.UpdateDate AS NoteUpdatedDate
    FROM    MemberMeasureMetricScoring mmms WITH(NOLOCK)
            INNER JOIN MemberMeasureSample mms WITH(NOLOCK) ON mmms.MemberMeasureSampleID = mms.MemberMeasureSampleID
            INNER JOIN Pursuit p WITH(NOLOCK) ON p.MemberID = mms.MemberID
            INNER JOIN PursuitEvent pe WITH(NOLOCK) ON pe.PursuitID = p.PursuitID AND
                                          pe.EventDate = mms.EventDate AND
                                          pe.MeasureID = mms.MeasureID
            INNER JOIN Measure ms WITH(NOLOCK) ON ms.MeasureID = mms.MeasureID
            INNER JOIN AbstractionStatus ab WITH(NOLOCK) ON ab.AbstractionStatusID = pe.AbstractionStatusID
            INNER JOIN PursuitEventNote pen WITH(NOLOCK) ON pen.PursuitEventID = pe.PursuitEventID
            LEFT JOIN PursuitEventNoteCategory penc WITH(NOLOCK) ON penc.PursuitEventNoteCategoryID = pen.PursuitEventNoteCategoryID
            LEFT JOIN PursuitEventNoteCategory penc2 WITH(NOLOCK) ON penc2.PursuitEventNoteCategoryID = penc.ParentID
            LEFT JOIN ProviderSite ps WITH(NOLOCK) ON ps.ProviderSiteID = p.ProviderSiteID
            INNER JOIN Providers pr WITH(NOLOCK) ON pr.ProviderID = p.ProviderID
            LEFT JOIN HEDISSubMetric mt WITH(NOLOCK) ON mt.HEDISSubMetricID = mmms.HEDISSubMetricID
            LEFT JOIN Member m WITH(NOLOCK) ON m.MemberID = mms.MemberID
            LEFT JOIN AbstractionReview ar WITH(NOLOCK) ON ar.PursuitEventID = pe.PursuitEventID
            LEFT JOIN ChartStatusValue cs WITH(NOLOCK) ON cs.ChartStatusValueID = pe.ChartStatusValueID
            LEFT JOIN Reviewer r WITH(NOLOCK) ON r.ReviewerID = p.ReviewerID
            LEFT JOIN Abstractor a WITH(NOLOCK) ON a.AbstractorID = p.AbstractorID
            OUTER APPLY (SELECT TOP 1
                                LogDate
                         FROM   dbo.PursuitEventStatusLog AS tPVSL WITH(NOLOCK)
                                INNER JOIN dbo.AbstractionStatus AS tAST WITH(NOLOCK) ON tPVSL.AbstractionStatusID = tAST.AbstractionStatusID AND
                                                              tAST.IsCompleted = 1
                         WHERE  tPVSL.PursuitEventID = pe.PursuitEventID AND
										tPVSL.AbstractionStatusChanged = 1
                         ORDER BY LogDate DESC
                        ) AS PVSL
            OUTER APPLY (SELECT Title
                         FROM   ChartStatusValue WITH(NOLOCK)
                         WHERE  ChartStatusValueID = cs.ParentID
                        ) AS ChartStatus
    WHERE   --(mmms.ExclusionCount > 0 OR
            -- mmms.SampleVoidCount > 0 OR
            -- mmms.ReqExclCount > 0
            --) AND
            --mmms.DenominatorCount > 0 AND
            ((@ProductLine IS NULL) OR
             (m.ProductLine = @ProductLine) OR
             (m.ProductLine LIKE '%' + @ProductLine + '%')
            ) AND
            ((@Product IS NULL) OR
             (m.Product = @Product) OR
             (m.Product LIKE '%' + @Product + '%')
            ) AND
            ((@MeasureID IS NULL) OR
             (pe.MeasureID = @MeasureID)
            ) AND
            ((@MetricID IS NULL) OR
             (mt.HEDISSubMetricID = @MetricID)
            ) AND
            ((@AbstractionStatusID IS NULL) OR
             (ab.AbstractionStatusID = @AbstractionStatusID)
            ) AND
            ((@ProviderSiteName IS NULL) OR
             (ps.ProviderSiteName = @ProviderSiteName) OR
             (ps.ProviderSiteName LIKE '%' + @ProviderSiteName + '%')
            ) AND
            ((@ProviderSiteID IS NULL) OR
             (ps.ProviderSiteID = @ProviderSiteID)
            ) AND
            ((@ProviderID IS NULL) OR
             (pr.ProviderID = @ProviderID)
            ) AND
            ((@ProviderName IS NULL) OR
             (pr.NameEntityFullName = @ProviderName) OR
             (pr.NameEntityFullName LIKE '%' + @ProviderName + '%') OR
             (pr.NameLast = @ProviderName) OR
             (pr.NameLast LIKE '%' + @ProviderName + '%')
            ) AND
            ((@AbstractorID IS NULL) OR
             (p.AbstractorID = @AbstractorID) OR
             (p.AbstractorID IS NULL AND
              @AbstractorID = -1
             )
            ) AND
            ((@AbstractionDateStart IS NULL) OR
             (@AbstractionDateStart <= PVSL.LogDate)
            ) AND
            ((@AbstractionDateEnd IS NULL) OR
             (PVSL.LogDate < DATEADD(DAY, 1, @AbstractionDateEnd))
            ) AND
            ((@NoteCreatedOnDateStart IS NULL) OR
             (@NoteCreatedOnDateStart <= pen.CreateDate)
            ) AND
            ((@NoteCreatedOnDateEnd IS NULL) OR
             (pen.CreateDate < DATEADD(DAY, 1, @NoteCreatedOnDateEnd))
            )
	--AND     ((@ChartStatusValueID IS NULL) OR (pe.ChartStatusValueID = @ChartStatusValueID) OR (@ChartStatusValueID = -1 AND pe.ChartStatusValueID IS NULL))
            AND
            ((@ChartStatusValueID IS NULL) OR
             (( pe.ChartStatusValueID IN (
              SELECT    ChartStatusValueID
              FROM      dbo.ChartStatusValue WITH(NOLOCK)
              WHERE     ParentID = @ChartStatusValueID) OR
              pe.ChartStatusValueID = @ChartStatusValueID)
             )
            ) AND
            ((@ChartStatusDetailID IS NULL) OR
             (pe.ChartStatusValueID = @ChartStatusDetailID)
            ) AND
            ((@NoteCategoryID IS NULL) OR
             (pen.PursuitEventNoteCategoryID IN (
              SELECT    PursuitEventNoteCategoryID
              FROM      dbo.PursuitEventNoteCategory WITH(NOLOCK)
              WHERE     ParentID = @NoteCategoryID OR
                        PursuitEventNoteCategoryID = @NoteCategoryID))
            ) AND
            ((@ProviderSiteNameID IS NULL) OR
             (ps.ProviderSiteID = @ProviderSiteNameID)
            ) AND
            ((@ProviderNameID IS NULL) OR
             (pr.ProviderID = @ProviderNameID)
            ) AND
            ((@PursuitNumber IS NULL) OR
             (p.PursuitNumber = @PursuitNumber)
            ) AND
            ((@UserName IS NULL) OR
             (ISNULL(@FilterOnUserName, 0) = 0) OR
             (a.UserName = @UserName)
            )
    ORDER BY ProductLine,
            Product,
            ms.HEDISMeasure,
            p.PursuitNumber 

END
GO
GRANT EXECUTE ON  [Report].[GetAbstractionNotes] TO [Reporting]
GO
