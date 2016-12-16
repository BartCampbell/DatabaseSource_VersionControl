SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
--Update 09/27/2016 Adding LoadDate to Primary Key PJ
-- Description:	Data Vault ScanningNotes Load Satelites
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ScanningNotes_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_ScanningNotesDEMO LOAD
        INSERT  INTO [dbo].[S_ScanningNotesDetails]
                ( [S_ScanningNotesDetails_RK] ,
                  [LoadDate] ,
                  [H_ScanningNotes_RK] ,
                  [Note_Text] ,
                  [IsCNA] ,
                  [LastUpdated] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Note_Text], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(rw.[IsCNA], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[LastUpdated], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        ScanningNotesHashKey ,
                        RTRIM(LTRIM(rw.[Note_Text])) ,
                        rw.[IsCNA] ,
                        rw.[LastUpdated] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Note_Text], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[IsCNA], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[LastUpdated], '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblScanningNotesStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Note_Text], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[IsCNA], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[LastUpdated], '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ScanningNotesDetails
                        WHERE   H_ScanningNotes_RK = rw.ScanningNotesHashKey
                                AND RecordEndDate IS NULL )
	--				AND rw.cci = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CNI, ''))), ':', RTRIM(LTRIM(COALESCE(rw.[Note_Text], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[IsCNA], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LastUpdated], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(rw.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        ScanningNotesHashKey ,
                        RTRIM(LTRIM(rw.[Note_Text])) ,
                        rw.[IsCNA] ,
                        rw.[LastUpdated] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[Note_Text], ''))), ':', RTRIM(LTRIM(COALESCE(rw.[IsCNA], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(rw.[LastUpdated], '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ScanningNotesDetails
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ScanningNotesDetails z
                                  WHERE     z.H_ScanningNotes_RK = a.H_ScanningNotes_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ScanningNotesDetails a
        WHERE   a.RecordEndDate IS NULL; 



    END;

GO
