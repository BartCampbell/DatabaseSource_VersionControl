SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	08/17/2016
-- Description:	returns a list of DV databases for HEDIS clients
-- =============================================
CREATE PROCEDURE [dbo].[spGetHEDISClients]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        SELECT CentauriClientID ,
               ClientDB ,
               InboundDirectory 
	   FROM dbo.DVLoadConfig 
	   WHERE Active = 1 AND DVLoad = 'HEDIS'

    END;


GO
