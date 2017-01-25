SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/30/2015
-- Description:	Retrieves the report list for the portal for reporting purposes.  
-- =============================================
CREATE PROCEDURE [ReportPortal].[GetReportObjectList] 
AS
BEGIN
	SET NOCOUNT ON;

    SELECT	t.NavigationRoot AS [Navigation Root],
			t.NavigationPath AS [Navigation Path],
			RPO.DisplayName AS [Report],
			REPLACE(REPLACE(RPO.Descr, CHAR(13), ''), CHAR(10), '') AS [Description]
	FROM	ReportPortal.Objects AS RPO WITH(NOLOCK)
			OUTER APPLY ReportPortal.GetNavigationPath(RPO.RptObjID, DEFAULT) AS t
	WHERE	RPO.RptObjTypeID IN (2, 3)
	ORDER BY 1, 2, 3;
		
END
GO
