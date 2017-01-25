SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[PortalServiceLogView]
AS
SELECT     
	pl.PortalServiceLogID, 
	pl.PortalServiceLogParentID, 
	pl.PortalSiteID, 
	pl.ServiceID, 
	pl.CreatorID, 
	pl.OwnerID, 
	pl.AssignedUserID, 
	pl.PortalServiceLogStatusID, 
    pl.PortalServiceLogSeverityID, 
	pl.PortalServiceLogImportanceID, 
	pl.PortalServiceLogComplexityID, 
	pl.PortalServiceLogCategoryID, 
	pl.CategoryOther,   
	pl.PortalServiceLogResolutionTypeID, 
	pl.ResolutionTypeOther, 
	pl.Priority, 
	pl.CreateDate, 
	pl.LastUpdate, 
	pl.RequestedDate, 
	pl.DueDate, 
	pl.IsWorkOrder, 
	pl.Title, 
	pl.Description, 
    pl.Resolution,
	ISNULL(plc.[Name], '') As Category,
	ISNULL(plc.SortNum, 0) AS CategorySortNum,
	ISNULL(plcx.[Name], '') As Complexity,
	ISNULL(plcx.SortNum, 0) As ComplexitySortNum,
	ISNULL(pli.[Name], '') As Importance,
	ISNULL(pli.SortNum, 0) As ImportanceSortNum,
	ISNULL(pls.[Name], '') As Severity,
	ISNULL(pls.SortNum, 0) As SeveritySortNum,
	ISNULL(pls2.[Name], '') As Status,
	ISNULL(pls2.SortNum, 0) As StatusSortNum,
	ISNULL(pslrt.[Name], '') AS ResolutionType,
	ISNULL(pslrt.SortNum, 0) AS ResolutionTypeSortNum

FROM         
	PortalServiceLog pl

LEFT OUTER JOIN
	PortalServiceLogCategory plc
ON	plc.PortalServiceLogCategoryID = pl.PortalServiceLogCategoryID

LEFT OUTER JOIN
	PortalServiceLogComplexity plcx
ON	plcx.PortalServiceLogComplexityID = pl.PortalServiceLogComplexityID

LEFT OUTER JOIN
	PortalServiceLogImportance pli
ON	pli.PortalServiceLogImportanceID = pl.PortalServiceLogImportanceID

LEFT OUTER JOIN
	PortalServiceLogSeverity pls
ON	pls.PortalServiceLogSeverityID = pl.PortalServiceLogSeverityID

LEFT OUTER JOIN
	PortalServiceLogStatus pls2
ON	pls2.PortalServiceLogStatusID = pl.PortalServiceLogStatusID

LEFT JOIN PortalServiceLogResolutionType pslrt ON pslrt.PortalServiceLogResolutionTypeID = pl.PortalServiceLogResolutionTypeID

GO
