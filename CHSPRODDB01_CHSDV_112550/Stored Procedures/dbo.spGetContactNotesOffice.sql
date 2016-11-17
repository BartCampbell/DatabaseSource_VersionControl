SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/06/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update 10/03/2016 Adding link satellite instead of record end date for links PJ
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
                INNER JOIN dbo.S_ContactNotesOfficeDetail s ON s.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK AND s.RecordEndDate IS NULL
                LEFT OUTER JOIN (SELECT lcj.H_ContactNotesOffice_RK,lcj.H_Project_RK FROM  dbo.L_ContactNotesOfficeProject lcj 
									INNER JOIN dbo.LS_ContactNotesOfficeProject cjl ON cjl.L_ContactNotesOfficeProject_RK = lcj.L_ContactNotesOfficeProject_RK 	AND cjl.RecordEndDate IS NULL ) cj
						ON cj.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK 
                LEFT OUTER JOIN dbo.H_Project j ON j.H_Project_RK = cj.H_Project_RK 
                LEFT OUTER JOIN (SELECT llcp.H_ContactNotesOffice_RK, llcp.H_ProviderOffice_RK FROM dbo.L_ContactNotesOfficeProvider llcp 
								INNER JOIN dbo.LS_ContactNotesOfficeProvider lcpl ON lcpl.L_ContactNotesOfficeProvider_RK = llcp.L_ContactNotesOfficeProvider_RK AND lcpl.RecordEndDate IS NULL) lcp
						ON lcp.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK 
                LEFT OUTER JOIN dbo.H_ProviderOffice po ON po.H_ProviderOffice_RK = lcp.H_ProviderOffice_RK
                LEFT OUTER JOIN (SELECT llcn.H_ContactNotesOffice_RK,llcn.H_ContactNote_RK   FROM dbo.L_ContactNotesOfficeContactNote llcn 
							INNER JOIN dbo.LS_ContactNotesOfficeContactNote lcnl ON lcnl.L_ContactNotesOfficeContactNote_RK = llcn.L_ContactNotesOfficeContactNote_RK AND lcnl.RecordEndDate IS NULL) lcn
						ON lcn.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK
                LEFT OUTER JOIN dbo.H_ContactNote cn ON cn.H_ContactNote_RK = lcn.H_ContactNote_RK
                LEFT OUTER JOIN (SELECT llcu.H_ContactNotesOffice_RK, llcu.H_User_RK FROM  dbo.L_ContactNotesOfficeUser llcu 
								INNER JOIN dbo.LS_ContactNotesOfficeUser lcul ON lcul.L_ContactNotesOfficeUser_RK = llcu.L_ContactNotesOfficeUser_RK AND lcul.RecordEndDate IS NULL) lcu
					  ON lcu.H_ContactNotesOffice_RK = h.H_ContactNotesOffice_RK
                LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = lcu.H_User_RK
        WHERE   s.LoadDate > @LoadDate;

    END;


GO
