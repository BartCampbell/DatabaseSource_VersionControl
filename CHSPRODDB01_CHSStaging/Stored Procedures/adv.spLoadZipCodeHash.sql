SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadZipCodeHash  @CCI Int
-- =============================================
CREATE PROCEDURE [adv].[spLoadZipCodeHash]
    @CCI INT ,
    @Date DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
     	DECLARE @recordsource VARCHAR(20)
	SET @recordsource =(SELECT TOP 1 RecordSource FROM adv.AdvanceVariables WHERE  AVKey =(SELECT TOP 1 VariableLoadKey FROM adv.AdvanceVariableLoad))
      
        INSERT  INTO adv.StagingHash
                ( HashDiff ,
                  ClientID ,
                  TableName ,
                  CreateDate,
				  RecordSource
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ZipCode_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ZipCode,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.City,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.State,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.County,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Latitude,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Longitude,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblZipCode' ,
                        @Date,
						@recordsource
                FROM    adv.tblZipCodeStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ZipCode_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ZipCode,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.City,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.State,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.County,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Latitude,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Longitude,
                                                              '')))))), 2)) = b.HashDiff
															  AND b.ClientID = @CCI
															  AND b.TableName = 'tblZipCode'
															  AND b.RecordSource = @recordsource
                WHERE   b.HashDiff IS NULL;

    END;
GO
