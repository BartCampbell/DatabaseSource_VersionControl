SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/29/2016
-- Description:	Data Vault ContactNotesOffice Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ContactNote_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
		

	--**S_ContactNotesOfficeDetail LOAD
        INSERT  INTO [dbo].[S_ContactNotesOfficeDetail]
                ( [S_ContactNotesOfficeDetail_RK] ,
                  [LoadDate] ,
                  [H_ContactNotesOffice_RK] ,
                  [ContactNoteText] ,
                  [LastUpdated_Date] ,
                  [contact_num] ,
                  [followup] ,
                  [IsResponded] ,
                  [IsViewedByScheduler] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ContactNoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[contact_num],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[followup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsResponded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsViewedByScheduler],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ContactNotesOfficeHashKey ,
                        [ContactNoteText] ,
                        [LastUpdated_Date] ,
                        [contact_num] ,
                        [followup] ,
                        [IsResponded] ,
                        [IsViewedByScheduler] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[ContactNoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[contact_num],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[followup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsResponded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsViewedByScheduler],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[ContactNoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[contact_num],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[followup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsResponded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsViewedByScheduler],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ContactNotesOfficeDetail
                        WHERE   H_ContactNotesOffice_RK = rw.ContactNotesOfficeHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ContactNoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[contact_num],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[followup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsResponded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsViewedByScheduler],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ContactNotesOfficeHashKey ,
                        [ContactNoteText] ,
                        [LastUpdated_Date] ,
                        [contact_num] ,
                        [followup] ,
                        [IsResponded] ,
                        [IsViewedByScheduler] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[ContactNoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[contact_num],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[followup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsResponded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsViewedByScheduler],
                                                              '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ContactNotesOfficeDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ContactNotesOfficeDetail z
                                  WHERE     z.H_ContactNotesOffice_RK = a.H_ContactNotesOffice_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ContactNotesOfficeDetail a
        WHERE   RecordEndDate IS NULL; 

    
	--**S_ContactNoteDetail LOAD

        INSERT  INTO [dbo].[S_ContactNoteDetail]
                ( [S_ContactNoteDetail_RK] ,
                  [LoadDate] ,
                  [H_ContactNote_RK] ,
                  [ContactNote_Text] ,
                  [IsSystem] ,
                  [sortOrder] ,
                  [IsIssue] ,
                  [IsCNA] ,
                  [IsFollowup] ,
                  [Followup_days] ,
                  [IsActive] ,
                  [IsCopyCenter] ,
                  [IsRetro] ,
                  [IsProspective] ,
                  [IsDataIssue] ,
                  [AllowedAttempts] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ContactNote_Text],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsSystem],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCNA],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsFollowup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Followup_days],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsActive],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCopyCenter],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRetro],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsProspective],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDataIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AllowedAttempts],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ContactNoteHashKey ,
                        [ContactNote_Text] ,
                        [IsSystem] ,
                        [sortOrder] ,
                        [IsIssue] ,
                        [IsCNA] ,
                        [IsFollowup] ,
                        [Followup_days] ,
                        [IsActive] ,
                        [IsCopyCenter] ,
                        [IsRetro] ,
                        [IsProspective] ,
                        [IsDataIssue] ,
                        [AllowedAttempts] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[ContactNote_Text],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsSystem],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCNA],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsFollowup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Followup_days],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsActive],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCopyCenter],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRetro],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsProspective],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDataIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AllowedAttempts],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblContactNoteStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[ContactNote_Text],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsSystem],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCNA],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsFollowup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Followup_days],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsActive],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCopyCenter],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRetro],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsProspective],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDataIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AllowedAttempts],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ContactNoteDetail
                        WHERE   H_ContactNote_RK = rw.ContactNoteHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ContactNote_Text],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsSystem],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCNA],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsFollowup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Followup_days],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsActive],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCopyCenter],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRetro],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsProspective],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDataIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AllowedAttempts],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ContactNoteHashKey ,
                        [ContactNote_Text] ,
                        [IsSystem] ,
                        [sortOrder] ,
                        [IsIssue] ,
                        [IsCNA] ,
                        [IsFollowup] ,
                        [Followup_days] ,
                        [IsActive] ,
                        [IsCopyCenter] ,
                        [IsRetro] ,
                        [IsProspective] ,
                        [IsDataIssue] ,
                        [AllowedAttempts] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[ContactNote_Text],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsSystem],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[sortOrder],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCNA],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsFollowup],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Followup_days],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsActive],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsCopyCenter],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRetro],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsProspective],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDataIssue],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[AllowedAttempts],
                                                              '')))))), 2)) ,
                        RecordSource; 



				--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ContactNoteDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ContactNoteDetail z
                                  WHERE     z.H_ContactNote_RK = a.H_ContactNote_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ContactNoteDetail a
        WHERE   RecordEndDate IS NULL; 

    END;
    
	
GO
