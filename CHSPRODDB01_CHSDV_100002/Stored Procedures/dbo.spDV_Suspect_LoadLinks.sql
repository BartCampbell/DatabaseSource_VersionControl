SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/19/2016
--Update 09/21/20166 to change over to CHSDV from CHSStaging tables  for L_ table creations PJ
--Update 09/22/2016 to update for MemberPK  PJ
-- Update 09/26/2016 update for provider PJ
--Updated 09/26/2016 Added record end date cleanup code PJ
--Upated 09/27/2016 Removed RecordEnddate for L_SuspectUser PJ
 --Update 09/27/2016 Adding LoadDate to Primary Key PJ
 --Update 10/04/2016 Replace RecordEndDate/LoadDate with Link Satellite PJ
 --Update 10/25/2016 Adding provideroffice to LS_SuspectProvider PJ
-- Description:	Load all Link Tables from the tblSuspectWCStage table
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Suspect_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS --DECLARE  @CCI VARCHAR(50)
--SET @cci=112546
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


--** Load L_SuspectCLIENT
        INSERT  INTO L_SuspectClient
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.SuspectHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectClient_RK
                        FROM    L_SuspectClient
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.SuspectHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;


		
		
--** Load L_SuspectProject
        INSERT  INTO L_SuspectProject
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceProject b WITH ( NOLOCK ) ON a.Project_PK = b.ClientProjectID
                                                                                   AND b.ClientID = @CCI
                        --INNER JOIN CHSStaging.adv.tblProjectStage b WITH ( NOLOCK ) ON a.Project_PK = b.Project_PK AND b.ClientID = @CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectProject_RK
                        FROM    L_SuspectProject
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource;

