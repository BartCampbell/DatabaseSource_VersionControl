SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Data Vault DocumentType Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Document_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
		

	--**S_DocumentTypeDetail LOAD
INSERT INTO [dbo].[S_DocumentTypeDetail]
           ([S_DocumentTypeDetail_RK]
           ,[LoadDate]
           ,[H_DocumentType_RK]
           ,[DocumentType]
           ,[LastUpdated]
           ,[HashDiff]
           ,[RecordSource]
)

           SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CDI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[DocumentType],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated],
                                                              '')))))), 2)) ,
                LoadDate ,
                DocumentTypeHashKey ,
                [DocumentType] ,
				[LastUpdated],
               UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[DocumentType],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated],
                                                              '')))))), 2)),
                RecordSource
        FROM    CHSStaging.adv.tblDocumentTypeStage rw WITH ( NOLOCK )
        WHERE     UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[DocumentType],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated],
                                                              '')))))), 2)) NOT IN (
                SELECT  HashDiff
                FROM    S_DocumentTypeDetail
                WHERE   H_DocumentType_RK = rw.DocumentTypeHashKey
                        AND RecordEndDate IS NULL )
                AND rw.CCI = @CCI
        GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CDI,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(rw.[DocumentType],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated],
                                                              '')))))), 2)) ,
                LoadDate ,
                DocumentTypeHashKey ,
                [DocumentType] ,
				[LastUpdated],
               UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                  UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[DocumentType],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[LastUpdated],
                                                              '')))))), 2)),
                RecordSource;

	--RECORD END DATE CLEANUP
UPDATE  dbo.S_DocumentTypeDetail
SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                          FROM      dbo.S_DocumentTypeDetail z
                          WHERE     z.H_DocumentType_RK = a.H_DocumentType_RK
                                    AND z.LoadDate > a.LoadDate
                        )
FROM    dbo.S_DocumentTypeDetail a
WHERE   RecordEndDate IS NULL; 

    
    END;
    
	
GO
