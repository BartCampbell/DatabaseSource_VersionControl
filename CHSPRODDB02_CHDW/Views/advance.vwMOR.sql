SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/*
    Author: Travis Parker
    Date:	  05/15/2016
    Name:	  advance.vwMOR
    Desc:	  view of MOR data for Advance ETL
*/

CREATE VIEW [advance].[vwMOR]
AS
     SELECT
          c.CentauriClientID,
          m.CentauriMemberID,
          mo.contractnumber,
          mo.MORVersion,
          mo.agegroup,
          mo.MedicaidDisabled,
          mo.MedicaidAged,
          mo.OriginallyDisabled,
          mo.PaymentYearandMonth,
          mo.ESRD,
          mo.CANCER_IMMUNE,
          mo.CHF_COPD,
          mo.CHF_RENAL,
          mo.COPD_CARD_RESP_FAIL,
          mo.DIABETES_CHF,
          mo.SEPSIS_CARD_RESP_FAIL,
          mo.MEDICAID,
          mo.DISABLED_PRESSURE_ULCER,
          mo.ART_OPENINGS_PRESSURE_ULCER,
          mo.ASP_SPEC_BACT_PNEUM_PRES_ULC,
          mo.COPD_ASP_SPEC_BACT_PNEUM,
          mo.SCHIZOPHRENIA_CHF,
          mo.SCHIZOPHRENIA_COPD,
          mo.SCHIZOPHRENIA_SEIZURES,
          mo.SEPSIS_ARTIF_OPENINGS,
          mo.SEPSIS_ASP_SPEC_BACT_PNEUM,
          mo.SEPSIS_PRESSURE_ULCER,
          mo.INT1,
          mo.INT2,
          mo.INT3,
          mo.INT4,
          mo.INT5,
          mo.INT6,
          mo.HCC
     FROM fact.MOR AS mo
          INNER JOIN dim.Client AS c ON mo.ClientID = c.ClientID
          INNER JOIN dim.Member AS m ON mo.MemberID = m.MemberID;


GO
