SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/06/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update adding/dropping new columns for Advance updates 02282017 PDJ
-- Description:	Gets ContactNote details from DV
-- =============================================

CREATE PROCEDURE [dbo].[spGetContactNote]
-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.ContactNote_BK AS [CentauriContactNoteID] ,
                s.[ContactNote_Text] ,
                s.[IsSystem] ,
                s.[sortOrder] ,
                s.[IsIssue] ,
                s.[IsCNA] ,
                s.[IsFollowup] ,
                s.[Followup_days] ,
                s.[IsActive] ,
                s.[IsCopyCenter] ,
                s.[IsRetro] ,
                s.[IsProspective] ,
                s.[IsDataIssue] ,
                s.[AllowedAttempts] ,
				s.[ChaseStatus_PK],
				s.[IsContact],
				s.[ContactNoteID],
				s.[IsIssueLogResponse],
				s.[ProviderOfficeSubBucket_PK],
                @CCI AS [ClientID] ,
                s.[RecordSource] ,
                s.[LoadDate]
        FROM    [dbo].[H_ContactNote] h
                INNER JOIN dbo.S_ContactNoteDetail s ON s.H_ContactNote_RK = h.H_ContactNote_RK AND s.RecordEndDate IS NULL
        WHERE   s.LoadDate > @LoadDate;

    END;

GO
