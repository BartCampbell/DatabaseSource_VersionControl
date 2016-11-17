SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[vwMOR_V21]
AS
SELECT recordsource, LoadDate, contractnumber, RunDate, recordtypecode, HICN, lastname, firstname, mi, dob, gender, ssn, AgeGroup, MedicaidDisabled, MedicaidAged,
       OriginallyDisabled, PaymentYearandMonth
	, ESRD
	, [CANCER_IMMUNE]
	, [CHF_COPD]
	, [CHF_RENAL]
	, [COPD_CARD_RESP_FAIL]
	, [DIABETES_CHF]
	, [SEPSIS_CARD_RESP_FAIL]
	, [MEDICAID]
	, [DISABLED_PRESSURE_ULCER]
	, [ART_OPENINGS_PRESSURE_ULCER]
	, [ASP_SPEC_BACT_PNEUM_PRES_ULC]
	, [COPD_ASP_SPEC_BACT_PNEUM]
	, [SCHIZOPHRENIA_CHF]
	, [SCHIZOPHRENIA_COPD]
	, [SCHIZOPHRENIA_SEIZURES]
	, [SEPSIS_ARTIF_OPENINGS]
	, [SEPSIS_ASP_SPEC_BACT_PNEUM]
	, [SEPSIS_PRESSURE_ULCER]
	, INT1
     , INT2
     , INT3
     , INT4
     , INT5
     , INT6
	, CONVERT(VARCHAR(20),HCC) AS HCC
	, CentauriClientID
	, CentauriMemberID
