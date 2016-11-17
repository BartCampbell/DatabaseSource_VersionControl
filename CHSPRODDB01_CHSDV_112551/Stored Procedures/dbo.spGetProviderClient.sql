SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Description:	Gets provider client details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetProviderClient]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.Provider_BK AS CentauriproviderID ,
                @CCI AS CentauriClientID ,
                h.ClientproviderID AS ClientproviderID ,
                h.LoadDate AS LoadDate
        FROM    [dbo].[H_provider] h
        WHERE   h.LoadDate > @LoadDate;

    END;
GO
