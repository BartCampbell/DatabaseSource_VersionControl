SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 05/05/2017
-- Description:	Gets MAO004 details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetMAO004]
	-- Add the parameters for the stored procedure here
    
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

   
   WITH wt AS (        SELECT  c.Member_ID ,
                a.[Beneficiary HICN] ,
                a.EncounterICN
        FROM    S_MAO004Details a
                INNER JOIN S_MemberHICN b ON a.[Beneficiary HICN] = b.HICNumber
                                             AND b.RecordEndDate IS NULL
                INNER JOIN S_MemberDetail c ON c.H_Member_RK = b.H_Member_RK
                                               AND c.RecordEndDate IS NULL
        WHERE   a.RecordEndDate IS NULL),
		wex AS (
        SELECT  [Beneficiary HICN] ,
                EncounterICN
        
        FROM    wt
        GROUP BY [Beneficiary HICN] ,
                EncounterICN
        HAVING  COUNT(DISTINCT Member_ID) > 1),
		wme AS ( SELECT DISTINCT
                a.[ReportID] ,
                a.[MedicareAdvantageContractID] ,
                a.[Beneficiary HICN] ,
                c.Member_BK AS CentauriMemberID,
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
                a.[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses]
        FROM    S_MAO004Details a
                INNER JOIN S_MemberHICN b ON a.[Beneficiary HICN] = b.HICNumber
                                             AND b.RecordEndDate IS NULL
                INNER JOIN dbo.H_Member c ON c.H_Member_RK = b.H_Member_RK
				LEFT OUTER JOIN wex d ON a.[Beneficiary HICN] = d.[Beneficiary HICN]
        WHERE   d.[Beneficiary HICN] IS NULL
                AND a.RecordEndDate IS NULL AND a.LoadDate > @LoadDate),
		wmf AS (   SELECT DISTINCT
                        a.[ReportID] ,
                        a.[MedicareAdvantageContractID] ,
                        a.[Beneficiary HICN] ,
						NULL AS CentauriMemberID, 
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
                        a.[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses]
                FROM    S_MAO004Details a
                        LEFT OUTER JOIN wme d ON a.[Beneficiary HICN] = d.[Beneficiary HICN]
                WHERE   d.[Beneficiary HICN] IS NULL
                        AND a.RecordEndDate IS NULL  AND a.LoadDate > @LoadDate)


        SELECT  *
        FROM    WME 
		UNION 
	 SELECT * FROM WMF; 




    END;



	
GO
