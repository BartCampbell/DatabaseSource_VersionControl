SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the DocumentType staging data to StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadDocumentTypeHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadDocumentTypeHash]
    @CCI INT ,
    @DATE DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        
        INSERT  INTO adv.StagingHash
                ( HashDiff ,
                  ClientID ,
                  TableName ,
                  CreateDate
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.DocumentType_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DocumentType,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblDocumentType' ,
                        @DATE
                FROM    adv.tblDocumentTypeStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.DocumentType_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DocumentType,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblDocumentType'
                WHERE   b.HashDiff IS NULL;


    END;
GO
