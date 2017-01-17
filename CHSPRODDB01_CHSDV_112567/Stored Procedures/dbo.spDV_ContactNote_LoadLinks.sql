SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/29/2016
 --Updated 09/21/2016 Linked tables changed to CHSDV PJ
 --Updated 09/26/2016 Added record end date cleanup code PJ
 --Update 09/27/2016 Adding LoadDate to Prmiary Key PJ
 --Update 10/03/2016 Removing RecordEndDate and LoadDate , replacing with Link Satellite PJ
-- Description:	Load all Link Tables from the tblContactNotesOfficeStage table.  BAsed on CHSDV.dbo.prDV_ContactNotesOffice_LoadLinks
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ContactNote_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
	
--*LOAD L_ContactNotesOfficeProvider

        INSERT  INTO L_ContactNotesOfficeProvider
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProviderOfficeHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_ProviderOffice b WITH ( NOLOCK ) ON rw.Office_PK = b.ClientProviderOfficeID
                                                                                   AND b.ClientID = rw.CCI
--                        INNER JOIN CHSStaging.adv.tblProviderOfficeWCStage b WITH ( NOLOCK ) ON b.ProviderOffice_PK = rw.Office_PK AND b.CCI = rw.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) NOT IN (
                        SELECT  L_ContactNotesOfficeProvider_RK
                        FROM    L_ContactNotesOfficeProvider
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProviderOfficeHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;

--*LOAD LS_ContactNotesOfficeProvider

        INSERT  INTO [dbo].[LS_ContactNotesOfficeProvider]
                ( [LS_ContactNotesOfficeProvider_RK] ,
                  [LoadDate] ,
                  [L_ContactNotesOfficeProvider_RK] ,
                  [H_ContactNotesOffice_RK] ,
                  [H_Provider_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.[LoadDate] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProviderOfficeHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', 'Y'))), 2)) ,
                        rw.[RecordSource]
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_ProviderOffice b WITH ( NOLOCK ) ON rw.Office_PK = b.ClientProviderOfficeID
                                                                                   AND b.ClientID = rw.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', 'Y'))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    LS_ContactNotesOfficeProvider
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.[LoadDate] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProviderOfficeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', 'Y'))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProviderOfficeHashKey ,
                        rw.[RecordSource]; 

	--RECORD END DATE CLEANUP -- LS_ContactNotesOfficeProvider

        UPDATE  dbo.LS_ContactNotesOfficeProvider
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_ContactNotesOfficeProvider z
                                  WHERE     z.H_ContactNotesOffice_RK = a.H_ContactNotesOffice_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_ContactNotesOfficeProvider a
        WHERE   a.RecordEndDate IS NULL; 



		--** Load L_ContactNotesOfficeUser
        INSERT  INTO L_ContactNotesOfficeUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON b.ClientUserID = rw.LastUpdated_User_PK
                                                                                AND b.ClientID = rw.CCI
						--INNER JOIN CHSStaging.adv.tblUserWCStage b WITH ( NOLOCK ) ON b.User_PK = rw.LastUpdated_User_PK  AND rw.CCi = b.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) NOT IN (
                        SELECT  L_ContactNotesOfficeUser_RK
                        FROM    L_ContactNotesOfficeUser
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;

--** Load LS_ContactNotesOfficeUser

        INSERT  INTO [dbo].[LS_ContactNotesOfficeUser]
                ( [LS_ContactNotesOfficeUser_RK] ,
                  [LoadDate] ,
                  [L_ContactNotesOfficeUser_RK] ,
                  [H_ContactNotesOffice_RK] ,
                  [H_User_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.UserHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, ''))),
                                                                       ':', 'Y'))), 2)) ,
                        rw.RecordSource
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON b.ClientUserID = rw.LastUpdated_User_PK
                                                                                AND b.ClientID = rw.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    LS_ContactNotesOfficeUser
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, ''))),
                                                                       ':', 'Y'))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.UserHashKey ,
                        rw.RecordSource; 


	--RECORD END DATE CLEANUP -- LS_ContactNotesOfficeUser

        UPDATE  dbo.LS_ContactNotesOfficeUser
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_ContactNotesOfficeUser z
                                  WHERE     z.H_ContactNotesOffice_RK = a.H_ContactNotesOffice_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_ContactNotesOfficeUser a
        WHERE   a.RecordEndDate IS NULL; 

