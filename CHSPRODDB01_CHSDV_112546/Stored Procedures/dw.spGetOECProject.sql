SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dw].[spGetOECProject]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.OECProject_BK AS CentauriOECProjectID,
            s.ProjectID ,
            s.ProjectName ,
		  c.Client_BK AS CentauriClientID 
    FROM    dbo.H_OECProject h 
    INNER JOIN dbo.S_OECProject s ON s.H_OECProject_RK = h.H_OECProject_RK
    CROSS JOIN dbo.H_Client c 
    WHERE   s.LoadDate > @LastLoadTime;



GO