FROM 
   (SELECT h.recordsource, b.LoadDate, h.ContractNumber, h.RunDate, h.PaymentYearandMonth, 'V21' AS RecordTypeCode, b.HICN, b.LastName, b.FirstName
	, b.MI, b.DOB, CASE WHEN b.Gender = 2 THEN 'Female' WHEN b.Gender = 1 THEN 'Male' ELSE 'Unknown' END AS Gender, b.SSN
	, CASE WHEN b.F034 = 1 THEN '0_34' 
		  WHEN b.F3544 = 1 THEN '35_44' 
		  WHEN b.F4554 = 1 THEN '45_54' 
		  WHEN b.F5559 = 1 THEN '55_59'
		  WHEN b.F6064 = 1 THEN '60_64'
		  WHEN b.F6569 = 1 THEN '65_69'
		  WHEN b.F7074 = 1 THEN '70_74'
		  WHEN b.F7579 = 1 THEN '75_79' 
		  WHEN b.F8084 = 1 THEN '80_84'
		  WHEN b.F8589 = 1 THEN '85_89'
		  WHEN b.F9094 = 1 THEN '90_94'
		  WHEN b.F95GT = 1 THEN '95_GT'
		  WHEN b.M034 = 1 THEN '0_34'
		  WHEN b.M3544 = 1 THEN '35_44'
		  WHEN b.M4554 = 1 THEN '45_54' 
		  WHEN b.M5559 = 1 THEN '55_59' 
		  WHEN b.M6064 = 1 THEN '60_64' 
		  WHEN b.M6569 = 1 THEN '65_69' 
		  WHEN b.M7074 = 1 THEN '70_74' 
		  WHEN b.M7579 = 1 THEN '75_79'
		  WHEN b.M8084 = 1 THEN '80_84' 
		  WHEN b.M8589 = 1 THEN '85_89' 
		  WHEN b.M9094 = 1 THEN '90_94' 
		  WHEN b.M95GT = 1 THEN '95_GT'
	   END AS AgeGroup
     , CASE WHEN MedicaidFemaleDisabled = 1 THEN 'Y' 
		  WHEN MedicaidMaleDisabled = 1 THEN 'Y' 
		  ELSE 'N' END AS MedicaidDisabled
	, CASE WHEN MedicaidFemaleAged = 1 THEN 'Y'
		  WHEN MedicaidMaleAged = 1 THEN 'Y'
		  ELSE 'N' END AS MedicaidAged
	, CASE WHEN OriginallyDisabledFemale = 1 THEN 'Y' 
		  WHEN OriginallyDisabledMale = 1 THEN 'Y' 
		  ELSE 'N' END AS OriginallyDisabled
	, NULLIF(HCC001,0) AS HCC001, NULLIF(HCC002,0) AS HCC002, NULLIF(HCC006,0) AS HCC006, NULLIF(HCC008,0) AS HCC008, NULLIF(HCC009,0) AS HCC009
	, NULLIF(HCC010,0) AS HCC010, NULLIF(HCC011,0) AS HCC011, NULLIF(HCC012,0) AS HCC012, NULLIF(HCC017,0) AS HCC017, NULLIF(HCC018,0) AS HCC018
	, NULLIF(HCC019,0) AS HCC019, NULLIF(HCC021,0) AS HCC021, NULLIF(HCC022,0) AS HCC022, NULLIF(HCC023,0) AS HCC023, NULLIF(HCC027,0) AS HCC027
	, NULLIF(HCC028,0) AS HCC028, NULLIF(HCC029,0) AS HCC029, NULLIF(HCC033,0) AS HCC033, NULLIF(HCC034,0) AS HCC034, NULLIF(HCC035,0) AS HCC035
	, NULLIF(HCC039,0) AS HCC039, NULLIF(HCC040,0) AS HCC040, NULLIF(HCC046,0) AS HCC046, NULLIF(HCC047,0) AS HCC047, NULLIF(HCC048,0) AS HCC048
	, NULLIF(HCC051,0) AS HCC051, NULLIF(HCC052,0) AS HCC052, NULLIF(HCC054,0) AS HCC054, NULLIF(HCC055,0) AS HCC055, NULLIF(HCC057,0) AS HCC057
	, NULLIF(HCC058,0) AS HCC058, NULLIF(HCC070,0) AS HCC070, NULLIF(HCC071,0) AS HCC071, NULLIF(HCC072,0) AS HCC072, NULLIF(HCC073,0) AS HCC073
	, NULLIF(HCC074,0) AS HCC074, NULLIF(HCC075,0) AS HCC075, NULLIF(HCC076,0) AS HCC076, NULLIF(HCC077,0) AS HCC077, NULLIF(HCC078,0) AS HCC078
	, NULLIF(HCC079,0) AS HCC079, NULLIF(HCC080,0) AS HCC080, NULLIF(HCC082,0) AS HCC082, NULLIF(HCC083,0) AS HCC083, NULLIF(HCC084,0) AS HCC084
	, NULLIF(HCC085,0) AS HCC085, NULLIF(HCC086,0) AS HCC086, NULLIF(HCC087,0) AS HCC087, NULLIF(HCC088,0) AS HCC088, NULLIF(HCC096,0) AS HCC096
	, NULLIF(HCC099,0) AS HCC099, NULLIF(HCC100,0) AS HCC100, NULLIF(HCC103,0) AS HCC103, NULLIF(HCC104,0) AS HCC104, NULLIF(HCC106,0) AS HCC106
	, NULLIF(HCC107,0) AS HCC107, NULLIF(HCC108,0) AS HCC108, NULLIF(HCC110,0) AS HCC110, NULLIF(HCC111,0) AS HCC111, NULLIF(HCC112,0) AS HCC112
	, NULLIF(HCC114,0) AS HCC114, NULLIF(HCC115,0) AS HCC115, NULLIF(HCC122,0) AS HCC122, NULLIF(HCC124,0) AS HCC124, NULLIF(HCC134,0) AS HCC134
	, NULLIF(HCC135,0) AS HCC135, NULLIF(HCC136,0) AS HCC136, NULLIF(HCC137,0) AS HCC137, NULLIF(HCC138,0) AS HCC138, NULLIF(HCC139,0) AS HCC139
	, NULLIF(HCC140,0) AS HCC140, NULLIF(HCC141,0) AS HCC141, NULLIF(HCC157,0) AS HCC157, NULLIF(HCC158,0) AS HCC158, NULLIF(HCC159,0) AS HCC159
	, NULLIF(HCC160,0) AS HCC160, NULLIF(HCC161,0) AS HCC161, NULLIF(HCC162,0) AS HCC162, NULLIF(HCC166,0) AS HCC166, NULLIF(HCC167,0) AS HCC167
	, NULLIF(HCC169,0) AS HCC169, NULLIF(HCC170,0) AS HCC170, NULLIF(HCC173,0) AS HCC173, NULLIF(HCC176,0) AS HCC176, NULLIF(HCC186,0) AS HCC186
	, NULLIF(HCC188,0) AS HCC188, NULLIF(HCC189,0) AS HCC189, NULLIF(DD_HCC006,0) AS DD_HCC006, NULLIF(DD_HCC034,0) AS DD_HCC034, NULLIF(DD_HCC046,0) AS DD_HCC046
	, NULLIF(DD_HCC054,0) AS DD_HCC054, NULLIF(DD_HCC055,0) AS DD_HCC055, NULLIF(DD_HCC110,0) AS DD_HCC110, NULLIF(DD_HCC176,0) AS DD_HCC176
	, NULLIF(DD_HCC039,0) AS DD_HCC039, NULLIF(DD_HCC077,0) AS DD_HCC077, NULLIF(DD_HCC085,0) AS DD_HCC085, NULLIF(DD_HCC161,0) AS DD_HCC161
	, ESRD
	, [CANCER_IMMUNE]
	, [CHF_COPD]
	, [CHF_RENAL]
	, [COPD_CARD_RESP_FAIL]
	, [DIABETES_CHF]
	, [SEPSIS_CARD_RESP_FAIL]
	, [MEDICAID]
	, [DISABLED_PRESSURE_ULCER]
	, [ART_OPENINGS_PRESSURE_ULCER]
	, [ASP_SPEC_BACT_PNEUM_PRES_ULC]
	, [COPD_ASP_SPEC_BACT_PNEUM]
	, [SCHIZOPHRENIA_CHF]
	, [SCHIZOPHRENIA_COPD]
	, [SCHIZOPHRENIA_SEIZURES]
	, [SEPSIS_ARTIF_OPENINGS]
	, [SEPSIS_ASP_SPEC_BACT_PNEUM]
	, [SEPSIS_PRESSURE_ULCER]
	, NULL AS INT1
     , NULL AS INT2
     , NULL AS INT3
     , NULL AS INT4
     , NULL AS INT5
     , NULL AS INT6
	, cl.Client_BK AS CentauriClientID
	, m.Member_BK AS CentauriMemberID
	FROM dbo.H_MOR_Header h 
	INNER JOIN dbo.L_Member_MOR l ON l.H_MOR_Header_RK = h.H_MOR_Header_RK
	INNER JOIN dbo.H_Member m ON m.H_Member_RK = l.H_Member_RK
	INNER JOIN dbo.LS_MOR_BRecord b ON b.L_Member_MOR_RK = l.L_Member_MOR_RK 
	CROSS JOIN dbo.H_Client cl 
	WHERE b.RecordEndDate IS NULL ) p
