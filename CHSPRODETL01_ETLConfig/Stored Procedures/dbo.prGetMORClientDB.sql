SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	07/27/2016
-- Description:	returns a list of DV databases for MOR clients
-- =============================================
CREATE PROCEDURE [dbo].[prGetMORClientDB]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        SELECT  ClientDB
        FROM    dbo.DWLoadConfig
        WHERE   DWLoad = 'MORDWLoad'
                AND Active = 1; 

    END;
GO
