SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/18/2016
--Updated 09/21/2016 Linked tables changed to CHSDV PJ
--Updated 09/26/2016 Added record end date cleanup code PJ
 --Update 09/27/2016 Adding LoadDate to Primary Key PJ
 --Update 10/04/2016 Replacing RecordEndDate and LoadDate with Link Satellite PJ
-- Description:	Load all Link Tables from the tblScannedDataStage table.  BAsed on CHSDV.dbo.prDV_ScannedData_LoadLinks
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ScannedData_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


--** Load L_ScannedDataUser
        INSERT  INTO L_ScannedDataUser
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblScannedDataStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON b.ClientUserID = rw.User_PK
                                                                                AND b.ClientID = rw.CCI
	 --INNER JOIN CHSStaging.adv.tblUserWCStage b with(nolock) 	 ON b.User_PK = rw.User_PK AND rw.CCi = b.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) NOT IN (
                        SELECT  L_ScannedDataUser_RK
                        FROM    L_ScannedDataUser
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;


--** Load LS_ScannedDataUser

        INSERT  INTO [dbo].[LS_ScannedDataUser]
                ( [LS_ScannedDataUser_RK] ,
                  [LoadDate] ,
                  [L_ScannedDataUser_RK] ,
                  [H_ScannedData_RK] ,
                  [H_User_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.UserHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                       ':Y'))), 2)) ,
                        rw.RecordSource
                FROM    CHSStaging.adv.tblScannedDataStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON b.ClientUserID = rw.User_PK
                                                                                AND b.ClientID = rw.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff
                                                                                             FROM   LS_ScannedDataUser
                                                                                             WHERE  RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                       ':Y'))), 2)) ,
                        rw.RecordSource; 

--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_ScannedDataUser
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_ScannedDataUser z
                                  WHERE     z.[H_ScannedData_RK] = a.[H_ScannedData_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_ScannedDataUser a
        WHERE   a.RecordEndDate IS NULL; 
		


--*LOAD L_ScannedDataSuspect

        INSERT  INTO L_ScannedDataSuspect
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.SuspectHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblScannedDataStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceSuspect b WITH ( NOLOCK ) ON b.ClientSuspectID = rw.Suspect_PK
                                                                                   AND b.ClientID = rw.CCI
	 --INNER JOIN CHSStaging.adv.tblSuspectWCStage b WITH(NOLOCK) 	 ON b.Suspect_PK = rw.Suspect_PK AND rw.CCi = b.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) NOT IN (
                        SELECT  L_ScannedDataSuspect_RK
                        FROM    L_ScannedDataSuspect
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.SuspectHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;


--*LOAD LS_ScannedDataSuspect

        INSERT  INTO [dbo].[LS_ScannedDataSuspect]
                ( [LS_ScannedDataSuspect_RK] ,
                  [LoadDate] ,
                  [L_ScannedDataSuspect_RK] ,
                  [H_ScannedData_RK] ,
                  [H_Suspect_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.SuspectHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                       ':Y'))), 2)) ,
                        rw.RecordSource
                FROM    CHSStaging.adv.tblScannedDataStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceSuspect b WITH ( NOLOCK ) ON b.ClientSuspectID = rw.Suspect_PK
                                                                                   AND b.ClientID = rw.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff
                                                                                             FROM   LS_ScannedDataSuspect
                                                                                             WHERE  RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.SuspectHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriSuspectID, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CSI, ''))),
                                                                       ':Y'))), 2)) ,
                        rw.RecordSource; 

							--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_ScannedDataSuspect
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_ScannedDataSuspect z
                                  WHERE     z.[H_ScannedData_RK] = a.[H_ScannedData_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_ScannedDataSuspect a
        WHERE   a.RecordEndDate IS NULL; 
		
--** Load L_ScannedDataDocumentType
        INSERT  INTO L_ScannedDataDocumentType
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.DocumentTypeHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblScannedDataStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_DocumentType b WITH ( NOLOCK ) ON b.ClientDocumentTypeID = rw.DocumentType_PK
                                                                                 AND b.ClientID = rw.CCI
	 	 --INNER JOIN CHSStaging.adv.tblDocumentTypeStage b WITH(NOLOCK) 	 ON b.DocumentType_PK = rw.DocumentType_PK AND rw.CCi = b.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) NOT IN ( SELECT   L_ScannedDataDocumentType_RK
                                                                                                                           FROM     L_ScannedDataDocumentType
                                                                                                                           WHERE    RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.DocumentTypeHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;

--** Load LS_ScannedDataDocumentType

        INSERT  INTO [dbo].[LS_ScannedDataDocumentType]
                ( [LS_ScannedDataDocumentType_RK] ,
                  [LoadDate] ,
                  [L_ScannedDataDocumentType_RK] ,
                  [H_ScannedData_RK] ,
                  [H_DocumentType_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.DocumentTypeHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':Y'))), 2)) ,
                        rw.RecordSource
                FROM    CHSStaging.adv.tblScannedDataStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_DocumentType b WITH ( NOLOCK ) ON b.ClientDocumentTypeID = rw.DocumentType_PK
                                                                                 AND b.ClientID = rw.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':Y'))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    LS_ScannedDataDocumentType
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CSI, '')))))), 2)) ,
                        rw.ScannedDataHashKey ,
                        b.DocumentTypeHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(b.CentauriDocumentTypeID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.CSI, ''))), ':Y'))), 2)) ,
                        rw.RecordSource; 

--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_ScannedDataDocumentType
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_ScannedDataDocumentType z
                                  WHERE     z.[H_ScannedData_RK] = a.[H_ScannedData_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_ScannedDataDocumentType a
        WHERE   a.RecordEndDate IS NULL; 
		

    END;


GO
