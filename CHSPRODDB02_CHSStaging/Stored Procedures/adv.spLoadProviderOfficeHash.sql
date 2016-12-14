SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblProviderOfficeHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadProviderOfficeHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadProviderOfficeHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	
        INSERT  INTO adv.tblProviderOfficeHash
                ( HashDiff
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
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblProviderOfficeStage a
                        LEFT OUTER JOIN adv.tblProviderOfficeHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
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
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;





    END;
GO
