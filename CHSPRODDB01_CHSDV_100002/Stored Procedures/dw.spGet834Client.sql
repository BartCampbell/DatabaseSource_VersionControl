SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	07/20/2016
---- Description:	Gets the latest 834 Client data for loading into the DW
---- =============================================
CREATE PROC [dw].[spGet834Client]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            Client_BK AS CentauriClientID ,
            ClientName
    FROM    dbo.H_Client
    WHERE   LoadDate > @LastLoadTime;


GO
