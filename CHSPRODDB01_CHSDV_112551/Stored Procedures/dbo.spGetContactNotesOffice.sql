SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/06/2016
-- Description:	Gets ContactNotesOffice details from DV
-- =============================================

CREATE PROCEDURE [dbo].[spGetContactNotesOffice]
-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.ContactNotesOffice_BK AS [CentauriContactNotesOfficeID] ,
                j.Project_BK AS [CentauriProjectID] ,
                po.ProviderOffice_BK AS [CentauriProviderOfficeID] ,
                cn.ContactNote_BK AS [CentauriContactNoteID] ,
                s.[ContactNoteText] ,
                u.User_PK AS [CentauriUserID] ,
                s.[LastUpdated_Date] ,
                s.[contact_num] ,
                s.[followup] ,
                s.[IsResponded] ,
                s.[IsViewedByScheduler] ,
                @CCI AS [ClientID] ,
                s.[RecordSource] ,
                s.[LoadDate]
        FROM    [dbo].[H_ContactNotesOffice] h
                INNER JOIN dbo.S_ContactNotesOfficeDetail s ON s.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK
                LEFT OUTER JOIN dbo.L_ContactNotesOfficeProject cj ON cj.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK
                LEFT OUTER JOIN dbo.H_Project j ON j.H_Project_RK = cj.H_Project_RK
                LEFT OUTER JOIN dbo.L_ContactNotesOfficeProvider lcp ON lcp.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK
                LEFT OUTER JOIN dbo.H_ProviderOffice po ON po.H_ProviderOffice_RK = lcp.H_ProviderOffice_RK
                LEFT OUTER JOIN dbo.L_ContactNotesOfficeContactNote lcn ON lcn.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK
                LEFT OUTER JOIN dbo.H_ContactNote cn ON cn.H_ContactNote_RK = lcn.H_ContactNote_RK
                LEFT OUTER JOIN dbo.L_ContactNotesOfficeUser lcu ON lcu.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK
                LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = lcu.H_User_RK
        WHERE   s.LoadDate > @LoadDate;

    END;
GO
