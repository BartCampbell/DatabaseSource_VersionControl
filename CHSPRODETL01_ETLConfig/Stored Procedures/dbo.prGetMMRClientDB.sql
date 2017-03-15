SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	08/01/2016
-- Description:	returns a list of DV databases for MMR clients
-- =============================================
CREATE PROCEDURE [dbo].[prGetMMRClientDB]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        SELECT  ClientDB
        FROM    dbo.DWLoadConfig
        WHERE   DWLoad = 'MMRDWLoad'
                AND Active = 1; 

    END;

GO
