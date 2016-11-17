SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Data Vault CodedData Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_CodedData_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
		

	--**S_CodedDataDetail LOAD

        INSERT  INTO [dbo].[S_CodedDataDetail]
                ( [S_CodedDataDetail_RK] ,
                  [LoadDate] ,
                  [H_CodedData_RK] ,
                  [DiagnosisCode] ,
                  [DOS_From] ,
                  [DOS_Thru] ,
                  [CPT] ,
                  [IsICD10] ,
                  [Coded_Date] ,
                  [Updated_Date] ,
                  [OpenedPage] ,
                  [Is_Deleted] ,
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
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Updated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[OpenedPage],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Is_Deleted],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        CodedDataHashKey ,
                        [DiagnosisCode] ,
                        [DOS_From] ,
                        [DOS_Thru] ,
                        [CPT] ,
                        [IsICD10] ,
                        [Coded_Date] ,
                        [Updated_Date] ,
                        [OpenedPage] ,
                        [Is_Deleted] ,
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
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Updated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[OpenedPage],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Is_Deleted],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblCodedDataStage rw WITH ( NOLOCK )
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
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Updated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[OpenedPage],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Is_Deleted],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_CodedDataDetail
                        WHERE   H_CodedData_RK = rw.CodedDataHashKey
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
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Updated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[OpenedPage],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Is_Deleted],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        CodedDataHashKey ,
                        [DiagnosisCode] ,
                        [DOS_From] ,
                        [DOS_Thru] ,
                        [CPT] ,
                        [IsICD10] ,
                        [Coded_Date] ,
                        [Updated_Date] ,
                        [OpenedPage] ,
                        [Is_Deleted] ,
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
                                                              RTRIM(LTRIM(COALESCE(rw.[Coded_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Updated_Date],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[OpenedPage],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Is_Deleted],
                                                              '')))))), 2)) ,
                        RecordSource;

							--RECORD END DATE CLEANUP
        UPDATE  dbo.S_CodedDataDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_CodedDataDetail z
                                  WHERE     z.H_CodedData_RK = a.H_CodedData_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_CodedDataDetail a
        WHERE   RecordEndDate IS NULL; 


--**S_CodedDataQADetail LOAD
        INSERT  INTO [dbo].[S_CodedDataQADetail]
                ( [S_CodedDataQADetail_RK] ,
                  [LoadDate] ,
                  [H_CodedData_RK] ,
                  [IsConfirmed] ,
                  [IsRemoved] ,
                  [Old_ICD9] ,
                  [Old_CPT] ,
                  [dtInsert] ,
                  [QA_User_PK] ,
                  [IsAdded] ,
                  [IsChanged] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CDI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsConfirmed],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRemoved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_ICD9],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[QA_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsAdded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChanged],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        CodedDataHashKey ,
                        [IsConfirmed] ,
                        [IsRemoved] ,
                        RTRIM(LTRIM([Old_ICD9])) ,
                        RTRIM(LTRIM([Old_CPT])) ,
                        [dtInsert] ,
                        [QA_User_PK] ,
                        [IsAdded] ,
                        [IsChanged] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[IsConfirmed],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRemoved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_ICD9],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[QA_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsAdded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChanged],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblCodedDataQAStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[IsConfirmed],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRemoved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_ICD9],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[QA_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsAdded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChanged],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_CodedDataDetail
                        WHERE   H_CodedData_RK = rw.CodedDataHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CDI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsConfirmed],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRemoved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_ICD9],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[QA_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsAdded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChanged],
                                                              '')))))), 2)) ,
                        LoadDate ,
                        CodedDataHashKey ,
                        [IsConfirmed] ,
                        [IsRemoved] ,
                        RTRIM(LTRIM([Old_ICD9])) ,
                        RTRIM(LTRIM([Old_CPT])) ,
                        [dtInsert] ,
                        [QA_User_PK] ,
                        [IsAdded] ,
                        [IsChanged] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.[IsConfirmed],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsRemoved],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_ICD9],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Old_CPT],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[dtInsert],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[QA_User_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsAdded],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[IsChanged],
                                                              '')))))), 2)) ,
                        RecordSource;








	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_CodedDataQADetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_CodedDataQADetail z
                                  WHERE     z.H_CodedData_RK = a.H_CodedData_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_CodedDataQADetail a
        WHERE   RecordEndDate IS NULL; 

    
    END;
    
	
GO
