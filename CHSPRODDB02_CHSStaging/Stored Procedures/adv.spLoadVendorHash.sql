SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblVendorHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadVendorHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadVendorHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
       
        INSERT  INTO adv.tblVendorHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Client_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Vendor_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Vendor_ID,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Lastname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Firstname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.City,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.State,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Zip,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactPerson,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblVendorStage a
                        LEFT OUTER JOIN adv.tblVendorHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Client_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Vendor_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Vendor_ID,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Lastname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Firstname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.City,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.State,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Zip,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactPerson,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FaxNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;

    END;
GO
