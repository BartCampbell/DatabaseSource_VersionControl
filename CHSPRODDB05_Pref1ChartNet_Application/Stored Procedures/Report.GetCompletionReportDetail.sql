SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Raasch, Mark
-- Create date: 10/30/2014
--Update 03/11/2017 Paul Johnson chaning join to Pursuit to reflect 1-2-1 relationship with PursuitEvent
-- Description:	Returns the detail for completion report detail
-- =============================================
CREATE PROCEDURE [Report].[GetCompletionReportDetail]
(
 @ProductLine varchar(20) = NULL,
 @Product varchar(20) = NULL,
 @MeasureID int = NULL,
 @AbstractionStatusID int = NULL,
 @ChartStatusValueID int = NULL,
 @ChartAttached bit = 0,
 @ProviderSiteID int = NULL,
 @ProviderSiteName varchar(75) = NULL,
 @ProviderSiteAddress varchar(75) = NULL,
 @ProviderID int = NULL,
 @ProviderName varchar(25) = NULL,
 @AbstractionDateStart datetime = NULL,
 @AbstractionDateEnd datetime = NULL,
 @ProviderNPI char(10) = NULL,
 @ProviderTIN varchar(11) = NULL,
 @AbstractorID int = NULL,
 @ChartStatusDetailID int = NULL,
 @ProviderSiteNameID int = NULL,
 @ProviderNameID int = NULL,
 @AbstractionComplete bit = NULL,
 @PursuitNumber varchar(30) = NULL
)
AS
BEGIN

    SET NOCOUNT ON

    SET @ProviderSiteName = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteName,'*', '%'), '?','_'), '%%%', '%'),'%%', '%'), '%');
    SET @ProviderName = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderName,'*', '%'), '?','_'), '%%%', '%'), '%%','%'), '%');
	SET @ProviderSiteAddress = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteAddress,'*', '%'), '?','_'), '%%%', '%'), '%%','%'), '%');

		-- if parent and child chosen, parent is null
	IF @ChartStatusDetailID IS NOT NULL
		SET @ChartStatusValueID = NULL

    SELECT DISTINCT
            mms.productline AS ProductLine,
            mms.Product AS Product,
            ms.HEDISMeasure,
			mms.EventDate,
            ab.[description] AS AbstractionStatus,
            ISNULL(ChartStatus.Title + ': ', '') + cs.Title AS ChartStatus,
            CASE  
			   WHEN ab.IsCompleted = 1 THEN 'Y'
			   WHEN ab.IsCompleted = 0 THEN 'N'
			END AS Complete,
            CASE 
				WHEN ci.PursuitEventChartImageID IS NOT NULL THEN 'Y' ELSE 'N'
            END AS ChartAttached,
            p.PursuitNumber,
            ps.CustomerProviderSiteID,
            ps.ProviderSiteName,
            CASE WHEN ps.Address2 IS NOT NULL AND
                                      ps.Address2 <> ''
                                 THEN ps.Address1 + ' - ' + ps.address2
                                 ELSE ps.Address1
                            END AS SiteAddress,
            ps.City,
            ps.[State],
            ps.Zip,
            ps.Phone,
			ps.Fax,
			ps.Contact,
			pr.CustomerProviderID,
			pr.NPI,
			pr.TaxID AS TIN,
            pr.NameEntityFullName AS ProviderName,
            m.CustomerMemberID AS MemberID,
			m.NameLast + ISNULL(', ' + m.NameFirst, '') + ISNULL(' ' + m.NameMiddleInitial, '') AS MemberName,
            m.DateOfBirth AS DOB,
			m.Gender,
            PVSL.LogDate AS AbstractionDate,
            ISNULL(a.AbstractorName, '') AS Abstractor
	 FROM    MemberMeasureMetricScoring mmms WITH(NOLOCK)
            LEFT JOIN MemberMeasureSample mms WITH(NOLOCK) ON mmms.MemberMeasureSampleID = mms.MemberMeasureSampleID
            -- INNER JOIN Pursuit p WITH(NOLOCK) ON p.MemberID = mms.MemberID
            INNER JOIN PursuitEvent pe WITH(NOLOCK) ON --(pe.PursuitID = p.PursuitID AND pe.EventDate = mms.EventDate AND pe.MeasureID = mms.MeasureID) OR 
											pe.MemberMeasureSampleID = mms.MemberMeasureSampleID
            INNER JOIN Pursuit p WITH(NOLOCK) ON p.PursuitID = pe.PursuitID
			INNER JOIN Measure ms WITH(NOLOCK) ON ms.MeasureID = mms.MeasureID
            INNER JOIN AbstractionStatus ab WITH(NOLOCK) ON ab.AbstractionStatusID = pe.AbstractionStatusID
            INNER JOIN providersite ps WITH(NOLOCK) ON ps.ProviderSiteID = p.ProviderSiteID
            INNER JOIN Providers pr WITH(NOLOCK) ON pr.ProviderID = p.ProviderID
            INNER JOIN Member m WITH(NOLOCK) ON m.MemberID = mms.MemberID
            LEFT OUTER JOIN chartstatusvalue cs WITH(NOLOCK) ON cs.ChartStatusValueID = pe.ChartStatusValueID
            LEFT OUTER JOIN Abstractor a WITH(NOLOCK) ON a.AbstractorID = p.AbstractorID
            OUTER APPLY (SELECT TOP 1 * FROM PursuitEventChartImage tci WITH(NOLOCK) WHERE tci.PursuitEventID = pe.PursuitEventID) AS ci
			OUTER APPLY (
                    SELECT TOP 1
                                LogDate
                    FROM  dbo.PursuitEventStatusLog AS tPVSL WITH(NOLOCK)
                                INNER JOIN dbo.AbstractionStatus AS tAST WITH(NOLOCK)
                                        ON tPVSL.AbstractionStatusID = tAST.AbstractionStatusID AND
                                            tAST.IsCompleted = 1
                    WHERE tPVSL.PursuitEventID = pe.PursuitEventID AND
							tPVSL.AbstractionStatusChanged = 1
                    ORDER BY LogDate DESC
                    ) AS PVSL
			OUTER APPLY (
					SELECT Title
					FROM ChartStatusValue WITH(NOLOCK)
					WHERE ChartStatusValueID = cs.ParentID
					) AS ChartStatus
	WHERE   ((@ProductLine IS NULL) OR (m.ProductLine = @ProductLine) OR (m.ProductLine LIKE '%' + @ProductLine + '%')) 
	AND     ((@Product IS NULL) OR (m.Product = @Product) OR (m.Product LIKE '%' + @Product + '%'))
	AND     ((@MeasureID IS NULL) OR (pe.MeasureID = @MeasureID))
	AND		((@AbstractionStatusID IS NULL) OR (ab.AbstractionStatusID = @AbstractionStatusID))
	AND     ((@ChartAttached IS NULL) OR ((ci.PursuitEventChartImageID IS NULL AND @ChartAttached = 0) OR (ci.PursuitEventChartImageID IS NOT NULL AND @ChartAttached = 1)))
	AND     ((@AbstractorID IS NULL) OR (p.AbstractorID = @AbstractorID) OR (p.AbstractorID IS NULL AND @AbstractorID = -1))
	AND     ((@AbstractionDateStart IS NULL) OR (@AbstractionDateStart <= PVSL.LogDate))
	AND     ((@AbstractionDateEnd IS NULL) OR (PVSL.LogDate < DATEADD(DAY, 1, @AbstractionDateEnd)))
	AND     ((@ProviderSiteID IS NULL) OR (ps.ProviderSiteID = @ProviderSiteID))
    AND     ((@ProviderSiteName IS NULL) OR (ps.ProviderSiteName = @ProviderSiteName) OR (ps.ProviderSiteName LIKE '%' + @ProviderSiteName + '%'))
	AND     ((@ProviderSiteAddress IS NULL) OR (ps.Address1 + ' ' + ps.Address2 LIKE '%' + @ProviderSiteAddress + '%'))
	AND     ((@ProviderID IS NULL) OR (pr.ProviderID = @ProviderID))
	AND     ((@ProviderNPI IS NULL) OR (pr.NPI = @ProviderNPI))
	AND     ((@ProviderTIN IS NULL) OR (pr.TaxID = @ProviderTIN))
	AND     ((@ProviderName IS NULL) OR (pr.NameEntityFullName = @ProviderName) OR (pr.NameEntityFullName LIKE '%' +  @ProviderName + '%') OR (pr.NameLast = @ProviderName) OR (pr.NameLast LIKE '%' + @ProviderName + '%'))
	AND     ((@ChartStatusValueID IS NULL) OR ((pe.ChartStatusValueID IN (SELECT ChartStatusValueID
																		   FROM dbo.ChartStatusValue WITH(NOLOCK)
																		  WHERE ParentID = @ChartStatusValueID)
												OR pe.ChartStatusValueID = @ChartStatusValueID)))
	AND     ((@ChartStatusDetailID IS NULL) OR (pe.ChartStatusValueID = @ChartStatusDetailID))
	AND     ((@ProviderSiteNameID IS NULL) OR (ps.ProviderSiteID = @ProviderSiteNameID))
	AND     ((@ProviderNameID IS NULL) OR (pr.ProviderID = @ProviderNameID))
	AND		((@AbstractionComplete IS NULL) OR (@AbstractionComplete = 1 AND ab.IsCompleted = 1) OR (@AbstractionComplete = 0 AND ab.IsCompleted = 0))
	AND     ((@PursuitNumber IS NULL) OR (LOWER(p.PursuitNumber) = LOWER(@PursuitNumber)))
    ORDER BY productline,
            product,
            HEDISMeasure,
			MemberName,
			Gender,
			DOB,
            PursuitNumber
	OPTION(OPTIMIZE FOR UNKNOWN); 

END


GO
GRANT EXECUTE ON  [Report].[GetCompletionReportDetail] TO [Reporting]
GO
