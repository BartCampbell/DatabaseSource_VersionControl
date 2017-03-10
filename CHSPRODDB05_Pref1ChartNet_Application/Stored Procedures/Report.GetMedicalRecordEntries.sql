SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetMedicalRecordEntries]
(
 @ProductLine varchar(20) = NULL,
 @Product varchar(20) = NULL,
 @MeasureID int = NULL,
 @MetricID int = NULL,
 @MeasureComponentID int = NULL,
 @AbstractionStatusID int = NULL,
 @ChartStatusValueID int = NULL,
 @ProviderSiteName varchar(75) = NULL,
 @ProviderID int = NULL,
 @ProviderName varchar(25) = NULL,
 @ProviderSiteID int = NULL,
 @AbstractorID int = NULL,
 @AbstractionDateStart datetime = NULL,
 @AbstractionDateEnd datetime = NULL,
 @DataEntryDateStart datetime = NULL,
 @DataEntryDateEnd datetime = NULL,
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

    SELECT 
	
			MBR.ProductLine,
			MBR.Product,
			M.HEDISMeasure AS Measure,
            M.HEDISMeasureDescription AS MeasureDescription,
            MC.ComponentName AS MeasureComponentName,
            MC.Title AS MeasureComponentTitle,
            R.PursuitNumber,
            P.ProviderID,
            P.CustomerProviderID,
            P.NameEntityFullName AS ProviderName,
            PS.ProviderSiteID,
            PS.CustomerProviderSiteID,
            PS.ProviderSiteName,
            PS.Address1 AS ProviderSiteAddress1,
            PS.Address2 AS ProviderSiteAddress2,
            PS.City AS ProviderSiteAddressCity,
            PS.[State] AS ProviderSiteAddressState,
            PS.Zip AS ProviderSiteAddressZip,
            PS.County AS ProviderSiteAddressCounty,
            PS.Phone AS ProviderSitePhone,
            PS.Fax AS ProviderSiteFax,
            PS.Contact AS ProviderSiteContact,
            MBR.MemberID,
            MBR.CustomerMemberID,
            MBR.NameLast + ISNULL(', ' + MBR.NameFirst, '') + ISNULL(' ' +
                                                              MBR.NameMiddleInitial,
                                                              '') AS MemberName,
            MBR.DateOfBirth,
            MBR.Gender,
            AST.Description AS AbstractionStatus,
            ISNULL(PCSV.Title + ': ', '') + CSV.Title AS ChartStatus,
            PVSL.LogDate AS AbstractionDate,
            A.AbstractorName,
            CONVERT(varchar(64), MRC.MeasureComponentID) + '-' +
            CONVERT(varchar(64), MRC.PursuitEventID) + '-' +
            CONVERT(varchar(64), MRC.MedicalRecordKey) AS IMIRef,
            MRC.MedicalRecordKey,
            MRC.PursuitID,
            MRC.PursuitEventID,
            MRC.ServiceDate,
            MRC.CreatedDate,
            MRC.CreatedUser,
            MRC.LastChangedDate,
            MRC.LastChangedUser,
            MRC.ColId01,
            MRC.ColTitle01,
            MRC.ColType01,
            MRC.ColValue01,
            MRC.ColId02,
            MRC.ColTitle02,
            MRC.ColType02,
            MRC.ColValue02,
            MRC.ColId03,
            MRC.ColTitle03,
            MRC.ColType03,
            MRC.ColValue03,
            MRC.ColId04,
            MRC.ColTitle04,
            MRC.ColType04,
            MRC.ColValue04,
            MRC.ColId05,
            MRC.ColTitle05,
            MRC.ColType05,
            MRC.ColValue05,
            MRC.ColId06,
            MRC.ColTitle06,
            MRC.ColType06,
            MRC.ColValue06,
            MRC.ColId07,
            MRC.ColTitle07,
            MRC.ColType07,
            MRC.ColValue07,
            MRC.ColId08,
            MRC.ColTitle08,
            MRC.ColType08,
            MRC.ColValue08,
            MRC.ColId09,
            MRC.ColTitle09,
            MRC.ColType09,
            MRC.ColValue09,
            MRC.ColId10,
            MRC.ColTitle10,
            MRC.ColType10,
            MRC.ColValue10,
            MRC.ColId11,
            MRC.ColTitle11,
            MRC.ColType11,
            MRC.ColValue11,
            MRC.ColId12,
            MRC.ColTitle12,
            MRC.ColType12,
            MRC.ColValue12,
            MRC.MeasureComponentID,
			MMMS.CountCompliant,
            MMMS.CountExclusion,
            MMMS.CountMetrics
    FROM    dbo.MedicalRecordComposite AS MRC WITH(NOLOCK)
            INNER JOIN dbo.MeasureComponent AS MC WITH(NOLOCK) ON MC.MeasureComponentID = MRC.MeasureComponentID
            INNER JOIN dbo.Pursuit AS R WITH(NOLOCK) ON R.PursuitID = MRC.PursuitID
            INNER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK) ON RV.PursuitEventID = MRC.PursuitEventID
            INNER JOIN dbo.Measure AS M WITH(NOLOCK) ON M.MeasureID = MC.MeasureID
            INNER JOIN dbo.Member AS MBR WITH(NOLOCK) ON MBR.MemberID = R.MemberID
            INNER JOIN dbo.Providers AS P WITH(NOLOCK) ON P.ProviderID = R.ProviderID
            INNER JOIN dbo.ProviderSite AS PS WITH(NOLOCK) ON PS.ProviderSiteID = R.ProviderSiteID
            LEFT OUTER JOIN dbo.Abstractor AS A WITH(NOLOCK) ON A.AbstractorID = R.AbstractorID
            LEFT OUTER JOIN dbo.AbstractionStatus AS AST WITH(NOLOCK) ON AST.AbstractionStatusID = RV.AbstractionStatusID
            OUTER APPLY (SELECT TOP 1
                                LogDate
                         FROM   dbo.PursuitEventStatusLog AS tPVSL WITH(NOLOCK)
                                INNER JOIN dbo.AbstractionStatus AS tAST WITH(NOLOCK) ON tPVSL.AbstractionStatusID = tAST.AbstractionStatusID AND
                                                              tAST.IsCompleted = 1
                         WHERE  tPVSL.PursuitEventID = RV.PursuitEventID AND
								tPVSL.AbstractionStatusChanged = 1
                         ORDER BY LogDate DESC
                        ) AS PVSL
			OUTER APPLY (SELECT TOP 1
								SUM(CASE WHEN tMMMS.HybridHitCount > 0 THEN 1 ELSE 0 END) AS CountCompliant,
								SUM(CASE WHEN tMMMS.ReqExclusion = 1 OR tMMMS.Exclusion = 1 OR tMMMS.SampleVoid = 1 THEN 1 ELSE 0 END) AS CountExclusion,
								SUM(CASE WHEN tMMMS.ReqExclusion = 0 AND tMMMS.Exclusion = 0 AND tMMMS.SampleVoid = 0 THEN 1 ELSE 0 END) AS CountMetrics
						FROM	dbo.MemberMeasureSample AS tMMS WITH(NOLOCK)
								INNER JOIN dbo.MemberMeasureMetricScoring AS tMMMS WITH(NOLOCK)
										ON tMMMS.MemberMeasureSampleID = tMMS.MemberMeasureSampleID
								INNER JOIN dbo.HEDISSubMetric AS tMX WITH(NOLOCK)
										ON tMX.HEDISSubMetricID = tMMMS.HEDISSubMetricID AND
											tMX.DisplayInScoringPanel = 1
								INNER JOIN dbo.MeasureComponentMetrics AS tMCMX WITH(NOLOCK)
										ON tMCMX.HEDISSubMetricID = tMMMS.HEDISSubMetricID
						WHERE	tMCMX.MeasureComponentID = MRC.MeasureComponentID AND
								tMMS.MemberID = R.MemberID AND
								tMMS.EventDate = RV.EventDate 
						) AS MMMS
            LEFT OUTER JOIN dbo.ChartStatusValue AS CSV WITH(NOLOCK) ON CSV.ChartStatusValueID = RV.ChartStatusValueID
            LEFT OUTER JOIN dbo.ChartStatusValue AS PCSV WITH(NOLOCK) ON PCSV.ChartStatusValueID = CSV.ParentID
    WHERE   (MC.EnabledOnWebsite = 1) AND
			((@ProductLine IS NULL) OR
             (MBR.ProductLine = @ProductLine) OR
             (MBR.ProductLine LIKE '%' + @ProductLine + '%')
            ) AND
            ((@Product IS NULL) OR
             (MBR.Product = @Product) OR
             (MBR.Product LIKE '%' + @Product + '%')
            ) AND
            ((@MeasureID IS NULL) OR
             (RV.MeasureID = @MeasureID)
            ) AND
			((@MeasureComponentID IS NULL) OR (MRC.MeasureComponentID = @MeasureComponentID)) AND
            ((@AbstractionStatusID IS NULL) OR
             (AST.AbstractionStatusID = @AbstractionStatusID)
            ) AND
            ((@ProviderSiteName IS NULL) OR
             (PS.ProviderSiteName = @ProviderSiteName) OR
             (PS.ProviderSiteName LIKE '%' + @ProviderSiteName + '%')
            ) AND
            ((@ProviderSiteID IS NULL) OR
             (R.ProviderSiteID = @ProviderSiteID)
            ) AND
            ((@ProviderID IS NULL) OR
             (R.ProviderID = @ProviderID)
            ) AND
            ((@ProviderName IS NULL) OR
             (P.NameEntityFullName = @ProviderName) OR
             (P.NameEntityFullName LIKE '%' + @ProviderName + '%') OR
             (P.NameLast = @ProviderName) OR
             (P.NameLast LIKE '%' + @ProviderName + '%')
            ) AND
            ((@AbstractorID IS NULL) OR
             (R.AbstractorID = @AbstractorID) OR
             (R.AbstractorID IS NULL AND
              @AbstractorID = -1
             )
            ) AND
            ((@AbstractionDateStart IS NULL) OR
             (@AbstractionDateStart <= PVSL.LogDate)
            ) AND
            ((@AbstractionDateEnd IS NULL) OR
             (PVSL.LogDate < DATEADD(DAY, 1, @AbstractionDateEnd))
            ) AND
			((@DataEntryDateStart IS NULL) OR
             (@DataEntryDateStart <= MRC.CreatedDate) OR
             (@DataEntryDateStart <= MRC.LastChangedDate)
            ) AND
            ((@DataEntryDateEnd IS NULL) OR
             (MRC.CreatedDate < DATEADD(DAY, 1, @DataEntryDateEnd))
			  OR
             (MRC.LastChangedDate < DATEADD(DAY, 1, @DataEntryDateEnd))
            ) AND
            ((@ChartStatusValueID IS NULL) OR
             (( RV.ChartStatusValueID IN (
              SELECT    ChartStatusValueID
              FROM      dbo.ChartStatusValue WITH(NOLOCK)
              WHERE     ParentID = @ChartStatusValueID) OR
              RV.ChartStatusValueID = @ChartStatusValueID)
             )
            ) AND
            ((@ProviderSiteNameID IS NULL) OR
             (PS.ProviderSiteID = @ProviderSiteNameID)
            ) AND
            ((@ProviderNameID IS NULL) OR
             (P.ProviderID = @ProviderNameID)
            ) AND
            ((@PursuitNumber IS NULL) OR
             (R.PursuitNumber = @PursuitNumber)
            ) AND
            ((@UserName IS NULL) OR
             (ISNULL(@FilterOnUserName, 0) = 0) OR
             (A.UserName = @UserName)
            )
    ORDER BY Measure,
            MeasureComponentName,
			ProductLine, 
			Product,
			PursuitNumber,
            MedicalRecordKey;

END

GO
GRANT EXECUTE ON  [Report].[GetMedicalRecordEntries] TO [Reporting]
GO
