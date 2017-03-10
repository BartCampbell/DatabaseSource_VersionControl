SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetEntityEventDetail]
(
 @CustomerMemberID varchar(32) = NULL,
 @DataRunID int,
 @EntityID int = NULL,
 @MeasureID int = NULL,
 @MetricID int = NULL,
 @MapTypeID tinyint = NULL,
 @ResultTypeID tinyint = NULL,
 @ShowHtml bit = 1
 )
AS
BEGIN

    SET @CustomerMemberID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@CustomerMemberID,
                                                              '*', '%'), '?',
                                                           '_'), '%%%', '%'),
                                           '%%', '%'), '%');

    SELECT  RMVD.ResultRowGuid AS [Record ID],
            RDSMK.CustomerMemberID AS [Member ID],
            RDSMK.DisplayID AS [IMI Member ID],
            RDSMK.NameLast AS [Member Last Name],
            RDSMK.NameFirst AS [Member First Name],
            RDSMK.DOB AS [Member DOB],
            Member.ConvertGenderToMF(RDSMK.Gender) AS [Member Gender],
            RDSMK.SsnDisplay AS [Member SSN],
            RDSPK.CustomerProviderID AS [Provider ID],
            RDSPK.DisplayID AS [IMI Provider ID],
            RDSPK.ProviderName AS [Provider Name],
            MM.Abbrev AS [Measure],
            MM.Descr AS [Measure Description],
            MX.Abbrev AS [Metric],
            MX.Descr AS [Metric Description],
            RMVD.KeyDate AS [Key Event Date],
            RRT.Descr AS [Result Type],
            CONVERT(varchar(32), RMVD.EntityID) + '-' +
            CONVERT(varchar(32), RMVD.DSEntityID) AS [Entity Reference ID],
            RMVD.EntityDescr AS [Entity Description],
            ISNULL(CONVERT(varchar(32), RMVD.EventID), '') + ISNULL('-' +
                                                              CONVERT(varchar(32), RMVD.DSEventID),
                                                              '') AS [Event Reference ID],
            RMVD.EventDescr AS [Event Description],
            RMVD.ClaimNum AS [Claim Number],
            CLT.Descr AS [Claim Type],
            RMVD.ServDate AS [Date of Service],
            RMVD.CodeType AS [Code Type],
            RMVD.Code AS [Code],
            CASE WHEN @ShowHtml = 1 THEN RMVD.DescrHtml ELSE RMVD.Descr END AS [Record Description],
            MMT.Descr AS [Record Mapping],
            dbo.ConvertBitToYN(RMVD.IsSupplmental) AS [Has Supplemental Data],
            BDSS.Descr AS [Supplemental Data Source]
    FROM    Result.MeasureEventDetail AS RMVD WITH (NOLOCK)
            INNER JOIN Measure.Measures AS MM WITH (NOLOCK) ON MM.MeasureID = RMVD.MeasureID
            INNER JOIN Measure.Metrics AS MX WITH (NOLOCK) ON MX.MetricID = RMVD.MetricID
            INNER JOIN Measure.MappingTypes AS MMT WITH (NOLOCK) ON MMT.MapTypeID = RMVD.MapTypeID
            INNER JOIN Result.ResultTypes AS RRT WITH (NOLOCK) ON RRT.ResultTypeID = RMVD.ResultTypeID
            INNER JOIN Result.DataSetMemberKey AS RDSMK WITH (NOLOCK) ON RDSMK.DataRunID = RMVD.DataRunID AND
                                                              RDSMK.DSMemberID = RMVD.DSMemberID
            LEFT OUTER JOIN Claim.ClaimTypes AS CLT WITH (NOLOCK) ON CLT.ClaimTypeID = RMVD.ClaimTypeID
            LEFT OUTER JOIN Result.DataSetProviderKey AS RDSPK WITH (NOLOCK) ON RDSPK.DataRunID = RMVD.DataRunID AND
                                                              RDSPK.DSProviderID = RMVD.DSProviderID
            LEFT OUTER JOIN Batch.DataSetSources AS BDSS ON BDSS.DataSetID = RMVD.DataSetID AND
                                                            BDSS.DataSourceID = RMVD.DataSourceID
    WHERE   (RMVD.DataRunID = @DataRunID) AND
            ((@CustomerMemberID IS NULL) OR
             (RDSMK.CustomerMemberID = @CustomerMemberID) OR
             (RDSMK.CustomerMemberID LIKE @CustomerMemberID)
            ) AND
            ((@EntityID IS NULL) OR
             (RMVD.EntityID = @EntityID)
            ) AND
            ((@MapTypeID IS NULL) OR
             (RMVD.MapTypeID = @MapTypeID)
            ) AND
            ((@MeasureID IS NULL) OR
             (RMVD.MeasureID = @MeasureID)
            ) AND
            ((@MetricID IS NULL) OR
             (RMVD.MetricID = @MetricID)
            ) AND
            ((@ResultTypeID IS NULL) OR
             (RMVD.ResultTypeID = @ResultTypeID) OR
			 (@ResultTypeID = 255 AND RMVD.ResultTypeID NOT IN (2, 3))
            )
    ORDER BY [Member Last Name],
            [Member First Name],
            [Member DOB],
            [Measure],
            [Key Event Date],
            [Result Type],
            [Metric],
            [Date of Service],
            [Record Mapping],
            RMVD.Iteration,
            [Code Type],
            [Code]
	OPTION (FORCE ORDER, OPTIMIZE FOR UNKNOWN);

END;


GO
GRANT VIEW DEFINITION ON  [Report].[GetEntityEventDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetEntityEventDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetEntityEventDetail] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetEntityEventDetail] TO [Reports]
GO
