SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/14/2016
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadProviderHash @CCI INT
-- =============================================
CREATE PROCEDURE [adv].[spLoadProviderHash] @CCI INT, @Date DATETIME
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Provider_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblProvider' ,
                        @Date,
						@recordsource

                FROM    adv.tblProviderStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Provider_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblProvider'
															 AND b.RecordSource = @recordsource
                WHERE   b.HashDiff IS NULL;

    END;
GO
