SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dw].[spGetOECClient]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            Client_BK AS CentauriClientID,
		  ClientName
    FROM    dbo.H_Client
    WHERE   LoadDate > @LastLoadTime;


GO
