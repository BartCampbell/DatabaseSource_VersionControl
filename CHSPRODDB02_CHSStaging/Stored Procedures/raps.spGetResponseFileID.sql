SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	06/10/2016
---- Description:	Gets the responsefileid for loading RAPS stage
---- Usage:			
----		  EXECUTE raps.spGetResponseFileI
---- =============================================
CREATE PROC [raps].[spGetResponseFileID]
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT  ISNULL(MAX(ResponseFileID),0) AS ResponseFileID
    FROM    raps.RAPS_RESPONSE_AAA;


GO
