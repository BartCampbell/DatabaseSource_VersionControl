SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Description:	Gets providers details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetProvider]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20) , 
	   @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.Provider_BK AS CentauriproviderID ,
                s.[LastName] ,
				s.[FirstName],
				s.[NPI],
				s.TIN ,
				s.PIN ,
				s.LastUpdated 
        FROM    [dbo].[H_Provider] h
		INNER JOIN dbo.L_ProviderProviderMaster l ON h.H_Provider_RK = l.H_Provider_RK
		INNER JOIN dbo.H_ProviderMaster m ON l.[H_ProviderMaster_RK] = m.[H_ProviderMaster_RK]
        LEFT OUTER JOIN [dbo].[S_ProviderDemo] s ON s.H_ProviderMaster_RK = m.H_ProviderMaster_RK
        WHERE   s.LoadDate > @LoadDate;

    END;

--GO
GO
