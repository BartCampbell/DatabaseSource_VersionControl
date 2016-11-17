SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/07/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update 11/08/2016 Adding LS_ProviderMasterOffice PJ
-- Description:	Gets provider office  from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetProviderOffice]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) , 
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT DISTINCT
                h.Provider_BK AS CentauriProviderID ,
                m.ProviderOffice_BK AS CentauriProviderOfficeID ,
			    @CCI AS ClientID ,
                m.LoadDate AS LoadDate ,
                m.RecordSource AS RecordSource
        FROM    [dbo].[H_Provider] h
                INNER JOIN (SELECT lm.H_Provider_RK,lm.H_ProviderOffice_RK FROM dbo.L_ProviderMasterOffice lm 
				INNER JOIN dbo.LS_ProviderMasterOffice ls ON ls.L_ProviderMasterOffice_RK = lm.L_ProviderMasterOffice_RK AND ls.RecordEndDate IS null) l
					 ON h.H_Provider_RK = l.H_Provider_RK  -- AND l.RecordEndDate IS NULL
                INNER JOIN dbo.H_ProviderOffice m ON l.[H_ProviderOffice_RK] = m.[H_ProviderOffice_RK]
        WHERE   m.LoadDate > @LoadDate;

    END;

GO
