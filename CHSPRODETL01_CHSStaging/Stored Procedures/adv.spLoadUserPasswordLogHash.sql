SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblUserPasswordLogHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadUserPasswordLogHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadUserPasswordLogHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	
        INSERT  INTO adv.tblUserPasswordLogHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Password,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtPassword,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblUserPasswordLogStage a
                        LEFT OUTER JOIN adv.tblUserPasswordLogHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Password,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtPassword,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;







    END;
GO
