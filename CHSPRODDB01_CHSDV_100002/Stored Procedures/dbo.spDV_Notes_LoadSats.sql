SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/24/2016
 --Update 09/27/2016 Adding LoadDate to Primary Key PJ
-- Description:	Data Vault NoteType Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Notes_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

INSERT  INTO [dbo].[S_NoteTextDetail]
        ( [S_NoteTextDetail_RK] ,
          [LoadDate] ,
          [H_NoteText_RK] ,
          [NoteText] ,
          [IsDiagnosisNote] ,
          [IsChartNote] ,
          [Client_PK] ,
          [HashDiff] ,
          [RecordSource] 
        )
        SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[NoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDiagnosisNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChartNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Client_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))))), 2)) ,
                LoadDate ,
                NoteTextHashKey ,
                [NoteText] ,
                [IsDiagnosisNote] ,
                [IsChartNote] ,
                [Client_PK] ,
                UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT( RTRIM(LTRIM(COALESCE(rw.[NoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDiagnosisNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChartNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Client_PK],
                                                              '')))))), 2)) ,
                RecordSource
        FROM    CHSStaging.adv.tblNoteTextStage rw WITH ( NOLOCK )
        WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT( RTRIM(LTRIM(COALESCE(rw.[NoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDiagnosisNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChartNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Client_PK],
                                                              '')))))), 2)) NOT IN (
                SELECT  HashDiff
                FROM    S_NoteTextDetail
                WHERE   H_NoteText_RK = rw.NoteTextHashKey
                        AND RecordEndDate IS NULL )
                AND rw.CCI = @CCI
        GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[NoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDiagnosisNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChartNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Client_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LoadDate],
                                                              '')))))), 2)) ,
                LoadDate ,
                NoteTextHashKey ,
                [NoteText] ,
                [IsDiagnosisNote] ,
                [IsChartNote] ,
                [Client_PK] ,
                UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT( RTRIM(LTRIM(COALESCE(rw.[NoteText],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsDiagnosisNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChartNote],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Client_PK],
                                                              '')))))), 2)) ,
                RecordSource;

	--RECORD END DATE CLEANUP
UPDATE  dbo.S_NoteTextDetail
SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                          FROM      dbo.S_NoteTextDetail z
                          WHERE     z.H_NoteText_RK = a.H_NoteText_RK
                                    AND z.LoadDate > a.LoadDate
                        )
FROM    dbo.S_NoteTextDetail a
WHERE   RecordEndDate IS NULL; 
	


	--**S_NoteTypeDetail LOAD
INSERT INTO [dbo].[S_NoteTypeDetail]
           ([S_NoteTypeDetail_RK]
           ,[LoadDate]
           ,[H_NoteType_RK]
           ,[NoteType]
           ,[HashDiff]
           ,[RecordSource]
           )
           SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CTI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[NoteType],
                                                              '')))))), 2)) ,
                LoadDate ,
                NoteTypeHashKey ,
                [NoteType] ,
                UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(RTRIM(LTRIM(COALESCE(rw.[NoteType],''))))), 2)) ,
                RecordSource
        FROM    CHSStaging.adv.tblNoteTypeStage rw WITH ( NOLOCK )
        WHERE     UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(RTRIM(LTRIM(COALESCE(rw.[NoteType],''))))), 2))NOT IN (
                SELECT  HashDiff
                FROM    S_NoteTypeDetail
                WHERE   H_NoteType_RK = rw.NoteTypeHashKey
                        AND RecordEndDate IS NULL )
                AND rw.CCI = @CCI
        GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CTI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[NoteType],
                                                              '')))))), 2)) ,
                LoadDate ,
                NoteTypeHashKey ,
                [NoteType] ,
                UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(RTRIM(LTRIM(COALESCE(rw.[NoteType],''))))), 2)) ,
                RecordSource;

	--RECORD END DATE CLEANUP
UPDATE  dbo.S_NoteTypeDetail
SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                          FROM      dbo.S_NoteTypeDetail z
                          WHERE     z.H_NoteType_RK = a.H_NoteType_RK
                                    AND z.LoadDate > a.LoadDate
                        )
FROM    dbo.S_NoteTypeDetail a
WHERE   RecordEndDate IS NULL; 

    
    END;
    
	

GO
