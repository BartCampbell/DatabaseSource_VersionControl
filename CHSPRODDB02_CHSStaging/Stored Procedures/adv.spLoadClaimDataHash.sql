SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblClaimDataHash with the hashdiff key
-- Usage		EXECUTE adv.sp_LoadClaimDatahash
-- =============================================
CREATE PROCEDURE [adv].[spLoadClaimDataHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        
        INSERT  INTO adv.tblClaimDataHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ClaimData_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Member_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DiagnosisCode,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DOS_From,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DOS_Thru,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CPT,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsICD10,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Claim_ID,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblClaimDataStage a
                        LEFT OUTER JOIN adv.tblClaimDataHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ClaimData_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Member_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DiagnosisCode,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DOS_From,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DOS_Thru,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.CPT,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderMaster_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsICD10,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Claim_ID,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;
    END;
GO