--** Load LS_SuspectProject

        INSERT  INTO [dbo].[LS_SuspectProject]
                ( [LS_SuspectProject_RK] ,
                  [LoadDate] ,
                  [L_SuspectProject_RK] ,
                  [H_Suspect_RK] ,
                  [H_Project_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.ProjectHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))),
                                                                       ':Y'))), 2)) ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceProject b WITH ( NOLOCK ) ON a.Project_PK = b.ClientProjectID
                                                                                   AND b.ClientID = @CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))),
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff
                                                                                             FROM   LS_SuspectProject
                                                                                             WHERE  RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.ProjectHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriProjectID, ''))),
                                                                       ':Y'))), 2)) ,
                        a.RecordSource; 


		--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_SuspectProject
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_SuspectProject z
                                  WHERE     z.[H_Suspect_RK] = a.[H_Suspect_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_SuspectProject a
        WHERE   a.RecordEndDate IS NULL; 
		
	 
--** Load L_SuspectProvider
        INSERT  INTO L_SuspectProvider
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.H_Provider_RK ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                   FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
				        INNER JOIN ( SELECT d.Provider_PK,l.H_Provider_RK FROM dbo.L_ProviderMasterOffice l INNER JOIN dbo.LS_ProviderMasterOffice d ON d.L_ProviderMasterOffice_RK = l.L_ProviderMasterOffice_RK AND d.RecordEndDate IS NULL ) b
									ON CAST(a.Provider_PK AS VARCHAR) = b.Provider_PK
                        --INNER JOIN CHSDV.dbo.R_Provider b WITH ( NOLOCK ) ON CAST(a.Provider_PK AS VARCHAR)= b.ClientProviderID
                        --                                      AND b.ClientID = a.CCI
                        --                                      AND b.ClientProviderID IS NOT NULL
                        --INNER JOIN CHSStaging.adv.tblProviderStage b WITH ( NOLOCK ) ON a.Provider_PK = b.Provider_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectProvider_RK
                        FROM    L_SuspectProvider
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.H_Provider_RK ,
                        a.LoadDate ,
                        a.RecordSource;

--** Load LS_SuspectProvider


        INSERT  INTO [dbo].[LS_SuspectProvider]
                ( [LS_SuspectProvider_RK] ,
                  [LoadDate] ,
                  [L_SuspectProvider_RK] ,
                  [H_Suspect_RK] ,
                  [H_Provider_RK] ,
				  [H_ProviderOffice_RK],
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, ''))), ':',
														   RTRIM(LTRIM(COALESCE(b.[H_ProviderOffice_RK], ''))), ':',
														   RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.H_Provider_RK ,
						b.[H_ProviderOffice_RK],
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, ''))), ':',
														   RTRIM(LTRIM(COALESCE(b.[H_ProviderOffice_RK], ''))), ':Y'))), 2)) ,
                        a.RecordSource
                   FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN ( SELECT d.Provider_PK,l.H_Provider_RK,l.H_ProviderOffice_RK FROM dbo.L_ProviderMasterOffice l 
						INNER JOIN dbo.LS_ProviderMasterOffice d ON d.L_ProviderMasterOffice_RK = l.L_ProviderMasterOffice_RK  WHERE d.RecordEndDate IS null ) b
									ON CAST(a.Provider_PK AS VARCHAR) = b.Provider_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, ''))), ':',
														   RTRIM(LTRIM(COALESCE(b.[H_ProviderOffice_RK], ''))), ':Y'))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    LS_SuspectProvider
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, ''))), ':',
														   RTRIM(LTRIM(COALESCE(b.[H_ProviderOffice_RK], ''))), ':',
														   RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.H_Provider_RK ,
						b.[H_ProviderOffice_RK],
                        
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.Provider_PK, ''))), ':',
														   RTRIM(LTRIM(COALESCE(b.[H_ProviderOffice_RK], ''))), ':Y'))), 2)) ,
                        a.RecordSource; 

		--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_SuspectProvider
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_SuspectProvider z
                                  WHERE     z.[H_Suspect_RK] = a.[H_Suspect_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_SuspectProvider a
        WHERE   a.RecordEndDate IS NULL; 
		
	 
--** Load L_SuspectMember
        INSERT  INTO L_SuspectMember
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.MemberHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN dbo.S_MemberDetail d WITH ( NOLOCK ) ON d.Member_PK = a.Member_PK
                        INNER JOIN CHSDV.dbo.R_Member b WITH ( NOLOCK ) ON d.H_Member_RK = b.MemberHashKey
                                                                           AND b.[ClientID] = @CCI

                        --INNER JOIN CHSStaging.adv.tblMemberWCStage b WITH ( NOLOCK ) ON a.Member_PK = b.Member_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectMember_RK
                        FROM    L_SuspectMember
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.MemberHashKey ,
                        a.LoadDate ,
                        a.RecordSource;

--** Load LS_SuspectMember

        INSERT  INTO [dbo].[LS_SuspectMember]
                ( [LS_SuspectMember_RK] ,
                  [LoadDate] ,
                  [L_SuspectMember_RK] ,
                  [H_Suspect_RK] ,
                  [H_Member_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.MemberHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, ''))),
                                                                       ':Y'))), 2)) ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN dbo.S_MemberDetail d WITH ( NOLOCK ) ON d.Member_PK = a.Member_PK
                        INNER JOIN CHSDV.dbo.R_Member b WITH ( NOLOCK ) ON d.H_Member_RK = b.MemberHashKey
                                                                           AND b.[ClientID] = @CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, ''))),
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff
                                                                                             FROM   LS_SuspectMember
                                                                                             WHERE  RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.MemberHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriMemberID, ''))),
                                                                       ':Y'))), 2)) ,
                        a.RecordSource; 

						
		--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_SuspectMember
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_SuspectMember z
                                  WHERE     z.[H_Suspect_RK] = a.[H_Suspect_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_SuspectMember a
        WHERE   a.RecordEndDate IS NULL; 
		
	 
--** Load L_SuspectUser from ScannedUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON a.Scanned_User_PK = b.[ClientUserID]
                                                                                AND b.[ClientID] = @CCI
                        --INNER JOIN CHSStaging.adv.tblUserWCStage b WITH ( NOLOCK ) ON a.Scanned_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;



					 
--** Load L_SuspectUser from CNAUSer
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON a.CNA_User_PK = b.[ClientUserID]
                                                                                AND b.[ClientID] = @CCI
                        --INNER JOIN CHSStaging.adv.tblUserWCStage b WITH ( NOLOCK ) ON a.CNA_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


	 
--** Load L_SuspectUser from CodedUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON a.Coded_User_PK = b.[ClientUserID]
                                                                                AND b.[ClientID] = @CCI
                        --INNER JOIN CHSStaging.adv.tblUserWCStage b WITH ( NOLOCK ) ON a.Coded_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;
	 
	 
--** Load L_SuspectUser from QAUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON a.QA_User_PK = b.[ClientUserID]
                                                                                AND b.[ClientID] = @CCI
                        --INNER JOIN CHSStaging.adv.tblUserWCStage b WITH ( NOLOCK ) ON a.QA_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;

						--** Load L_SuspectUser from tblSuspectChartRecLogStage
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[CentauriSuspectID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.[adv].[tblSuspectChartRecLogStage] rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.[dbo].[R_AdvanceSuspect] a WITH ( NOLOCK ) ON rw.Suspect_PK = a.[ClientSuspectID]
                                                                                       AND a.ClientID = @CCI
						--INNER JOIN	CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK ) ON rw.suspect_pk = a.suspect_pk
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON rw.User_PK = b.[ClientUserID]
                                                                                AND b.[ClientID] = @CCI
                        --INNER JOIN CHSStaging.adv.tblUserWCStage b WITH ( NOLOCK ) ON rw.User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[CentauriSuspectID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[CentauriSuspectID], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;


		----RECORD END DATE CLEANUP
  --      UPDATE  dbo.L_SuspectUser
  --      SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
  --                                FROM      dbo.L_SuspectUser z
  --                                WHERE     z.[H_Suspect_RK] = a.[H_Suspect_RK]
  --                                          AND z.LoadDate > a.LoadDate
  --                              )
  --      FROM    dbo.L_SuspectUser a
  --      WHERE   a.RecordEndDate IS NULL; 
		

	 --REMOVED USER
	 /* NOT NEEDED AFTER SWAPPING TO USING R_ADVANCEUSER
--** Load L_SuspectUser from ScannedUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblUserRemovedStage b
                        WITH ( NOLOCK ) ON a.Scanned_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


	 
--** Load L_SuspectUser from CNAUSer
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblUserRemovedStage b
                        WITH ( NOLOCK ) ON a.CNA_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


	 
--** Load L_SuspectUser from CodedUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblUserRemovedStage b
                        WITH ( NOLOCK ) ON a.Coded_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;
	 
	 
--** Load L_SuspectUser from QAUser
        INSERT  INTO L_SuspectUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSStaging.adv.tblUserRemovedStage b
                        WITH ( NOLOCK ) ON a.QA_User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUser_RK
                        FROM    L_SuspectUser
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                        AND b.UserHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(b.CentauriUserID,
                                                              '')))))), 2)) ,
                        a.SuspectHashKey ,
                        b.UserHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


						*/
----**Load L_SupsectUserNote

--        INSERT  INTO [dbo].[L_SuspectUserNote]
--                ( [L_SuspectUserNote_RK] ,
--                  [H_Suspect_RK] ,
--                  [H_User_RK] ,
--                  [H_NoteText_RK] ,
--                  [LoadDate] ,
--                  [RecordSource]
--                )
--                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
--                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CUI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CNI,
--                                                              '')))))), 2)) ,
--                        a.SuspectHashKey ,
--                        a.UserHashKey ,
--                        a.NoteTextHashKey ,
--                        a.LoadDate ,
--                        a.RecordSource
--                FROM    CHSStaging.adv.tblSuspectNoteStage a WITH ( NOLOCK )
--                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
--                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CUI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CNI,
--                                                              '')))))), 2)) NOT IN (
--                        SELECT  L_SuspectUserNote_RK
--                        FROM    L_SuspectUserNote
--                        WHERE   RecordEndDate IS NULL )
--                        AND a.CCI = @CCI
--                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
--                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CUI,
--                                                              ''))), ':',
--                                                              RTRIM(LTRIM(COALESCE(a.CNI,
--                                                              '')))))), 2)) ,
--                        a.SuspectHashKey ,
--                        a.UserHashKey ,
--                        a.NoteTextHashKey ,
--                        a.LoadDate ,
--                        a.RecordSource;


