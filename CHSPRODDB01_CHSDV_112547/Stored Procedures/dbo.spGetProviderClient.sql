SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
--Update 10/05/2016 adding Provider_ID
-- 10/11/2016 Changing links PJ
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
                CASE WHEN h.ClientProviderID IS NULL THEN s.Provider_ID ELSE h.ClientProviderID END AS ClientProviderID ,
                h.LoadDate AS LoadDate
         FROM    [dbo].[H_Provider] h
		 LEFT OUTER JOIN dbo.S_ProviderMasterDemo s ON s.H_Provider_RK = h.H_Provider_RK
				
        WHERE   h.LoadDate > @LoadDate OR s.LoadDate>@LoadDate;

    END;


GO
