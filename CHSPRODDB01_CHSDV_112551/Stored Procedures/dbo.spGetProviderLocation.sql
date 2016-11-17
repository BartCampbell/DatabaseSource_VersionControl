SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Description:	Gets provider Location details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetProviderLocation]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20) , 
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  m.ProviderOffice_BK AS CentauriProviderOffice_ID ,
                s.Address1 AS Addr1 ,
                s.Address2 AS Addr2 ,
                s.City AS City ,
                s.State AS State ,
                s.ZIP AS Zip ,
                s.County AS County
        FROM    dbo.H_ProviderOffice m
                INNER JOIN [dbo].[L_ProviderOfficeLocation] o ON o.H_ProviderOffice_RK = m.H_ProviderOffice_RK
                INNER JOIN dbo.H_Location c ON o.H_Location_RK = c.H_Location_RK
                INNER JOIN dbo.S_Location s ON s.H_Location_RK = c.H_Location_RK
        WHERE   s.LoadDate > @LoadDate;

    END;
GO
