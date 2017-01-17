SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/07/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
-- Description:	Gets issue response office from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetIssueResponseOffice]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        

        SELECT  h.IssueResponse_BK AS CentauriIssueResponseID ,
                c.ContactNotesOffice_BK AS CentauriContactNotesOfficeID ,
                u.User_PK AS CentaruriUserID ,
                s.[IssueResponse] ,
                ls.[AdditionalResponse] ,
                ls.dtInsert ,
                @CCI AS ClientID ,
                ls.LoadDate AS LoadDate ,
                ls.RecordSource AS RecordSource
        FROM    dbo.H_IssueResponse h
                INNER JOIN dbo.S_IssueResponseDetail s ON s.H_IssueResponse_RK = h.H_IssueResponse_RK AND s.RecordEndDate IS NULL
                INNER JOIN dbo.L_IssueResponseUserContactNotesOffice l ON l.H_IssueResponse_RK = h.H_IssueResponse_RK
                LEFT OUTER JOIN dbo.H_ContactNotesOffice c ON c.H_ContactNotesOffice_RK = l.H_ContactNotesOffice_RK 
                LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = l.H_User_RK
                INNER JOIN dbo.LS_IssueResponseOfficeDetail ls ON ls.L_IssueResponseUserContactNotesOffice_RK = l.L_IssueResponseUserContactNotesOffice_RK AND ls.RecordEndDate IS NULL
        WHERE   ls.LoadDate > @LoadDate OR s.LoadDate>@LoadDate;

    END;



GO
