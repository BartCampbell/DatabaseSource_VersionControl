SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Data Vault ClaimData Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ClaimData_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
		

	--**S_ClaimDataDetail LOAD

        INSERT  INTO [dbo].[S_ClaimDataDetail]
                ( [S_ClaimDataDetail_RK] ,
                  [LoadDate] ,
                  [H_ClaimData_RK] ,
                  [DiagnosisCode] ,
                  [DOS_From] ,
                  [DOS_Thru] ,
                  [CPT] ,
                  [IsICD10] ,
                  [Claim_ID] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CDI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DiagnosisCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_From],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_Thru],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsICD10],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Claim_ID],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ClaimDataHashKey ,
                        [DiagnosisCode] ,
                        [DOS_From] ,
                        [DOS_Thru] ,
                        [CPT] ,
                        [IsICD10] ,
                        [Claim_ID] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[DiagnosisCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_From],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_Thru],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsICD10],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Claim_ID],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblClaimDataStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[DiagnosisCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_From],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_Thru],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsICD10],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Claim_ID],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ClaimDataDetail
                        WHERE   H_ClaimData_RK = rw.ClaimDataHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CDI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DiagnosisCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_From],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_Thru],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsICD10],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Claim_ID],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        ClaimDataHashKey ,
                        [DiagnosisCode] ,
                        [DOS_From] ,
                        [DOS_Thru] ,
                        [CPT] ,
                        [IsICD10] ,
                        [Claim_ID] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[DiagnosisCode],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_From],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[DOS_Thru],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsICD10],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Claim_ID],
                                                              '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ClaimDataDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ClaimDataDetail z
                                  WHERE     z.H_ClaimData_RK = a.H_ClaimData_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ClaimDataDetail a
        WHERE   RecordEndDate IS NULL; 

    
    END;
    
	
GO
