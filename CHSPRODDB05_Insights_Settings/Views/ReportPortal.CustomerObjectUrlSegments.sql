SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [ReportPortal].[CustomerObjectUrlSegments] AS
SELECT	RC.RptCustGuid,
		RC.RptCustID,
		RO.RptObjGuid,
		RO.RptObjID,
		RO.RptObjTypeID,
		RC.UrlSeg + RO.UrlSeg AS UrlSeg
FROM	ReportPortal.CustomerObjects AS RCO
		INNER JOIN ReportPortal.Customers AS RC
				ON RC.RptCustID = RCO.RptCustID
		INNER JOIN ReportPortal.[Objects] AS RO
				ON RO.RptObjID = RCO.RptObjID
GO
