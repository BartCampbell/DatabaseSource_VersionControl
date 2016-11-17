SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/23/2016
-- Description:	Load all Link Tables from the tblUserStage table
-- =============================================
CREATE PROCEDURE [dbo].[spDV_User_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


--** Load L_UserCLIENT
        INSERT  INTO L_UserClient
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CCI,
                                                              '')))))), 2)) ,
                        rw.UserHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CCI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_UserClient_RK
                        FROM    L_UserClient
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CCI,
                                                              '')))))), 2)) ,
                        rw.UserHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;



        INSERT  INTO L_UserClient
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CCI,
                                                              '')))))), 2)) ,
                        rw.UserHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserRemovedStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CCI,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_UserClient_RK
                        FROM    L_UserClient
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.CCI,
                                                              '')))))), 2)) ,
                        rw.UserHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;

		--*** INSERT INTO L_UserCONTACT

        INSERT  INTO L_UserContact
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([sch_Tel],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([sch_Fax],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([sch_Fax],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([sch_Tel],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([sch_Fax],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_UserContact_RK
                        FROM    L_UserContact
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([sch_Tel],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([sch_Fax],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([sch_Fax],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource;




						
        INSERT  INTO L_UserContact
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserRemovedStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_UserContact_RK
                        FROM    L_UserContact
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(NULL,
                                                              '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource;

---**** INSERT INTO L_USERLOCATION

        INSERT  INTO L_UserLocation
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR),
                                                              '')))))), 2)) ,
                        rw.UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR),
                                                              '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR),
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_UserLocation_RK
                        FROM    L_UserLocation
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE([address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR),
                                                              '')))))), 2)) ,
                        rw.UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR),
                                                              '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource;

--** INSERT INTO L_USERPROJECT

        INSERT  INTO [dbo].[L_UserProject]
                ( [L_UserProject_RK] ,
                  [H_User_RK] ,
                  [H_Project_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Project_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        b.UserHashKey ,
                        c.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblUserProjectStage a
                        INNER JOIN CHSStaging.adv.tblUserRemovedStage b ON a.User_PK = b.User_PK
                        INNER JOIN CHSStaging.adv.tblProjectStage c ON a.Project_PK = c.Project_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Project_PK AS VARCHAR),
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_UserProject_RK
                        FROM    L_UserProject
                        WHERE   RecordEndDate IS NULL )
                        AND b.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Project_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        b.UserHashKey ,
                        c.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource;


        INSERT  INTO [dbo].[L_UserProject]
                ( [L_UserProject_RK] ,
                  [H_User_RK] ,
                  [H_Project_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Project_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        b.UserHashKey ,
                        c.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblUserProjectStage a
                        INNER JOIN CHSStaging.adv.tblUserStage b ON a.User_PK = b.User_PK
                        INNER JOIN CHSStaging.adv.tblProjectStage c ON a.Project_PK = c.Project_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Project_PK AS VARCHAR),
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_UserProject_RK
                        FROM    L_UserProject
                        WHERE   RecordEndDate IS NULL )
                        AND b.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Project_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        b.UserHashKey ,
                        c.ProjectHashKey ,
                        a.LoadDate ,
                        a.RecordSource;



	---**** INSERT INTO L_UserSession

        INSERT  INTO [dbo].[L_UserSession]
                ( [L_UserSession_RK] ,
                  [H_User_RK] ,
                  [H_Session_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Session_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        b.UserHashKey ,
                        a.SessionHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblUserSessionStage a
                        INNER JOIN CHSStaging.adv.tblUserStage b ON a.User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Session_PK AS VARCHAR),
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_UserSession_RK
                        FROM    L_UserSession
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Session_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        b.UserHashKey ,
                        a.SessionHashKey ,
                        a.LoadDate ,
                        a.RecordSource;



        INSERT  INTO [dbo].[L_UserSession]
                ( [L_UserSession_RK] ,
                  [H_User_RK] ,
                  [H_Session_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Session_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        b.UserHashKey ,
                        a.SessionHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblUserSessionStage a
                        INNER JOIN CHSStaging.adv.tblUserRemovedStage b ON a.User_PK = b.User_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Session_PK AS VARCHAR),
                                                              '')))))), 2)) NOT IN (
                        SELECT  L_UserSession_RK
                        FROM    L_UserSession
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CUI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.User_PK AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(a.Session_PK AS VARCHAR),
                                                              '')))))), 2)) ,
                        b.UserHashKey ,
                        a.SessionHashKey ,
                        a.LoadDate ,
                        a.RecordSource;