--** Load L_ContactNotesOfficeContactNote
        INSERT  INTO L_ContactNotesOfficeContactNote
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ContactNoteHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceContactNote b WITH ( NOLOCK ) ON b.ClientContactNoteID = rw.ContactNote_PK
                                                                                       AND b.ClientID = rw.CCI
                --        INNER JOIN CHSStaging.adv.tblContactNoteStage b WITH ( NOLOCK ) ON b.ContactNote_PK = rw.ContactNote_PK AND rw.CCi = b.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) NOT IN (
                        SELECT  L_ContactNotesOfficeContactNote_RK
                        FROM    L_ContactNotesOfficeContactNote
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ContactNoteHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;

--** Load LS_ContactNotesOfficeContactNote
        INSERT  INTO [dbo].[LS_ContactNotesOfficeContactNote]
                ( [LS_ContactNotesOfficeContactNote_RK] ,
                  [LoadDate] ,
                  [L_ContactNotesOfficeContactNote_RK] ,
				  [H_ContactNotesOffice_RK] ,
				  [H_ContactNote_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
																	   rw.ContactNotesOfficeHashKey,
																	   b.ContactNoteHashKey,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', 'Y'))), 2)) ,
                        rw.RecordSource
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceContactNote b WITH ( NOLOCK ) ON b.ClientContactNoteID = rw.ContactNote_PK
                                                                                       AND b.ClientID = rw.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', 'Y'))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    LS_ContactNotesOfficeContactNote
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriContactNoteID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', 'Y'))), 2)) ,
																	   rw.ContactNotesOfficeHashKey,
																	   b.ContactNoteHashKey,
                        rw.RecordSource;
	
	--RECORD END DATE CLEANUP -- LS_ContactNotesOfficeContactNote
        UPDATE  dbo.LS_ContactNotesOfficeContactNote
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_ContactNotesOfficeContactNote z
                                  WHERE     z.H_ContactNotesOffice_RK = a.H_ContactNotesOffice_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_ContactNotesOfficeContactNote a
        WHERE   a.RecordEndDate IS NULL; 
	


--** Load L_ContactNotesOfficeProject
        INSERT  INTO L_ContactNotesOfficeProject
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProjectHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceProject b WITH ( NOLOCK ) ON b.ClientProjectID = rw.Project_PK
                                                                                   AND b.ClientID = rw.CCI
                        --INNER JOIN CHSStaging.adv.tblProjectStage b WITH ( NOLOCK ) ON b.Project_PK = rw.Project_PK  AND rw.CCi = b.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) NOT IN (
                        SELECT  L_ContactNotesOfficeProject_RK
                        FROM    L_ContactNotesOfficeProject
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        rw.ContactNotesOfficeHashKey ,
                        b.ProjectHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;


--** Load LS_ContactNotesOfficeContactNote
        INSERT  INTO [dbo].[LS_ContactNotesOfficeProject]
                ( [LS_ContactNotesOfficeProject_RK] ,
                  [LoadDate] ,
                  [L_ContactNotesOfficeProject_RK] ,
				  [H_ContactNotesOffice_RK] ,
				  [H_Project_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
														  rw.ContactNotesOfficeHashKey,
														  b.ProjectHashKey,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, ''))),
                                                                       ':', 'Y'))), 2)) ,
                        rw.RecordSource
                FROM    CHSStaging.adv.tblContactNotesOfficeStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceProject b WITH ( NOLOCK ) ON b.ClientProjectID = rw.Project_PK
                                                                                   AND b.ClientID = rw.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, ''))),
                                                                       ':', 'Y'))), 2)) NOT IN ( SELECT HashDiff
                                                                                                 FROM   LS_ContactNotesOfficeProject
                                                                                                 WHERE  RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, '')))))), 2)) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CNI, ''))),
                                                                       ':', 'Y'))), 2)) ,
																	   rw.ContactNotesOfficeHashKey,
														  b.ProjectHashKey,
                        rw.RecordSource;
	
	--RECORD END DATE CLEANUP -- LS_ContactNotesOfficeContactNote
        UPDATE  dbo.LS_ContactNotesOfficeProject
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_ContactNotesOfficeProject z
                                  WHERE     z.H_ContactNotesOffice_RK = a.H_ContactNotesOffice_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_ContactNotesOfficeProject a
        WHERE   a.RecordEndDate IS NULL; 



    END;




GO