UNPIVOT
   (present FOR HCC IN  
      ( HCC001, HCC002, HCC006, HCC008, HCC009, HCC010, HCC011, HCC012, HCC017, HCC018, HCC019, HCC021, HCC022, HCC023, HCC027, HCC028, HCC029, HCC033
		, HCC034, HCC035, HCC039, HCC040, HCC046, HCC047, HCC048, HCC051, HCC052, HCC054, HCC055, HCC057, HCC058, HCC070, HCC071, HCC072, HCC073, HCC074
		, HCC075, HCC076, HCC077, HCC078, HCC079, HCC080, HCC082, HCC083, HCC084, HCC085, HCC086, HCC087, HCC088, HCC096, HCC099, HCC100, HCC103, HCC104
		, HCC106, HCC107, HCC108, HCC110, HCC111, HCC112, HCC114, HCC115, HCC122, HCC124, HCC134, HCC135, HCC136, HCC137, HCC138, HCC139, HCC140, HCC141
		, HCC157, HCC158, HCC159, HCC160, HCC161, HCC162, HCC166, HCC167, HCC169, HCC170, HCC173, HCC176, HCC186, HCC188, HCC189, DD_HCC006, DD_HCC034
		, DD_HCC046, DD_HCC054, DD_HCC055, DD_HCC110, DD_HCC176, DD_HCC039, DD_HCC077, DD_HCC085, DD_HCC161)
)AS unpvt;






GO