--        DECLARE @sql VARCHAR(2000);--,	@CCI VARCHAR(50)
--				--SET @cci='112551'

--        SET @sql = 'UPDATE  CHSStaging.adv.tblUserSessionStage
--SET     UserSessionHashKey = c.[L_UserSession_RK]
--FROM    CHSStaging.adv.tblUserSessionStage a
--INNER JOIN CHSStaging.adv.tblUserStage b ON a.User_PK = b.User_pk AND a.CCI = '
--            + @CCI + '                             
--        INNER JOIN CHSDV_' + @CCI
--            + '.dbo.L_UserSession c ON a.SessionHashKey = c.H_Session_RK AND b.UserHashKey = c.H_User_RK';

--        EXEC (@sql);
 UPDATE  CHSStaging.adv.tblUserSessionStage
SET     UserSessionHashKey = c.[L_UserSession_RK]
FROM    CHSStaging.adv.tblUserSessionStage a
INNER JOIN CHSStaging.adv.tblUserStage b ON a.User_PK = b.User_pk AND a.CCI = @CCI 
        INNER JOIN dbo.L_UserSession c ON a.SessionHashKey = c.H_Session_RK AND b.UserHashKey = c.H_User_RK;
		
		
--** INSERT INTO L_USERAdvanceLocation

        INSERT  INTO [dbo].[L_UserAdvanceLocation]
                ( [L_UserAdvanceLocation_RK] ,
                  [H_User_RK] ,
                  [H_AdvanceLocation_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                               RTRIM(LTRIM(COALESCE(c.CLI,
                                                              '')))))), 2)) ,
                        a.UserHashKey ,
                        c.LocationHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM     CHSStaging.adv.tblUserStage a
                        INNER JOIN CHSStaging.adv.tblLocationStage c ON a.Location_PK = c.Location_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                               RTRIM(LTRIM(COALESCE(c.CLI,
                                                              '')))))), 2))  NOT IN (
                        SELECT  L_UserAdvanceLocation_RK
                        FROM    L_UserAdvanceLocation
                        WHERE   RecordEndDate IS NULL )
								AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI,
                                                              ''))), ':',
                                                               RTRIM(LTRIM(COALESCE(c.CLI,
                                                              '')))))), 2)) ,
                        a.UserHashKey ,
                        c.LocationHashKey ,
                        a.LoadDate ,
                        a.RecordSource


--** Insert into LS_UserSession
						
        INSERT  INTO [dbo].[LS_UserSession]
                ( [LS_UserSession_RK] ,
                  [LoadDate] ,
                  [L_UserSession_RK] ,
                  [SessionStart] ,
                  [SesssionEnd] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(rw.SessionStart AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(rw.SessionEnd AS VARCHAR),
                                                              '')))))), 2)) ,
                        LoadDate ,
                        UserSessionHashKey ,
                        rw.SessionStart ,
                        rw.SessionEnd ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CAST(rw.SessionStart AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(rw.SessionEnd AS VARCHAR),
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblUserSessionStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CAST(rw.SessionStart AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(rw.SessionEnd AS VARCHAR),
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    LS_UserSession
                        WHERE   L_UserSession_RK = rw.UserSessionHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                        AND rw.UserSessionHashKey IS NOT NULL
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CSI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(rw.SessionStart AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(rw.SessionEnd AS VARCHAR),
                                                              '')))))), 2)) ,
                        LoadDate ,
                        UserSessionHashKey ,
                        rw.SessionStart ,
                        rw.SessionEnd ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CAST(rw.SessionStart AS VARCHAR),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CAST(rw.SessionEnd AS VARCHAR),
                                                              '')))))), 2)) ,
                        RecordSource;


					--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_UserSession
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_UserSession z
                                  WHERE     z.L_UserSession_RK = a.L_UserSession_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_UserSession a
        WHERE   RecordEndDate IS NULL; 


    END;
GO
