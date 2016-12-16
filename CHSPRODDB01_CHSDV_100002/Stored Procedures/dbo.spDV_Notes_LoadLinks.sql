SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/24/2016
--Updated 09/21/2016 Linked tables changed to CHSDV PJ
--Updated 09/26/2016 Added record end date cleanup code PJ
 --Update 09/27/2016 Adding LoadDate to Primary Key PJ
 --Update 10/04/2016 Replacing RecordEndDate/LoadDate with Link Satellite PJ
-- Description:	Load all Link Tables from the tblNoteTextStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Notes_LoadLinks]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


--** Load L_NoteTextCLIENT
        INSERT  INTO [dbo].[L_NoteTextClient]
                ( [L_NoteTextClient_RK] ,
                  [H_NoteText_RK] ,
                  [H_Client_RK] ,
                  [LoadDate] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.NoteTextHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblNoteTextStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) NOT IN (
                        SELECT  L_NoteTextClient_RK
                        FROM    L_NoteTextClient
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.NoteTextHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;
	

	--** Load L_NoteTypeCLIENT
        INSERT  INTO [dbo].[L_NoteTypeClient]
                ( [L_NoteTypeClient_RK] ,
                  [H_NoteType_RK] ,
                  [H_Client_RK] ,
                  [LoadDate] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CTI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.NoteTypeHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblNoteTypeStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CTI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) NOT IN (
                        SELECT  L_NoteTypeClient_RK
                        FROM    L_NoteTypeClient
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CTI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.CCI, '')))))), 2)) ,
                        rw.NoteTypeHashKey ,
                        rw.ClientHashKey ,
                        rw.LoadDate ,
                        rw.RecordSource;
	
	
	--** Load L_NoteTextType
        INSERT  INTO [dbo].[L_NoteTextType]
                ( [L_NoteTextType_RK] ,
                  [H_NoteText_RK] ,
                  [H_NoteType_RK] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, '')))))), 2)) ,
                        a.NoteTextHashKey ,
                        b.NoteTypeHashKey ,
                        a.LoadDate ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblNoteTextStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_NoteType b WITH ( NOLOCK ) ON b.ClientNoteTypeID = a.NoteType_PK
                                                                             AND b.ClientID = a.CCI
	 --INNER JOIN CHSStaging.adv.tblNoteTypeStage b WITH(NOLOCK)	 ON b.NoteType_PK = a.NoteType_PK AND b.CCI = a.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, '')))))), 2)) NOT IN (
                        SELECT  L_NoteTextType_RK
                        FROM    L_NoteTextType
                        WHERE   RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, '')))))), 2)) ,
                        a.NoteTextHashKey ,
                        b.NoteTypeHashKey ,
                        a.LoadDate ,
                        a.RecordSource;



        INSERT  INTO [dbo].[LS_NoteTextType]
                ( [LS_NoteTextType_RK] ,
                  [LoadDate] ,
                  [L_NoteTextType_RK] ,
                  [H_NoteText_RK] ,
                  [H_NoteType_RK] ,
                  [Active] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, '')))))), 2)) ,
                        a.NoteTextHashKey ,
                        b.NoteTypeHashKey ,
                        'Y' ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, ''))),
                                                                       ':Y'))), 2)) ,
                        a.RecordSource
                FROM    CHSStaging.adv.tblNoteTextStage a WITH ( NOLOCK )
                        INNER JOIN CHSDV.dbo.R_NoteType b WITH ( NOLOCK ) ON b.ClientNoteTypeID = a.NoteType_PK
                                                                             AND b.ClientID = a.CCI
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, ''))),
                                                                       ':Y'))), 2)) NOT IN ( SELECT HashDiff
                                                                                             FROM   LS_NoteTextType
                                                                                             WHERE  RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, '')))))), 2)) ,
                        a.NoteTextHashKey ,
                        b.NoteTypeHashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(b.CentauriNoteTypeID, ''))),
                                                                       ':Y'))), 2)) ,
                        a.RecordSource;

		--RECORD END DATE CLEANUP
        UPDATE  dbo.LS_NoteTextType
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.LS_NoteTextType z
                                  WHERE     z.[H_NoteText_RK] = a.[H_NoteText_RK]
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_NoteTextType a
        WHERE   a.RecordEndDate IS NULL; 


    END;



GO
