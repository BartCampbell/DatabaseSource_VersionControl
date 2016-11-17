SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


---- =============================================
---- Author:		Travis Parker
---- Create date:	07/27/2016
---- Description:	Gets the latest MOR data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetMOR '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetMOR]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  recordsource ,
            LoadDate ,
            contractnumber ,
		  RunDate ,
            recordtypecode ,
            HICN ,
            lastname ,
            firstname ,
            mi ,
            dob ,
            gender ,
            ssn ,
            AgeGroup ,
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
            CentauriClientID ,
            CentauriMemberID,
		  UPPER(CONCAT(LTRIM(RTRIM(recordsource)),':',LTRIM(RTRIM(RunDate)),':',LTRIM(RTRIM(recordtypecode)),':',LTRIM(RTRIM(HICN)),':',LTRIM(RTRIM(HCC)))) AS MOR_BK
    FROM    dbo.vwMOR_V12
    WHERE   LoadDate > @LastLoadTime
    UNION
    SELECT  recordsource ,
            LoadDate ,
            contractnumber ,
		  RunDate ,
            recordtypecode ,
            HICN ,
            lastname ,
            firstname ,
            mi ,
            dob ,
            gender ,
            ssn ,
            AgeGroup ,
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
            CentauriClientID ,
            CentauriMemberID,
		  UPPER(CONCAT(LTRIM(RTRIM(recordsource)),':',LTRIM(RTRIM(RunDate)),':',LTRIM(RTRIM(recordtypecode)),':',LTRIM(RTRIM(HICN)),':',LTRIM(RTRIM(HCC)))) AS MOR_BK
    FROM    dbo.vwMOR_V21
    WHERE   LoadDate > @LastLoadTime
    UNION
    SELECT  recordsource ,
            LoadDate ,
            contractnumber ,
		  RunDate ,
            recordtypecode ,
            HICN ,
            lastname ,
            firstname ,
            mi ,
            dob ,
            gender ,
            ssn ,
            AgeGroup ,
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
            CentauriClientID ,
            CentauriMemberID,
		  UPPER(CONCAT(LTRIM(RTRIM(recordsource)),':',LTRIM(RTRIM(RunDate)),':',LTRIM(RTRIM(recordtypecode)),':',LTRIM(RTRIM(HICN)),':',LTRIM(RTRIM(HCC)))) AS MOR_BK
    FROM    dbo.vwMOR_V22
    WHERE   LoadDate > @LastLoadTime;


GO
