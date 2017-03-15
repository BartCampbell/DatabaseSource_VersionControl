SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the CodedSource staging data into StagingHash with the hashdiff key
-- Usage		EXECUTE adv.sp_LoadCodedSourceHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadCodedSourceHash]
    @CCI INT ,
    @Date DATETIME
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CodedSource_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CodedSource,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.sortOrder,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblCodedSource' ,
                        @Date
                FROM    adv.tblCodedSourceStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CodedSource_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CodedSource,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.sortOrder,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblCodedSource'
                WHERE   b.HashDiff IS NULL;


    END;
GO
