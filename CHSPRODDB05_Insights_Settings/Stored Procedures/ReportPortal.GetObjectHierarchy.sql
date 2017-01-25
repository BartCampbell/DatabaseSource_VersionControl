SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [ReportPortal].[GetObjectHierarchy]
AS
BEGIN
    SELECT  ROH.ChildID,
			RO.Descr,
			RO.DisplayName,
			RO.ObjectName,
            ROH.RptObjID,
			RO.RptObjTypeID,
            ROH.Tier,
			OT.Descr AS RptObjType
    FROM    ReportPortal.ObjectHierarchy  AS ROH WITH(NOLOCK)
		LEFT OUTER JOIN ReportPortal.[Objects] AS RO WITH (NOLOCK) 
					ON RO.RptObjID = ROH.ChildID
		INNER JOIN ReportPortal.ObjectTypes AS OT WITH(NOLOCK) 
					ON RO.RptObjTypeID = OT.RptObjTypeID
    ORDER BY Tier,
            ROH.RptObjID,
            RO.DisplayName
END
GO
GRANT EXECUTE ON  [ReportPortal].[GetObjectHierarchy] TO [PortalApp]
GO