--  UPDATE  CHSStaging.[adv].[tblSuspectNoteStage]
--        SET     [SuspectUserNoteHashKey] = c.[L_SuspectUserNote_RK]
--        FROM    CHSStaging.[adv].[tblSuspectNoteStage] a
--                INNER JOIN [dbo].[L_SuspectUserNote] c ON ISNULL(a.SuspectHashKey,
--                                                              '') = ISNULL(c.H_Suspect_RK,
--                                                              '')
--                                                              AND ISNULL(a.UserHashKey,
--                                                              '') = ISNULL(c.H_User_RK,
--                                                              '')
--                                                              AND ISNULL(a.NoteTextHashKey,
--                                                              '') = ISNULL(c.H_NoteText_RK,
--                                                              '')
--															  WHERE   a.CCI = @CCI
--															  ;


															  
--**Load L_SupsectUserScanningNotes

        INSERT  INTO [dbo].[L_SuspectUserScanningNotes]
                ( [L_SuspectUserScanningNotes_RK] ,
                  [H_Suspect_RK] ,
                  [H_User_RK] ,
                  [H_ScanningNotes_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.CNI, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        a.UserHashKey ,
                        a.ScanningNoteHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblSuspectScanningNotesStage a WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.CNI, '')))))), 2)) NOT IN (
                        SELECT  L_SuspectUserScanningNotes_RK
                        FROM    L_SuspectUserScanningNotes
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.CNI, '')))))), 2)) ,
                        a.SuspectHashKey ,
                        a.UserHashKey ,
                        a.ScanningNoteHashKey ,
                        a.LoadDate ,
                        a.RecordSource;



		----RECORD END DATE CLEANUP
  --      UPDATE  dbo.L_SuspectUserScanningNotes
  --      SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
  --                                FROM      dbo.L_SuspectUserScanningNotes z
  --                                WHERE     z.[H_Suspect_RK] = a.[H_Suspect_RK]
  --                                          AND z.LoadDate > a.LoadDate
  --                              )
  --      FROM    dbo.L_SuspectUserScanningNotes a
  --      WHERE   a.RecordEndDate IS NULL; 
		

        UPDATE  CHSStaging.[adv].[tblSuspectScanningNotesStage]
        SET     [SuspectUserScanningNoteHashKey] = c.[L_SuspectUserScanningNotes_RK]
        FROM    CHSStaging.[adv].[tblSuspectScanningNotesStage] a
                INNER JOIN [dbo].[L_SuspectUserScanningNotes] c ON ISNULL(a.SuspectHashKey, '') = ISNULL(c.H_Suspect_RK, '')
                                                                   AND ISNULL(a.UserHashKey, '') = ISNULL(c.H_User_RK, '')
                                                                   AND ISNULL(a.ScanningNoteHashKey, '') = ISNULL(c.H_ScanningNotes_RK, '')
                                                                   AND c.RecordEndDate IS NULL
        WHERE   a.CCI = @CCI;



						--									  --** Load L_SuspectUser from tblSuspectChartRecLogStage
      --  INSERT  INTO L_SuspectUser
      --          SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
      --                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
      --                                                        ''))), ':',
      --                                                        RTRIM(LTRIM(COALESCE(b.CentauriUserID,
      --                                                        '')))))), 2)) ,
      --                  a.SuspectHashKey ,
      --                  b.UserHashKey ,
      --                  a.LoadDate ,
      --                  a.RecordSource ,
      --                  NULL
      --          FROM    CHSStaging.[adv].[tblSuspectChartRecLogStage] rw WITH ( NOLOCK )
						--INNER JOIN	CHSStaging.adv.tblSuspectWCStage a WITH ( NOLOCK ) ON rw.suspect_pk = a.suspect_pk
      --                  INNER JOIN CHSStaging.adv.tblUserRemovedStage b WITH ( NOLOCK ) ON rw.User_PK = b.User_PK
      --          WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
      --                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
      --                                                        ''))), ':',
      --                                                        RTRIM(LTRIM(COALESCE(b.CentauriUserID,
      --                                                        '')))))), 2)) NOT IN (
      --                  SELECT  L_SuspectUser_RK
      --                  FROM    L_SuspectUser
      --                  WHERE   RecordEndDate IS NULL )
      --                  AND a.CCI = @CCI
      --                  AND b.UserHashKey IS NOT NULL
      --          GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
      --                                                    UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CSI,
      --                                                        ''))), ':',
      --                                                        RTRIM(LTRIM(COALESCE(b.CentauriUserID,
      --                                                        '')))))), 2)) ,
      --                  a.SuspectHashKey ,
      --                  b.UserHashKey ,
      --                  a.LoadDate ,
      --                  a.RecordSource


	--					--**LS_InvoiceInfo LOAD

 --       INSERT  INTO [dbo].[LS_InvoiceInfo]
 --               ( [LS_InvoiceInfo_RK] ,
 --                 [LoadDate] ,
 --                 [L_SuspectUserInvoiceVendor_RK] ,
 --                 [InvoiceNumber] ,
 --                 [AccountNumber] ,
 --                 [InvoiceAmount] ,
 --                 [dtInsert] ,
 --                 [IsApproved] ,
 --                 [Update_User_PK] ,
 --                 [dtUpdate] ,
 --                 [Invoice_PK] ,
 --                 [AmountPaid] ,
 --                 [Check_Transaction_Number] ,
 --                 [PaymentType_PK] ,
 --                 [InvoiceAccountNumber] ,
 --                 [Inv_File] ,
 --                 [IsPaid] ,
 --                 [HashDiff] ,
 --                 [RecordSource]
 --               )
 --               SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                         UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CUI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CVI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtInsert],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsApproved],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Inv_File],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsPaid],
 --                                                             '')))))), 2)) ,
 --                       LoadDate ,
 --                       [SuspectUserInvoiceVendorHashKey] ,
 --                       RTRIM(LTRIM([InvoiceNumber])) ,
 --                       RTRIM(LTRIM([AccountNumber])) ,
 --                       RTRIM(LTRIM([InvoiceAmount])) ,
 --                       [dtInsert] ,
 --                       [IsApproved] ,
 --                       [Update_User_PK] ,
 --                       [dtUpdate] ,
 --                       [Invoice_PK] ,
 --                       [AmountPaid] ,
 --                       RTRIM(LTRIM([Check_Transaction_Number])) ,
 --                       [PaymentType_PK] ,
 --                       RTRIM(LTRIM([InvoiceAccountNumber])) ,
 --                       [Inv_File] ,
 --                       [IsPaid] ,
 --                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                         UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtInsert],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsApproved],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Inv_File],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsPaid],
 --                                                             '')))))), 2)) ,
 --                       RecordSource
 --               FROM    CHSStaging.adv.tblSuspectInvoiceInfoStage rw WITH ( NOLOCK )
 --               WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                         UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtInsert],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsApproved],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Inv_File],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsPaid],
 --                                                             '')))))), 2)) NOT IN (
 --                       SELECT  HashDiff
 --                       FROM    LS_InvoiceInfo
 --                       WHERE   L_SuspectUserInvoiceVendor_RK = rw.SuspectUserInvoiceVendorHashKey
 --                               AND RecordEndDate IS NULL )
 --                       AND rw.CCI = @CCI
 --               GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CUI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CVI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtInsert],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsApproved],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Inv_File],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsPaid],
 --                                                             '')))))), 2)) ,
 --                       LoadDate ,
 --                       [SuspectUserInvoiceVendorHashKey] ,
 --                       RTRIM(LTRIM([InvoiceNumber])) ,
 --                       RTRIM(LTRIM([AccountNumber])) ,
 --                       RTRIM(LTRIM([InvoiceAmount])) ,
 --                       [dtInsert] ,
 --                       [IsApproved] ,
 --                       [Update_User_PK] ,
 --                       [dtUpdate] ,
 --                       [Invoice_PK] ,
 --                       [AmountPaid] ,
 --                       RTRIM(LTRIM([Check_Transaction_Number])) ,
 --                       [PaymentType_PK] ,
 --                       RTRIM(LTRIM([InvoiceAccountNumber])) ,
 --                       [Inv_File] ,
 --                       [IsPaid] ,
 --                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                         UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[InvoiceNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAmount],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtInsert],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsApproved],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Update_User_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[dtUpdate],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Invoice_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[AmountPaid],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Check_Transaction_Number],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[PaymentType_PK],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[InvoiceAccountNumber],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Inv_File],
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[IsPaid],
 --                                                             '')))))), 2)) ,
 --                       RecordSource;

	----RECORD END DATE CLEANUP
 --       UPDATE  dbo.LS_InvoiceInfo
 --       SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
 --                                 FROM      dbo.LS_InvoiceInfo z
 --                                 WHERE     z.[LS_InvoiceInfo_RK] = a.[LS_InvoiceInfo_RK]
 --                                           AND z.LoadDate > a.LoadDate
 --                               )
 --       FROM    dbo.LS_InvoiceInfo a
 --       WHERE   a.RecordEndDate IS NULL; 





	--	--**LS_SuspectNote LOAD

 --       INSERT  INTO [dbo].[LS_SuspectNote]
 --               ( [LS_SuspectNote_RK] ,
 --                 [LoadDate] ,
 --                 [L_SuspectUserNote_RK] ,
 --                 [Coded_Date] ,
 --                 [HashDiff] ,
 --                 [RecordSource]
 --               )
 --               SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                         UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CUI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CNI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
 --                                                             '')))))), 2)) ,
 --                       LoadDate ,
 --                       [SuspectUserNoteHashKey] ,
 --                       rw.[Coded_Date] ,
 --                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                         UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CUI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CNI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
 --                                                             '')))))), 2)) ,
 --                       RecordSource
 --               FROM    CHSStaging.adv.tblSuspectNoteStage rw WITH ( NOLOCK )
 --               WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                         UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CUI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CNI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
 --                                                             '')))))), 2)) NOT IN (
 --                       SELECT  HashDiff
 --                       FROM    [LS_SuspectNote]
 --                       WHERE   [L_SuspectUserNote_RK] = rw.[SuspectUserNoteHashKey]
 --                               AND RecordEndDate IS NULL )
 --                       AND rw.CCI = @CCI
 --               GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CUI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CNI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
 --                                                             '')))))), 2)) ,
 --                       LoadDate ,
 --                       [SuspectUserNoteHashKey] ,
 --                       rw.[Coded_Date] ,
 --                       UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
 --                                                         UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CUI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.CNI,
 --                                                             ''))), ':',
 --                                                             RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
 --                                                             '')))))), 2)) ,
 --                       RecordSource;

	----RECORD END DATE CLEANUP
 --       UPDATE  dbo.LS_SuspectNote
 --       SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
 --                                 FROM      dbo.LS_SuspectNote z
 --                                 WHERE     z.LS_SuspectNote_RK = a.LS_SuspectNote_RK
 --                                           AND z.LoadDate > a.LoadDate
 --                               )
 --       FROM    dbo.LS_SuspectNote a
 --       WHERE   a.RecordEndDate IS NULL; 



		
		--**LS_SuspectScanningNote LOAD

		
        INSERT  INTO [dbo].[LS_SuspectScanningNote]
                ( [LS_SuspectScanningNote_RK] ,
                  [LoadDate] ,
                  [L_SuspectUserScanningNotes_RK] ,
                  [dtInsert] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[dtInsert], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        [SuspectUserScanningNoteHashKey] ,
                        rw.[dtInsert] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[dtInsert], '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblSuspectScanningNotesStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[dtInsert], '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    [LS_SuspectScanningNote]
                        WHERE   [L_SuspectUserScanningNotes_RK] = rw.[SuspectUserScanningNoteHashKey]
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[dtInsert], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        [SuspectUserScanningNoteHashKey] ,
                        rw.[dtInsert] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[dtInsert], '')))))), 2)) ,
                        RecordSource;


	--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_SuspectScanningNote
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_SuspectScanningNote z
                                  WHERE     z.LS_SuspectScanningNote_RK = a.LS_SuspectScanningNote_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_SuspectScanningNote a
        WHERE   a.RecordEndDate IS NULL; 

    END;


GO
