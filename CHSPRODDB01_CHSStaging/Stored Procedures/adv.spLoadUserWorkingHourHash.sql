SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblUserWorkingHourHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadUserWorkingHourHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadUserWorkingHourHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
       
        INSERT  INTO adv.tblUserWorkingHourHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Day_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FromHour,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FromMin,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ToHour,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ToMin,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblUserWorkingHourStage a
                        LEFT OUTER JOIN adv.tblUserWorkingHourHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Day_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FromHour,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FromMin,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ToHour,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ToMin,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;

    END;
GO
