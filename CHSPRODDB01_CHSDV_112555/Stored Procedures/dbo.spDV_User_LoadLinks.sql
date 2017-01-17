SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/15/2016
--Updated 09/21/2016 Linked tables changed to CHSDV PJ
--Updated 09/26/2016 Added record end date cleanup code PJ
--Update 09/27/2016 Adding LoadDate to Primary Key PJ
--Update 10/05/2016 Replacing RecordEndDate and LoadDate in Links with Link Satellites PJ
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
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.UserHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserWCStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) NOT IN (
                        SELECT  L_UserClient_RK
                        FROM    L_UserClient
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.UserHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;


        INSERT  INTO L_UserClient
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.UserHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserRemovedStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) NOT IN (
                        SELECT  L_UserClient_RK
                        FROM    L_UserClient
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.UserHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;



		----RECORD END DATE CLEANUP
  --      UPDATE  dbo.L_UserClient
  --      SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
  --                                FROM      dbo.L_UserClient z
  --                                WHERE     z.[H_User_RK] = a.[H_User_RK]
  --                                          AND z.LoadDate > a.LoadDate
  --                              )
  --      FROM    dbo.L_UserClient a
  --      WHERE   a.RecordEndDate IS NULL; 


		--*** INSERT INTO L_UserCONTACT

        INSERT  INTO L_UserContact
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) NOT IN ( SELECT    L_UserContact_RK
                                                                                                                              FROM      L_UserContact
                                                                                                                              WHERE     RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource;

        INSERT  INTO L_UserContact
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserRemovedStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) NOT IN ( SELECT L_UserContact_RK
                                                                                                                         FROM   L_UserContact
                                                                                                                         WHERE  RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource;

--*** INSERT INTO LS_UserCONTACT
        INSERT  INTO [dbo].[LS_UserContact]
                ( [LS_UserContact_RK] ,
                  [LoadDate] ,
                  [L_UserContact_RK] ,
                  [H_User_RK] ,
                  [H_Location_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                       ':Y'))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblUserWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff
                                                                                             FROM   LS_UserContact
                                                                                             WHERE  RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':', RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE([sch_Tel], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([sch_Fax], ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))),
                                                                       ':Y'))), 2)) ,
                        RecordSource; 


        INSERT  INTO [dbo].[LS_UserContact]
                ( [LS_UserContact_RK] ,
                  [LoadDate] ,
                  [L_UserContact_RK] ,
                  [H_User_RK] ,
                  [H_Location_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, ''))), ':Y'))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblUserRemovedStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, ''))), ':Y'))), 2)) NOT IN ( SELECT   HashDiff
                                                                                                                               FROM     LS_UserContact
                                                                                                                               WHERE    RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(rw.LoadDate, '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':', RTRIM(LTRIM(COALESCE(NULL, '')))))), 2)) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(Email_Address, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(NULL, ''))), ':Y'))), 2)) ,
                        RecordSource; 

		--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_UserContact
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_UserContact z
                                  WHERE     z.[H_User_RK] = a.[H_User_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_UserContact a
        WHERE   a.RecordEndDate IS NULL; 


---**** INSERT INTO L_USERLOCATION

        INSERT  INTO L_UserLocation
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        rw.UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblUserWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) NOT IN (
                        SELECT  L_UserLocation_RK
                        FROM    L_UserLocation
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        rw.UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        rw.LoadDate ,
                        RecordSource;

---**** INSERT INTO LS_USERLOCATION


        INSERT  INTO [dbo].[LS_UserLocation]
                ( [LS_UserLocation_RK] ,
                  [LoadDate] ,
                  [L_UserLocation_RK] ,
                  [H_User_RK] ,
                  [H_Location_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        rw.UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), ''))), ':Y'))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblUserWCStage rw
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), ''))), ':Y'))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    LS_UserLocation
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        rw.UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), '')))))), 2)) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(CUI, ''))), ':', RTRIM(LTRIM(COALESCE([address], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(CAST(zipcode_pk AS VARCHAR), ''))), ':Y'))), 2)) ,
                        RecordSource; 

		--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_UserLocation
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_UserLocation z
                                  WHERE     z.[H_User_RK] = a.[H_User_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_UserLocation a
        WHERE   a.RecordEndDate IS NULL; 

		
--** INSERT INTO L_USERAdvanceLocation

        INSERT  INTO [dbo].[L_UserAdvanceLocation]
                ( [L_UserAdvanceLocation_RK] ,
                  [H_User_RK] ,
                  [H_AdvanceLocation_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, '')))))), 2)) ,
                        a.UserHashKey ,
                        c.LocationHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblUserWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceLocation c WITH ( NOLOCK ) ON c.ClientLocationID = a.Location_PK
                                                                                    AND c.ClientID = a.CCI
                        --INNER JOIN CHSStaging.adv.tblLocationStage c ON a.Location_PK = c.Location_PK
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, '')))))), 2)) NOT IN (
                        SELECT  L_UserAdvanceLocation_RK
                        FROM    L_UserAdvanceLocation
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, '')))))), 2)) ,
                        a.UserHashKey ,
                        c.LocationHashKey ,
                        a.LoadDate ,
                        a.RecordSource;

--** INSERT INTO LS_USERAdvanceLocation

        INSERT  INTO [dbo].[LS_UserAdvanceLocation]
                ( [LS_UserAdvanceLocation_RK] ,
                  [LoadDate] ,
                  [L_UserAdvanceLocation_RK] ,
                  [H_User_RK] ,
                  [H_AdvanceLocation_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, '')))))), 2)) ,
                        a.UserHashKey ,
                        c.LocationHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, ''))),
                                                                       ':Y'))), 2)) ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblUserWCStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceLocation c WITH ( NOLOCK ) ON c.ClientLocationID = a.Location_PK
                                                                                    AND c.ClientID = a.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, ''))),
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff
                                                                                             FROM   LS_UserAdvanceLocation
                                                                                             WHERE  RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, '')))))), 2)) ,
                        a.UserHashKey ,
                        c.LocationHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CUI, ''))), ':', RTRIM(LTRIM(COALESCE(c.CentauriLocationID, ''))),
                                                                       ':Y'))), 2)) ,
                        a.RecordSource;


		--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_UserAdvanceLocation
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_UserAdvanceLocation z
                                  WHERE     z.[H_User_RK] = a.[H_User_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_UserAdvanceLocation a
        WHERE   a.RecordEndDate IS NULL; 



    END;


GO
