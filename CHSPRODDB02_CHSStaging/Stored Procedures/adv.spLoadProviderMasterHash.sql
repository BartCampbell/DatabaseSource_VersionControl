SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/14/2016
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadProviderMasterHash @CCI INT
-- =============================================
CREATE PROCEDURE [adv].[spLoadProviderMasterHash]
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Provider_ID,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Lastname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Firstname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.TIN,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PIN,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblProviderMaster' ,
                        @Date
                FROM    adv.tblProviderMasterStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Provider_ID,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Lastname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Firstname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NPI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.TIN,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PIN,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblProviderMaster'
                WHERE   b.HashDiff IS NULL;





    END;
GO
