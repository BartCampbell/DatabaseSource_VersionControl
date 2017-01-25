SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/16/2016
-- Description:	Returns a given customer and object from the specified report path.  
-- =============================================
CREATE PROCEDURE [ReportPortal].[GetObjectFromFullReportPath]
(
	@RptCustID smallint = NULL,
	@RptFullPath varchar(1024)
)
AS
BEGIN
	SET NOCOUNT ON;

    WITH Results AS
	(
		SELECT	RPCS.RptCustID,
				RPO.RptObjID,
				REPLACE(RPCS.RptRootPath + '/' + RPO.RptRelPath + '/' + RPO.ObjectName, '//', '/') AS RptFullPath
		FROM	ReportPortal.CustomerSettings AS RPCS
				INNER JOIN ReportPortal.Objects AS RPO
						ON RPO.RptObjTypeID = 2
	)
	SELECT	t.RptCustID, t.RptFullPath, t.RptObjID
	FROM	Results AS t
	WHERE	((@RptCustID IS NULL) OR (t.RptCustID = @RptCustID)) AND
			(t.RptFullPath = @RptFullPath);
END
GO
GRANT EXECUTE ON  [ReportPortal].[GetObjectFromFullReportPath] TO [PortalApp]
GO
