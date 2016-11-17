SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblProviderOfficeStatusHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadProviderOfficeStatusHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadProviderOfficeStatusHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	
        INSERT  INTO adv.tblProviderOfficeStatusHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Project_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.OfficeIssueStatus,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblProviderOfficeStatusStage a
                        LEFT OUTER JOIN adv.tblProviderOfficeStatusHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Project_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.OfficeIssueStatus,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;

    END;
GO
