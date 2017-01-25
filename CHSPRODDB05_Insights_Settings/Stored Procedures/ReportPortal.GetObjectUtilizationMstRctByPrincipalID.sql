SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		George Graves
-- Create date: 06/13/2016
-- Description: Returns a list of the most recent 
-- report views by principal, sorted by created date
-- and views
-- =============================================
CREATE PROCEDURE [ReportPortal].[GetObjectUtilizationMstRctByPrincipalID]
	-- Add the parameters for the stored procedure here
(
 @PrincipalID smallint, 
 @RptObjID smallint
	
)
AS
BEGIN
WITH Results AS
(
    SELECT  CAST(RPOU.CreatedDate AS date) AS CreatedDate,
            RPO.DisplayName,
            RPO.Descr,
            RPOU.RptObjID,
            COUNT(RPOU.RptObjUtilID) AS Viewed,
            COUNT(RPOU.Params) AS ParamCnt,
			CAST(RPOU.Params AS varchar(MAX)) AS Params
    FROM    ReportPortal.ObjectUtilization RPOU
            INNER JOIN ReportPortal.Objects RPO ON RPO.RptObjID = RPOU.RptObjID AND RPO.RptObjTypeID = 2
    WHERE   (RPOU.PrincipalID = @PrincipalID) AND
			(RPOU.RptObjID = @RptObjID)
    GROUP BY RPOU.RptObjID,
            CAST(RPOU.CreatedDate AS date),
            RPO.DisplayName,
            RPO.Descr,
            CAST(RPOU.Params AS varchar(MAX))
	)

	SELECT * FROM Results ORDER BY Results.CreatedDate DESC, Results.Viewed DESC
END;

GO
GRANT EXECUTE ON  [ReportPortal].[GetObjectUtilizationMstRctByPrincipalID] TO [PortalApp]
GO
