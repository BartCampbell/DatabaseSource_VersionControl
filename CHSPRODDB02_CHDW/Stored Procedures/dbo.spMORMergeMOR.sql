SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	07/28/2016
-- Description:	merges the stage to dim for MemberHICN
-- Usage:			
--		  EXECUTE dbo.spMORMergeMOR
-- =============================================
CREATE PROC [dbo].[spMORMergeMOR]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.MOR AS t
        USING
            ( SELECT  DISTINCT  s.recordsource ,
                        s.LoadDate ,
                        s.contractnumber ,
                        CONVERT(VARCHAR(8),s.RunDate,112) AS RunDate,
                        s.recordtypecode AS MORVersion ,
                        s.PaymentYearandMonth ,
                        s.AgeGroup ,
                        s.MedicaidDisabled ,
                        s.MedicaidAged ,
                        s.OriginallyDisabled ,
                        s.ESRD ,
                        s.CANCER_IMMUNE ,
                        s.CHF_COPD ,
                        s.CHF_RENAL ,
                        s.COPD_CARD_RESP_FAIL ,
                        s.DIABETES_CHF ,
                        s.SEPSIS_CARD_RESP_FAIL ,
                        s.MEDICAID ,
                        s.DISABLED_PRESSURE_ULCER ,
                        s.ART_OPENINGS_PRESSURE_ULCER ,
                        s.ASP_SPEC_BACT_PNEUM_PRES_ULC ,
                        s.COPD_ASP_SPEC_BACT_PNEUM ,
                        s.SCHIZOPHRENIA_CHF ,
                        s.SCHIZOPHRENIA_COPD ,
                        s.SCHIZOPHRENIA_SEIZURES ,
                        s.SEPSIS_ARTIF_OPENINGS ,
                        s.SEPSIS_ASP_SPEC_BACT_PNEUM ,
                        s.SEPSIS_PRESSURE_ULCER ,
                        s.INT1 ,
                        s.INT2 ,
                        s.INT3 ,
                        s.INT4 ,
                        s.INT5 ,
                        s.INT6 ,
                        s.HCC ,
                        c.ClientID ,
                        m.MemberID
              FROM      stage.MOR s
                        INNER JOIN dim.Client c ON s.ClientID = c.CentauriClientID
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
            ) AS s
        ON t.ClientID = s.ClientID
            AND t.MemberID = s.MemberID
            AND t.contractnumber = s.contractnumber
            AND t.MORVersion = s.MORVersion
            AND t.PaymentYearandMonth = s.PaymentYearandMonth
            AND t.RunDate = s.RunDate
		  AND t.HCC = s.HCC
        WHEN MATCHED AND ( ISNULL(t.agegroup, '') <> ISNULL(s.AgeGroup, '')
                           OR ISNULL(t.MedicaidDisabled, '') <> ISNULL(s.MedicaidDisabled, '')
                           OR ISNULL(t.MedicaidAged, '') <> ISNULL(s.MedicaidAged, '')
                           OR ISNULL(t.OriginallyDisabled, '') <> ISNULL(s.OriginallyDisabled, '')
                           OR ISNULL(t.ESRD, '') <> ISNULL(s.ESRD, '')
                           OR ISNULL(t.CANCER_IMMUNE, '') <> ISNULL(s.CANCER_IMMUNE, '')
                           OR ISNULL(t.CHF_COPD, '') <> ISNULL(s.CHF_COPD, '')
                           OR ISNULL(t.CHF_RENAL, '') <> ISNULL(s.CHF_RENAL, '')
                           OR ISNULL(t.COPD_CARD_RESP_FAIL, '') <> ISNULL(s.COPD_CARD_RESP_FAIL, '')
                           OR ISNULL(t.DIABETES_CHF, '') <> ISNULL(s.DIABETES_CHF, '')
                           OR ISNULL(t.SEPSIS_CARD_RESP_FAIL, '') <> ISNULL(s.SEPSIS_CARD_RESP_FAIL, '')
                           OR ISNULL(t.MEDICAID, '') <> ISNULL(s.MEDICAID, '')
                           OR ISNULL(t.DISABLED_PRESSURE_ULCER, '') <> ISNULL(s.DISABLED_PRESSURE_ULCER, '')
                           OR ISNULL(t.ART_OPENINGS_PRESSURE_ULCER, '') <> ISNULL(s.ART_OPENINGS_PRESSURE_ULCER, '')
                           OR ISNULL(t.ASP_SPEC_BACT_PNEUM_PRES_ULC, '') <> ISNULL(s.ASP_SPEC_BACT_PNEUM_PRES_ULC, '')
                           OR ISNULL(t.COPD_ASP_SPEC_BACT_PNEUM, '') <> ISNULL(s.COPD_ASP_SPEC_BACT_PNEUM, '')
                           OR ISNULL(t.SCHIZOPHRENIA_CHF, '') <> ISNULL(s.SCHIZOPHRENIA_CHF, '')
                           OR ISNULL(t.SCHIZOPHRENIA_COPD, '') <> ISNULL(s.SCHIZOPHRENIA_COPD, '')
                           OR ISNULL(t.SCHIZOPHRENIA_SEIZURES, '') <> ISNULL(s.SCHIZOPHRENIA_SEIZURES, '')
                           OR ISNULL(t.SEPSIS_ARTIF_OPENINGS, '') <> ISNULL(s.SEPSIS_ARTIF_OPENINGS, '')
                           OR ISNULL(t.SEPSIS_ASP_SPEC_BACT_PNEUM, '') <> ISNULL(s.SEPSIS_ASP_SPEC_BACT_PNEUM, '')
                           OR ISNULL(t.SEPSIS_PRESSURE_ULCER, '') <> ISNULL(s.SEPSIS_PRESSURE_ULCER, '')
                           OR ISNULL(t.INT1, '') <> ISNULL(s.INT1, '')
                           OR ISNULL(t.INT2, '') <> ISNULL(s.INT2, '')
                           OR ISNULL(t.INT3, '') <> ISNULL(s.INT3, '')
                           OR ISNULL(t.INT4, '') <> ISNULL(s.INT4, '')
                           OR ISNULL(t.INT5, '') <> ISNULL(s.INT5, '')
                           OR ISNULL(t.INT6, '') <> ISNULL(s.INT6, '')
                         ) THEN
            UPDATE SET
                    t.agegroup = s.AgeGroup ,
                    t.MedicaidDisabled = s.MedicaidDisabled ,
                    t.MedicaidAged = s.MedicaidAged ,
                    t.OriginallyDisabled = s.OriginallyDisabled ,
                    t.ESRD = s.ESRD ,
                    t.CANCER_IMMUNE = s.CANCER_IMMUNE ,
                    t.CHF_COPD = s.CHF_COPD ,
                    t.CHF_RENAL = s.CHF_RENAL ,
                    t.COPD_CARD_RESP_FAIL = s.COPD_CARD_RESP_FAIL ,
                    t.DIABETES_CHF = s.DIABETES_CHF ,
                    t.SEPSIS_CARD_RESP_FAIL = s.SEPSIS_CARD_RESP_FAIL ,
                    t.MEDICAID = s.MEDICAID ,
                    t.DISABLED_PRESSURE_ULCER = s.DISABLED_PRESSURE_ULCER ,
                    t.ART_OPENINGS_PRESSURE_ULCER = s.ART_OPENINGS_PRESSURE_ULCER ,
                    t.ASP_SPEC_BACT_PNEUM_PRES_ULC = s.ASP_SPEC_BACT_PNEUM_PRES_ULC ,
                    t.COPD_ASP_SPEC_BACT_PNEUM = s.COPD_ASP_SPEC_BACT_PNEUM ,
                    t.SCHIZOPHRENIA_CHF = s.SCHIZOPHRENIA_CHF ,
                    t.SCHIZOPHRENIA_COPD = s.SCHIZOPHRENIA_COPD ,
                    t.SCHIZOPHRENIA_SEIZURES = s.SCHIZOPHRENIA_SEIZURES ,
                    t.SEPSIS_ARTIF_OPENINGS = s.SEPSIS_ARTIF_OPENINGS ,
                    t.SEPSIS_ASP_SPEC_BACT_PNEUM = s.SEPSIS_ASP_SPEC_BACT_PNEUM ,
                    t.SEPSIS_PRESSURE_ULCER = s.SEPSIS_PRESSURE_ULCER ,
                    t.INT1 = s.INT1 ,
                    t.INT2 = s.INT2 ,
                    t.INT3 = s.INT3 ,
                    t.INT4 = s.INT4 ,
                    t.INT5 = s.INT5 ,
                    t.INT6 = s.INT6 ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ClientID ,
                     MemberID ,
                     contractnumber ,
                     RunDate ,
                     MORVersion ,
                     agegroup ,
                     MedicaidDisabled ,
                     MedicaidAged ,
                     OriginallyDisabled ,
                     PaymentYearandMonth ,
                     ESRD ,
                     CANCER_IMMUNE ,
                     CHF_COPD ,
                     CHF_RENAL ,
                     COPD_CARD_RESP_FAIL ,
                     DIABETES_CHF ,
                     SEPSIS_CARD_RESP_FAIL ,
                     MEDICAID ,
                     DISABLED_PRESSURE_ULCER ,
                     ART_OPENINGS_PRESSURE_ULCER ,
                     ASP_SPEC_BACT_PNEUM_PRES_ULC ,
                     COPD_ASP_SPEC_BACT_PNEUM ,
                     SCHIZOPHRENIA_CHF ,
                     SCHIZOPHRENIA_COPD ,
                     SCHIZOPHRENIA_SEIZURES ,
                     SEPSIS_ARTIF_OPENINGS ,
                     SEPSIS_ASP_SPEC_BACT_PNEUM ,
                     SEPSIS_PRESSURE_ULCER ,
                     INT1 ,
                     INT2 ,
                     INT3 ,
                     INT4 ,
                     INT5 ,
                     INT6 ,
                     HCC ,
                     FileName ,
                     CreateDate ,
                     LastUpdate
                   )
            VALUES ( s.ClientID ,
                     s.MemberID ,
                     s.contractnumber ,
                     s.RunDate ,
                     s.MORVersion ,
                     s.AgeGroup ,
                     s.MedicaidDisabled ,
                     s.MedicaidAged ,
                     s.OriginallyDisabled ,
                     s.PaymentYearandMonth ,
                     s.ESRD ,
                     s.CANCER_IMMUNE ,
                     s.CHF_COPD ,
                     s.CHF_RENAL ,
                     s.COPD_CARD_RESP_FAIL ,
                     s.DIABETES_CHF ,
                     s.SEPSIS_CARD_RESP_FAIL ,
                     s.MEDICAID ,
                     s.DISABLED_PRESSURE_ULCER ,
                     s.ART_OPENINGS_PRESSURE_ULCER ,
                     s.ASP_SPEC_BACT_PNEUM_PRES_ULC ,
                     s.COPD_ASP_SPEC_BACT_PNEUM ,
                     s.SCHIZOPHRENIA_CHF ,
                     s.SCHIZOPHRENIA_COPD ,
                     s.SCHIZOPHRENIA_SEIZURES ,
                     s.SEPSIS_ARTIF_OPENINGS ,
                     s.SEPSIS_ASP_SPEC_BACT_PNEUM ,
                     s.SEPSIS_PRESSURE_ULCER ,
                     s.INT1 ,
                     s.INT2 ,
                     s.INT3 ,
                     s.INT4 ,
                     s.INT5 ,
                     s.INT6 ,
                     s.HCC ,
                     s.recordsource ,
                     @CurrentDate ,
                     @CurrentDate
                   );
    END;     



GO
