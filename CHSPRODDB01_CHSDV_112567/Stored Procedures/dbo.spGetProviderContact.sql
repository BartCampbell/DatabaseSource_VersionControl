SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/01/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update 10/04/2016 adding Link Satellite to replace record end PJ
-- Description:	Gets provider contact details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetProviderContact]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20) , 
	   @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT 
		m.ProviderOffice_BK AS CentauriProviderOffice_ID,
                s.Phone AS Phone,
				s.Fax AS Fax,
				s.EmailAddress AS EmailAddress
			
	    FROM    dbo.H_ProviderOffice m 
        INNER JOIN [dbo].[L_ProviderOfficeContact] o ON o.H_ProviderOffice_RK = m.H_ProviderOffice_RK 
		INNER JOIN dbo.LS_ProviderOfficeContact n ON n.L_ProviderOfficeContact_RK = o.L_ProviderOfficeContact_RK AND n.RecordEndDate IS NULL
		INNER JOIN dbo.H_Contact c ON o.H_Contact_RK = c.H_Contact_RK
		INNER JOIN dbo.S_Contact s ON s.H_Contact_RK = c.H_Contact_RK AND s.RecordEndDate IS NULL
        WHERE   s.LoadDate > @LoadDate OR n.LoadDate>@LoadDate;

    END;

GO
