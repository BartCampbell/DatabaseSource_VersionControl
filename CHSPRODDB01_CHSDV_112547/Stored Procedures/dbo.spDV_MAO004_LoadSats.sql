SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 05/02/2017
 -- Description:	Data Vault MAO004 Load Satelites
-- =============================================
CREATE PROCEDURE [dbo].[spDV_MAO004_LoadSats]
    @filelog VARCHAR(100) ,
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

        INSERT  INTO dbo.S_MAO004Details
                ( S_MAO004Details_RK ,
                  LoadDate ,
                  H_MAO004Record_RK ,
                  ReportID ,
                  MedicareAdvantageContractID ,
                  [Beneficiary HICN] ,
                  EncounterICN ,
                  EncounterTypeSwitch ,
                  ICNOfEncounterLinkedTo ,
                  AllowedDisallowedStatusOfEncounterLinkedTo ,
                  EncounterSubmissionDate ,
                  FromDateofService ,
                  ThroughDateOfService ,
                  ClaimType ,
                  AllowedDisallowedflag ,
                  AllowedDisallowedReasonCode ,
                  DiagnosesICD ,
                  DiagnosisCode ,
                  AddOrDeleteFlag ,
                  [DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses] ,
                  HashDiff ,
                  RecordSource 
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[LoadDate], ''))), ':', RTRIM(LTRIM(COALESCE(a.[ReportID], ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.[MedicareAdvantageContractID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Beneficiary HICN], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterICN], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterTypeSwitch], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ICNOfEncounterLinkedTo], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedStatusOfEncounterLinkedTo], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterSubmissionDate], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[FromDateofService], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ThroughDateOfService], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ClaimType], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedflag], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedReasonCode], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosesICD], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosisCode], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AddOrDeleteFlag], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses], '')))))), 2)) ,
                        a.[LoadDate] ,
                        b.H_MAO004Record_RK ,
                        a.[ReportID] ,
                        a.[MedicareAdvantageContractID] ,
                        a.[Beneficiary HICN] ,
                        a.[EncounterICN] ,
                        a.[EncounterTypeSwitch] ,
                        a.[ICNOfEncounterLinkedTo] ,
                        a.[AllowedDisallowedStatusOfEncounterLinkedTo] ,
                        a.[EncounterSubmissionDate] ,
                        a.[FromDateofService] ,
                        a.[ThroughDateOfService] ,
                        a.[ClaimType] ,
                        a.[AllowedDisallowedflag] ,
                        a.[AllowedDisallowedReasonCode] ,
                        a.[DiagnosesICD] ,
                        a.[DiagnosisCode] ,
                        a.[AddOrDeleteFlag] ,
                        a.[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[ReportID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[MedicareAdvantageContractID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Beneficiary HICN], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterICN], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterTypeSwitch], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ICNOfEncounterLinkedTo], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedStatusOfEncounterLinkedTo], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterSubmissionDate], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[FromDateofService], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ThroughDateOfService], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ClaimType], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedflag], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedReasonCode], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosesICD], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosisCode], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AddOrDeleteFlag], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses], '')))))), 2)) ,
                        @filelog
                FROM    CHSStaging.dbo.MAO004Detail a WITH ( NOLOCK )
                        INNER JOIN dbo.H_MAO004Record b ON a.EncounterICN = b.ClientMAO004RecordID
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[ReportID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[MedicareAdvantageContractID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Beneficiary HICN], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterICN], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterTypeSwitch], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ICNOfEncounterLinkedTo], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedStatusOfEncounterLinkedTo], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterSubmissionDate], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[FromDateofService], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ThroughDateOfService], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ClaimType], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedflag], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedReasonCode], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosesICD], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosisCode], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AddOrDeleteFlag], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses], '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    dbo.S_MAO004Details
                        WHERE   RecordEndDate IS NULL )
                        AND a.[FileName] = @filelog
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[LoadDate], ''))), ':', RTRIM(LTRIM(COALESCE(a.[ReportID], ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(a.[MedicareAdvantageContractID], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[Beneficiary HICN], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[EncounterICN], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[EncounterTypeSwitch], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[ICNOfEncounterLinkedTo], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedStatusOfEncounterLinkedTo], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[EncounterSubmissionDate], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[FromDateofService], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[ThroughDateOfService], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[ClaimType], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedflag], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedReasonCode], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[DiagnosesICD], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[DiagnosisCode], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[AddOrDeleteFlag], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses], '')))))), 2)) ,
                        a.[LoadDate] ,
                        b.H_MAO004Record_RK ,
                        a.[ReportID] ,
                        a.[MedicareAdvantageContractID] ,
                        a.[Beneficiary HICN] ,
                        a.[EncounterICN] ,
                        a.[EncounterTypeSwitch] ,
                        a.[ICNOfEncounterLinkedTo] ,
                        a.[AllowedDisallowedStatusOfEncounterLinkedTo] ,
                        a.[EncounterSubmissionDate] ,
                        a.[FromDateofService] ,
                        a.[ThroughDateOfService] ,
                        a.[ClaimType] ,
                        a.[AllowedDisallowedflag] ,
                        a.[AllowedDisallowedReasonCode] ,
                        a.[DiagnosesICD] ,
                        a.[DiagnosisCode] ,
                        a.[AddOrDeleteFlag] ,
                        a.[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[ReportID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[MedicareAdvantageContractID], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Beneficiary HICN], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterICN], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterTypeSwitch], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ICNOfEncounterLinkedTo], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedStatusOfEncounterLinkedTo], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[EncounterSubmissionDate], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[FromDateofService], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ThroughDateOfService], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[ClaimType], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedflag], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AllowedDisallowedReasonCode], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosesICD], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosisCode], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[AddOrDeleteFlag], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses], '')))))), 2));

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_MAO004Details
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_MAO004Details z
                                  WHERE     z.H_MAO004Record_RK = a.H_MAO004Record_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MAO004Details a
        WHERE   a.RecordEndDate IS NULL; 



    END;




GO
