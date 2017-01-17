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
  --Update 10/03/2016 Replace reecord end date and loaddate in link with Link Satellite PJ
-- Description:	Load all Link Tables from the tblExtractionQueueStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ExtractionQueue_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


--** Load L_ExtractionQueueUser
        INSERT  INTO [dbo].[L_ExtractionQueueUser]
                ( [L_ExtractionQueueUser_RK] ,
                  [H_ExtractionQueue_RK] ,
                  [H_User_RK] ,
                  [LoadDate] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        rw.ExtractionQueueHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblExtractionQueueStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON b.ClientUserID = rw.AssignedUser_PK
                                                                                AND b.ClientID = rw.CCI
	 --INNER JOIN CHSStaging.adv.tblUserWCStage b ON rw.AssignedUser_PK = b.User_PK	AND b.CCI = rw.CCI
                WHERE  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2))
														  NOT IN ( SELECT  L_ExtractionQueueUser_RK
                                                                                            FROM    L_ExtractionQueueUser
                                                                                            WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        rw.ExtractionQueueHashKey ,
                        b.UserHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;


--** Load LS_ExtractionQueueUser
        INSERT  INTO [dbo].[LS_ExtractionQueueUser]
                ( [LS_ExtractionQueueUser_RK] ,
                  [LoadDate] ,
                  [L_ExtractionQueueUser_RK] ,
                  [H_ExtractionQueue_RK] ,
                  [H_User_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        rw.ExtractionQueueHashKey ,
                        b.UserHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))),
                                                                       ':Y'))), 2)) ,
                        rw.RecordSource
                FROM    CHSStaging.adv.tblExtractionQueueStage rw WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_AdvanceUser b WITH ( NOLOCK ) ON b.ClientUserID = rw.AssignedUser_PK
                                                                                AND b.ClientID = rw.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))),
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff
                                                                                             FROM   LS_ExtractionQueueUser
                                                                                             WHERE  RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        rw.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, '')))))), 2)) ,
                        rw.ExtractionQueueHashKey ,
                        b.UserHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CEI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriUserID, ''))),
                                                                       ':Y'))), 2)) ,
                        rw.RecordSource; 


	--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_ExtractionQueueUser
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_ExtractionQueueUser z
                                  WHERE     z.[H_ExtractionQueue_RK] = a.[H_ExtractionQueue_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_ExtractionQueueUser a
        WHERE   a.RecordEndDate IS NULL; 


    END;




GO
