SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadProviderOfficeHash @CCI INT
-- =============================================
CREATE PROCEDURE [adv].[spLoadProviderOfficeWCHash]
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ZipCode_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactPerson,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.EMR_Type,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.EMR_Type_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.GroupName,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LocationID,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderOfficeBucket_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Pool_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedUser_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblProviderOffice' ,
                        @Date
                FROM    adv.tblProviderOfficeWCStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ZipCode_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactPerson,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.EMR_Type,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.EMR_Type_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.GroupName,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LocationID,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderOfficeBucket_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Pool_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedUser_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblProviderOffice'
                WHERE   b.HashDiff IS NULL;





    END;
GO
