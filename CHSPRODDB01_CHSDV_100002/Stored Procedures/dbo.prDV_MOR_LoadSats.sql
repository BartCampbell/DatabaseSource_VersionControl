SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:	     Travis Parker
-- Create date:	07/26/2016
-- Description:	Load MOR detail data to the DV from Staging 
-- =============================================
CREATE PROCEDURE [dbo].[prDV_MOR_LoadSats]
	-- Add the parameters for the stored procedure here
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

	   --LOAD TRAILER
        INSERT  INTO dbo.S_MOR_Trailer
                ( S_MOR_Trailer_RK ,
                  H_MOR_Header_RK ,
                  RecordTypeCode ,
                  ContractNumber ,
                  TotalRecordCount ,
                  LoadDate ,
                  RecordSource ,
                  HashDiff 
	           )
                SELECT  DISTINCT
                        s.S_MOR_Trailer_RK ,
                        s.H_MOR_Header_RK ,
                        s.RecordTypeCode ,
                        s.ContractNumber ,
                        s.TotalRecordCount ,
                        s.LoadDate ,
                        s.RecordSource ,
                        s.HashDiff
                FROM    CHSStaging.mor.MOR_Trailer_Stage s
                        LEFT JOIN dbo.S_MOR_Trailer t ON t.H_MOR_Header_RK = s.H_MOR_Header_RK
                                                         AND t.RecordEndDate IS NULL
                                                         AND t.HashDiff = s.HashDiff
                WHERE   t.S_MOR_Trailer_RK IS NULL; 

	   --RECORD END DATE CLEANUP
	   UPDATE  dbo.S_MOR_Trailer
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.S_MOR_Trailer AS z
                                    WHERE     z.H_MOR_Header_RK = a.H_MOR_Header_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MOR_Trailer a
        WHERE   a.RecordEndDate IS NULL;


	   --LOAD MemberHICN A RECORDS
        INSERT  INTO dbo.S_MemberHICN
                ( S_MemberHICN_RK ,
                  LoadDate ,
                  H_Member_RK ,
                  HICNumber ,
                  HashDiff ,
                  RecordSource 
	           )
                SELECT DISTINCT
                        a.S_MemberHICN_RK ,
                        a.LoadDate ,
                        a.H_Member_RK ,
                        a.HICN ,
                        a.S_MemberHICN_HashDiff ,
                        a.RecordSource
                FROM    CHSStaging.mor.MOR_ARecord_Stage a
                        LEFT JOIN dbo.S_MemberHICN s ON s.H_Member_RK = a.H_Member_RK
                                                        AND s.RecordEndDate IS NULL
                                                        AND s.HashDiff = a.S_MemberHICN_HashDiff
                WHERE   s.S_MemberHICN_RK IS NULL;
	   
	   --RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberHICN
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.S_MemberHICN AS z
                                    WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberHICN a
        WHERE   a.RecordEndDate IS NULL;

	   
	   --LOAD MemberHICN B RECORDS
        INSERT  INTO dbo.S_MemberHICN
                ( S_MemberHICN_RK ,
                  LoadDate ,
                  H_Member_RK ,
                  HICNumber ,
                  HashDiff ,
                  RecordSource 
	           )
                SELECT  DISTINCT
                        b.S_MemberHICN_RK ,
                        b.LoadDate ,
                        b.H_Member_RK ,
                        b.HICN ,
                        b.S_MemberHICN_HashDiff ,
                        b.RecordSource
                FROM    CHSStaging.mor.MOR_BRecord_Stage b
                        LEFT JOIN dbo.S_MemberHICN s ON s.H_Member_RK = b.H_Member_RK
                                                        AND s.RecordEndDate IS NULL
                                                        AND s.HashDiff = b.S_MemberHICN_HashDiff
                WHERE   s.S_MemberHICN_RK IS NULL;
	   
	   --RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberHICN
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.S_MemberHICN AS z
                                    WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberHICN a
        WHERE   a.RecordEndDate IS NULL;
	   
	   --LOAD MemberHICN C RECORDS
        INSERT  INTO dbo.S_MemberHICN
                ( S_MemberHICN_RK ,
                  LoadDate ,
                  H_Member_RK ,
                  HICNumber ,
                  HashDiff ,
                  RecordSource 
	           )
                SELECT  DISTINCT
                        c.S_MemberHICN_RK ,
                        c.LoadDate ,
                        c.H_Member_RK ,
                        c.HICN ,
                        c.S_MemberHICN_HashDiff ,
                        c.RecordSource
                FROM    CHSStaging.mor.MOR_CRecord_Stage c
                        LEFT JOIN dbo.S_MemberHICN s ON s.H_Member_RK = c.H_Member_RK
                                                        AND s.RecordEndDate IS NULL
                                                        AND s.HashDiff = c.S_MemberHICN_HashDiff
                WHERE   s.S_MemberHICN_RK IS NULL;
	   
	   --RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberHICN
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.S_MemberHICN AS z
                                    WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberHICN a
        WHERE   a.RecordEndDate IS NULL;
	   
	   --LOAD MemberDemo A RECORDS
        INSERT  INTO dbo.S_MemberDemo
                ( S_MemberDemo_RK ,
                  LoadDate ,
                  H_Member_RK ,
                  FirstName ,
                  LastName ,
                  MiddleInitial ,
                  Gender ,
                  DOB ,
                  HashDiff ,
                  RecordSource 
	           )
                SELECT  DISTINCT
                        a.S_MemberDemo_RK ,
                        a.LoadDate ,
                        a.H_Member_RK ,
                        a.FirstName ,
                        a.LastName ,
                        a.MI ,
                        a.Gender ,
                        a.DOB ,
                        a.S_MemberDemo_HashDiff ,
                        a.RecordSource
                FROM    CHSStaging.mor.MOR_ARecord_Stage a
                        LEFT JOIN dbo.S_MemberDemo s ON s.H_Member_RK = a.H_Member_RK
                                                        AND s.RecordEndDate IS NULL
                                                        AND a.S_MemberDemo_HashDiff = s.HashDiff
                WHERE   s.S_MemberDemo_RK IS NULL; 
	   
	   --RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberDemo
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.S_MemberDemo AS z
                                    WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberDemo a
        WHERE   a.RecordEndDate IS NULL;
	   
	   --LOAD MemberDemo B RECORDS
        INSERT  INTO dbo.S_MemberDemo
                ( S_MemberDemo_RK ,
                  LoadDate ,
                  H_Member_RK ,
                  FirstName ,
                  LastName ,
                  MiddleInitial ,
                  Gender ,
                  DOB ,
                  HashDiff ,
                  RecordSource 
	           )
                SELECT  DISTINCT
                        b.S_MemberDemo_RK ,
                        b.LoadDate ,
                        b.H_Member_RK ,
                        b.FirstName ,
                        b.LastName ,
                        b.MI ,
                        b.Gender ,
                        b.DOB ,
                        b.S_MemberDemo_HashDiff ,
                        b.RecordSource
                FROM    CHSStaging.mor.MOR_BRecord_Stage b
                        LEFT JOIN dbo.S_MemberDemo s ON s.H_Member_RK = b.H_Member_RK
                                                        AND s.RecordEndDate IS NULL
                                                        AND b.S_MemberDemo_HashDiff = s.HashDiff
                WHERE   s.S_MemberDemo_RK IS NULL; 
	   
	   --RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberDemo
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.S_MemberDemo AS z
                                    WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberDemo a
        WHERE   a.RecordEndDate IS NULL;
	   
	   --LOAD MemberDemo C RECORDS
        INSERT  INTO dbo.S_MemberDemo
                ( S_MemberDemo_RK ,
                  LoadDate ,
                  H_Member_RK ,
                  FirstName ,
                  LastName ,
                  MiddleInitial ,
                  Gender ,
                  DOB ,
                  HashDiff ,
                  RecordSource 
	           )
                SELECT  DISTINCT
                        c.S_MemberDemo_RK ,
                        c.LoadDate ,
                        c.H_Member_RK ,
                        c.FirstName ,
                        c.LastName ,
                        c.MI ,
                        c.Gender ,
                        c.DOB ,
                        c.S_MemberDemo_HashDiff ,
                        c.RecordSource
                FROM    CHSStaging.mor.MOR_CRecord_Stage c
                        LEFT JOIN dbo.S_MemberDemo s ON s.H_Member_RK = c.H_Member_RK
                                                        AND s.RecordEndDate IS NULL
                                                        AND c.S_MemberDemo_HashDiff = s.HashDiff
                WHERE   s.S_MemberDemo_RK IS NULL; 

	   --RECORD END DATE CLEANUP
        UPDATE  dbo.S_MemberDemo
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.S_MemberDemo AS z
                                    WHERE     z.H_Member_RK = a.H_Member_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_MemberDemo a
        WHERE   a.RecordEndDate IS NULL;
	   
	   -- LOAD MOR A RECORDS
        INSERT  INTO dbo.LS_MOR_ARecord
                ( LS_MOR_ARecord_RK ,
                  L_Member_MOR_RK ,
                  RecordTypeCode ,
                  HICN ,
                  LastName ,
                  FirstName ,
                  MI ,
                  DOB ,
                  Gender ,
                  SSN ,
                  F034 ,
                  F3544 ,
                  F4554 ,
                  F5559 ,
                  F6064 ,
                  F6569 ,
                  F7074 ,
                  F7579 ,
                  F8084 ,
                  F8589 ,
                  F9094 ,
                  F95GT ,
                  M034 ,
                  M3544 ,
                  M4554 ,
                  M5559 ,
                  M6064 ,
                  M6569 ,
                  M7074 ,
                  M7579 ,
                  M8084 ,
                  M8589 ,
                  M9094 ,
                  M95GT ,
                  MedicaidFemaleDisabled ,
                  MedicaidFemaleAged ,
                  MedicaidMaleDisabled ,
                  MedicaidMaleAged ,
                  OriginallyDisabledFemale ,
                  OriginallyDisabledMale ,
                  HCC1 ,
                  HCC2 ,
                  HCC5 ,
                  HCC7 ,
                  HCC8 ,
                  HCC9 ,
                  HCC10 ,
                  HCC15 ,
                  HCC16 ,
                  HCC17 ,
                  HCC18 ,
                  HCC19 ,
                  HCC21 ,
                  HCC25 ,
                  HCC26 ,
                  HCC27 ,
                  HCC31 ,
                  HCC32 ,
                  HCC33 ,
                  HCC37 ,
                  HCC38 ,
                  HCC44 ,
                  HCC45 ,
                  HCC51 ,
                  HCC52 ,
                  HCC54 ,
                  HCC55 ,
                  HCC67 ,
                  HCC68 ,
                  HCC69 ,
                  HCC70 ,
                  HCC71 ,
                  HCC72 ,
                  HCC73 ,
                  HCC74 ,
                  HCC75 ,
                  HCC77 ,
                  HCC78 ,
                  HCC79 ,
                  HCC80 ,
                  HCC81 ,
                  HCC82 ,
                  HCC83 ,
                  HCC92 ,
                  HCC95 ,
                  HCC96 ,
                  HCC100 ,
                  HCC101 ,
                  HCC104 ,
                  HCC105 ,
                  HCC107 ,
                  HCC108 ,
                  HCC111 ,
                  HCC112 ,
                  HCC119 ,
                  HCC130 ,
                  HCC131 ,
                  HCC132 ,
                  HCC148 ,
                  HCC149 ,
                  HCC150 ,
                  HCC154 ,
                  HCC155 ,
                  HCC157 ,
                  HCC158 ,
                  HCC161 ,
                  HCC164 ,
                  HCC174 ,
                  HCC176 ,
                  HCC177 ,
                  DD_HCC5 ,
                  DD_HCC44 ,
                  DD_HCC51 ,
                  DD_HCC52 ,
                  DD_HCC107 ,
                  INT1 ,
                  INT2 ,
                  INT3 ,
                  INT4 ,
                  INT5 ,
                  INT6 ,
                  RecordSource ,
                  LoadDate ,
                  HashDiff 
                )
                SELECT DISTINCT
                        s.LS_MOR_ARecord_RK ,
                        s.L_Member_MOR_RK ,
                        s.RecordTypeCode ,
                        s.HICN ,
                        s.LastName ,
                        s.FirstName ,
                        s.MI ,
                        s.DOB ,
                        s.Gender ,
                        s.SSN ,
                        s.F034 ,
                        s.F3544 ,
                        s.F4554 ,
                        s.F5559 ,
                        s.F6064 ,
                        s.F6569 ,
                        s.F7074 ,
                        s.F7579 ,
                        s.F8084 ,
                        s.F8589 ,
                        s.F9094 ,
                        s.F95GT ,
                        s.M034 ,
                        s.M3544 ,
                        s.M4554 ,
                        s.M5559 ,
                        s.M6064 ,
                        s.M6569 ,
                        s.M7074 ,
                        s.M7579 ,
                        s.M8084 ,
                        s.M8589 ,
                        s.M9094 ,
                        s.M95GT ,
                        s.MedicaidFemaleDisabled ,
                        s.MedicaidFemaleAged ,
                        s.MedicaidMaleDisabled ,
                        s.MedicaidMaleAged ,
                        s.OriginallyDisabledFemale ,
                        s.OriginallyDisabledMale ,
                        s.HCC1 ,
                        s.HCC2 ,
                        s.HCC5 ,
                        s.HCC7 ,
                        s.HCC8 ,
                        s.HCC9 ,
                        s.HCC10 ,
                        s.HCC15 ,
                        s.HCC16 ,
                        s.HCC17 ,
                        s.HCC18 ,
                        s.HCC19 ,
                        s.HCC21 ,
                        s.HCC25 ,
                        s.HCC26 ,
                        s.HCC27 ,
                        s.HCC31 ,
                        s.HCC32 ,
                        s.HCC33 ,
                        s.HCC37 ,
                        s.HCC38 ,
                        s.HCC44 ,
                        s.HCC45 ,
                        s.HCC51 ,
                        s.HCC52 ,
                        s.HCC54 ,
                        s.HCC55 ,
                        s.HCC67 ,
                        s.HCC68 ,
                        s.HCC69 ,
                        s.HCC70 ,
                        s.HCC71 ,
                        s.HCC72 ,
                        s.HCC73 ,
                        s.HCC74 ,
                        s.HCC75 ,
                        s.HCC77 ,
                        s.HCC78 ,
                        s.HCC79 ,
                        s.HCC80 ,
                        s.HCC81 ,
                        s.HCC82 ,
                        s.HCC83 ,
                        s.HCC92 ,
                        s.HCC95 ,
                        s.HCC96 ,
                        s.HCC100 ,
                        s.HCC101 ,
                        s.HCC104 ,
                        s.HCC105 ,
                        s.HCC107 ,
                        s.HCC108 ,
                        s.HCC111 ,
                        s.HCC112 ,
                        s.HCC119 ,
                        s.HCC130 ,
                        s.HCC131 ,
                        s.HCC132 ,
                        s.HCC148 ,
                        s.HCC149 ,
                        s.HCC150 ,
                        s.HCC154 ,
                        s.HCC155 ,
                        s.HCC157 ,
                        s.HCC158 ,
                        s.HCC161 ,
                        s.HCC164 ,
                        s.HCC174 ,
                        s.HCC176 ,
                        s.HCC177 ,
                        s.DD_HCC5 ,
                        s.DD_HCC44 ,
                        s.DD_HCC51 ,
                        s.DD_HCC52 ,
                        s.DD_HCC107 ,
                        s.INT1 ,
                        s.INT2 ,
                        s.INT3 ,
                        s.INT4 ,
                        s.INT5 ,
                        s.INT6 ,
                        s.RecordSource ,
                        s.LoadDate ,
                        s.HashDiff
                FROM    CHSStaging.mor.MOR_ARecord_Stage s
                        LEFT JOIN dbo.LS_MOR_ARecord a ON s.L_Member_MOR_RK = a.L_Member_MOR_RK
                                                          AND a.RecordEndDate IS NULL
                                                          AND s.HashDiff = a.HashDiff
                WHERE   a.LS_MOR_ARecord_RK IS NULL; 


	   --RECORD END DATE CLEANUP
        UPDATE  dbo.LS_MOR_ARecord
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.LS_MOR_ARecord AS z
                                    WHERE     z.L_Member_MOR_RK = a.L_Member_MOR_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_MOR_ARecord a
        WHERE   a.RecordEndDate IS NULL;
	   
	   -- LOAD MOR B RECORDS
        INSERT  INTO dbo.LS_MOR_BRecord
                ( LS_MOR_BRecord_RK ,
                  L_Member_MOR_RK ,
                  RecordTypeCode ,
                  HICN ,
                  LastName ,
                  FirstName ,
                  MI ,
                  DOB ,
                  Gender ,
                  SSN ,
                  ESRD ,
                  F034 ,
                  F3544 ,
                  F4554 ,
                  F5559 ,
                  F6064 ,
                  F6569 ,
                  F7074 ,
                  F7579 ,
                  F8084 ,
                  F8589 ,
                  F9094 ,
                  F95GT ,
                  M034 ,
                  M3544 ,
                  M4554 ,
                  M5559 ,
                  M6064 ,
                  M6569 ,
                  M7074 ,
                  M7579 ,
                  M8084 ,
                  M8589 ,
                  M9094 ,
                  M95GT ,
                  MedicaidFemaleDisabled ,
                  MedicaidFemaleAged ,
                  MedicaidMaleDisabled ,
                  MedicaidMaleAged ,
                  OriginallyDisabledFemale ,
                  OriginallyDisabledMale ,
                  HCC001 ,
                  HCC002 ,
                  HCC006 ,
                  HCC008 ,
                  HCC009 ,
                  HCC010 ,
                  HCC011 ,
                  HCC012 ,
                  HCC017 ,
                  HCC018 ,
                  HCC019 ,
                  HCC021 ,
                  HCC022 ,
                  HCC023 ,
                  HCC027 ,
                  HCC028 ,
                  HCC029 ,
                  HCC033 ,
                  HCC034 ,
                  HCC035 ,
                  HCC039 ,
                  HCC040 ,
                  HCC046 ,
                  HCC047 ,
                  HCC048 ,
                  HCC051 ,
                  HCC052 ,
                  HCC054 ,
                  HCC055 ,
                  HCC057 ,
                  HCC058 ,
                  HCC070 ,
                  HCC071 ,
                  HCC072 ,
                  HCC073 ,
                  HCC074 ,
                  HCC075 ,
                  HCC076 ,
                  HCC077 ,
                  HCC078 ,
                  HCC079 ,
                  HCC080 ,
                  HCC082 ,
                  HCC083 ,
                  HCC084 ,
                  HCC085 ,
                  HCC086 ,
                  HCC087 ,
                  HCC088 ,
                  HCC096 ,
                  HCC099 ,
                  HCC100 ,
                  HCC103 ,
                  HCC104 ,
                  HCC106 ,
                  HCC107 ,
                  HCC108 ,
                  HCC110 ,
                  HCC111 ,
                  HCC112 ,
                  HCC114 ,
                  HCC115 ,
                  HCC122 ,
                  HCC124 ,
                  HCC134 ,
                  HCC135 ,
                  HCC136 ,
                  HCC137 ,
                  HCC138 ,
                  HCC139 ,
                  HCC140 ,
                  HCC141 ,
                  HCC157 ,
                  HCC158 ,
                  HCC159 ,
                  HCC160 ,
                  HCC161 ,
                  HCC162 ,
                  HCC166 ,
                  HCC167 ,
                  HCC169 ,
                  HCC170 ,
                  HCC173 ,
                  HCC176 ,
                  HCC186 ,
                  HCC188 ,
                  HCC189 ,
                  DD_HCC006 ,
                  DD_HCC034 ,
                  DD_HCC046 ,
                  DD_HCC054 ,
                  DD_HCC055 ,
                  DD_HCC110 ,
                  DD_HCC176 ,
                  CANCER_IMMUNE ,
                  CHF_COPD ,
                  CHF_RENAL ,
                  COPD_CARD_RESP_FAIL ,
                  DIABETES_CHF ,
                  SEPSIS_CARD_RESP_FAIL ,
                  MEDICAID ,
                  Orginaly_Disabled ,
                  DD_HCC039 ,
                  DD_HCC077 ,
                  DD_HCC085 ,
                  DD_HCC161 ,
                  ART_OPENINGS_PRESSURE_ULCER ,
                  ASP_SPEC_BACT_PNEUM_PRES_ULC ,
                  COPD_ASP_SPEC_BACT_PNEUM ,
                  DISABLED_PRESSURE_ULCER ,
                  SCHIZOPHRENIA_CHF ,
                  SCHIZOPHRENIA_COPD ,
                  SCHIZOPHRENIA_SEIZURES ,
                  SEPSIS_ARTIF_OPENINGS ,
                  SEPSIS_ASP_SPEC_BACT_PNEUM ,
                  SEPSIS_PRESSURE_ULCER ,
                  RecordSource ,
                  LoadDate ,
                  HashDiff 
                )
                SELECT DISTINCT
                        s.LS_MOR_BRecord_RK ,
                        s.L_Member_MOR_RK ,
                        s.RecordTypeCode ,
                        s.HICN ,
                        s.LastName ,
                        s.FirstName ,
                        s.MI ,
                        s.DOB ,
                        s.Gender ,
                        s.SSN ,
                        s.ESRD ,
                        s.F034 ,
                        s.F3544 ,
                        s.F4554 ,
                        s.F5559 ,
                        s.F6064 ,
                        s.F6569 ,
                        s.F7074 ,
                        s.F7579 ,
                        s.F8084 ,
                        s.F8589 ,
                        s.F9094 ,
                        s.F95GT ,
                        s.M034 ,
                        s.M3544 ,
                        s.M4554 ,
                        s.M5559 ,
                        s.M6064 ,
                        s.M6569 ,
                        s.M7074 ,
                        s.M7579 ,
                        s.M8084 ,
                        s.M8589 ,
                        s.M9094 ,
                        s.M95GT ,
                        s.MedicaidFemaleDisabled ,
                        s.MedicaidFemaleAged ,
                        s.MedicaidMaleDisabled ,
                        s.MedicaidMaleAged ,
                        s.OriginallyDisabledFemale ,
                        s.OriginallyDisabledMale ,
                        s.HCC001 ,
                        s.HCC002 ,
                        s.HCC006 ,
                        s.HCC008 ,
                        s.HCC009 ,
                        s.HCC010 ,
                        s.HCC011 ,
                        s.HCC012 ,
                        s.HCC017 ,
                        s.HCC018 ,
                        s.HCC019 ,
                        s.HCC021 ,
                        s.HCC022 ,
                        s.HCC023 ,
                        s.HCC027 ,
                        s.HCC028 ,
                        s.HCC029 ,
                        s.HCC033 ,
                        s.HCC034 ,
                        s.HCC035 ,
                        s.HCC039 ,
                        s.HCC040 ,
                        s.HCC046 ,
                        s.HCC047 ,
                        s.HCC048 ,
                        s.HCC051 ,
                        s.HCC052 ,
                        s.HCC054 ,
                        s.HCC055 ,
                        s.HCC057 ,
                        s.HCC058 ,
                        s.HCC070 ,
                        s.HCC071 ,
                        s.HCC072 ,
                        s.HCC073 ,
                        s.HCC074 ,
                        s.HCC075 ,
                        s.HCC076 ,
                        s.HCC077 ,
                        s.HCC078 ,
                        s.HCC079 ,
                        s.HCC080 ,
                        s.HCC082 ,
                        s.HCC083 ,
                        s.HCC084 ,
                        s.HCC085 ,
                        s.HCC086 ,
                        s.HCC087 ,
                        s.HCC088 ,
                        s.HCC096 ,
                        s.HCC099 ,
                        s.HCC100 ,
                        s.HCC103 ,
                        s.HCC104 ,
                        s.HCC106 ,
                        s.HCC107 ,
                        s.HCC108 ,
                        s.HCC110 ,
                        s.HCC111 ,
                        s.HCC112 ,
                        s.HCC114 ,
                        s.HCC115 ,
                        s.HCC122 ,
                        s.HCC124 ,
                        s.HCC134 ,
                        s.HCC135 ,
                        s.HCC136 ,
                        s.HCC137 ,
                        s.HCC138 ,
                        s.HCC139 ,
                        s.HCC140 ,
                        s.HCC141 ,
                        s.HCC157 ,
                        s.HCC158 ,
                        s.HCC159 ,
                        s.HCC160 ,
                        s.HCC161 ,
                        s.HCC162 ,
                        s.HCC166 ,
                        s.HCC167 ,
                        s.HCC169 ,
                        s.HCC170 ,
                        s.HCC173 ,
                        s.HCC176 ,
                        s.HCC186 ,
                        s.HCC188 ,
                        s.HCC189 ,
                        s.DD_HCC006 ,
                        s.DD_HCC034 ,
                        s.DD_HCC046 ,
                        s.DD_HCC054 ,
                        s.DD_HCC055 ,
                        s.DD_HCC110 ,
                        s.DD_HCC176 ,
                        s.CANCER_IMMUNE ,
                        s.CHF_COPD ,
                        s.CHF_RENAL ,
                        s.COPD_CARD_RESP_FAIL ,
                        s.DIABETES_CHF ,
                        s.SEPSIS_CARD_RESP_FAIL ,
                        s.MEDICAID ,
                        s.Orginaly_Disabled ,
                        s.DD_HCC039 ,
                        s.DD_HCC077 ,
                        s.DD_HCC085 ,
                        s.DD_HCC161 ,
                        s.ART_OPENINGS_PRESSURE_ULCER ,
                        s.ASP_SPEC_BACT_PNEUM_PRES_ULC ,
                        s.COPD_ASP_SPEC_BACT_PNEUM ,
                        s.DISABLED_PRESSURE_ULCER ,
                        s.SCHIZOPHRENIA_CHF ,
                        s.SCHIZOPHRENIA_COPD ,
                        s.SCHIZOPHRENIA_SEIZURES ,
                        s.SEPSIS_ARTIF_OPENINGS ,
                        s.SEPSIS_ASP_SPEC_BACT_PNEUM ,
                        s.SEPSIS_PRESSURE_ULCER ,
                        s.RecordSource ,
                        s.LoadDate ,
                        s.HashDiff
                FROM    CHSStaging.mor.MOR_BRecord_Stage s
                        LEFT JOIN dbo.LS_MOR_BRecord b ON s.L_Member_MOR_RK = b.L_Member_MOR_RK
                                                          AND b.RecordEndDate IS NULL
                                                          AND s.HashDiff = b.HashDiff
                WHERE   b.LS_MOR_BRecord_RK IS NULL; 

	   --RECORD END DATE CLEANUP
        UPDATE  dbo.LS_MOR_BRecord
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.LS_MOR_BRecord AS z
                                    WHERE     z.L_Member_MOR_RK = a.L_Member_MOR_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_MOR_BRecord a
        WHERE   a.RecordEndDate IS NULL;
	   
	   -- LOAD MOR C RECORDS
        INSERT  INTO dbo.LS_MOR_CRecord
                ( LS_MOR_CRecord_RK ,
                  L_Member_MOR_RK ,
                  RecordTypeCode ,
                  HICN ,
                  LastName ,
                  FirstName ,
                  MI ,
                  DOB ,
                  Gender ,
                  SSN ,
                  F034 ,
                  F3544 ,
                  F4554 ,
                  F5559 ,
                  F6064 ,
                  F6569 ,
                  F7074 ,
                  F7579 ,
                  F8084 ,
                  F8589 ,
                  F9094 ,
                  F95GT ,
                  M034 ,
                  M3544 ,
                  M4554 ,
                  M5559 ,
                  M6064 ,
                  M6569 ,
                  M7074 ,
                  M7579 ,
                  M8084 ,
                  M8589 ,
                  M9094 ,
                  M95GT ,
                  MedicaidFemaleDisabled ,
                  MedicaidFemaleAged ,
                  MedicaidMaleDisabled ,
                  MedicaidMaleAged ,
                  OriginallyDisabledFemale ,
                  OriginallyDisabledMale ,
                  HCC001 ,
                  HCC002 ,
                  HCC006 ,
                  HCC008 ,
                  HCC009 ,
                  HCC010 ,
                  HCC011 ,
                  HCC012 ,
                  HCC017 ,
                  HCC018 ,
                  HCC019 ,
                  HCC021 ,
                  HCC022 ,
                  HCC023 ,
                  HCC027 ,
                  HCC028 ,
                  HCC029 ,
                  HCC033 ,
                  HCC034 ,
                  HCC035 ,
                  HCC039 ,
                  HCC040 ,
                  HCC046 ,
                  HCC047 ,
                  HCC048 ,
                  HCC054 ,
                  HCC055 ,
                  HCC057 ,
                  HCC058 ,
                  HCC070 ,
                  HCC071 ,
                  HCC072 ,
                  HCC073 ,
                  HCC074 ,
                  HCC075 ,
                  HCC076 ,
                  HCC077 ,
                  HCC078 ,
                  HCC079 ,
                  HCC080 ,
                  HCC082 ,
                  HCC083 ,
                  HCC084 ,
                  HCC085 ,
                  HCC086 ,
                  HCC087 ,
                  HCC088 ,
                  HCC096 ,
                  HCC099 ,
                  HCC100 ,
                  HCC103 ,
                  HCC104 ,
                  HCC106 ,
                  HCC107 ,
                  HCC108 ,
                  HCC110 ,
                  HCC111 ,
                  HCC112 ,
                  HCC114 ,
                  HCC115 ,
                  HCC122 ,
                  HCC124 ,
                  HCC134 ,
                  HCC135 ,
                  HCC136 ,
                  HCC137 ,
                  HCC157 ,
                  HCC158 ,
                  HCC161 ,
                  HCC162 ,
                  HCC166 ,
                  HCC167 ,
                  HCC169 ,
                  HCC170 ,
                  HCC173 ,
                  HCC176 ,
                  HCC186 ,
                  HCC188 ,
                  HCC189 ,
                  DD_HCC006 ,
                  DD_HCC034 ,
                  DD_HCC046 ,
                  DD_HCC054 ,
                  DD_HCC055 ,
                  DD_HCC110 ,
                  DD_HCC176 ,
                  CANCER_IMMUNE ,
                  CHF_COPD ,
                  CHF_RENAL ,
                  COPD_CARD_RESP_FAIL ,
                  DIABETES_CHF ,
                  SEPSIS_CARD_RESP_FAIL ,
                  MEDICAID ,
                  Orginaly_Disabled ,
                  DD_HCC039 ,
                  DD_HCC077 ,
                  DD_HCC085 ,
                  DD_HCC161 ,
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
                  RecordSource ,
                  LoadDate ,
                  HashDiff
                )
                SELECT DISTINCT
                        s.LS_MOR_CRecord_RK ,
                        s.L_Member_MOR_RK ,
                        s.RecordTypeCode ,
                        s.HICN ,
                        s.LastName ,
                        s.FirstName ,
                        s.MI ,
                        s.DOB ,
                        s.Gender ,
                        s.SSN ,
                        s.F034 ,
                        s.F3544 ,
                        s.F4554 ,
                        s.F5559 ,
                        s.F6064 ,
                        s.F6569 ,
                        s.F7074 ,
                        s.F7579 ,
                        s.F8084 ,
                        s.F8589 ,
                        s.F9094 ,
                        s.F95GT ,
                        s.M034 ,
                        s.M3544 ,
                        s.M4554 ,
                        s.M5559 ,
                        s.M6064 ,
                        s.M6569 ,
                        s.M7074 ,
                        s.M7579 ,
                        s.M8084 ,
                        s.M8589 ,
                        s.M9094 ,
                        s.M95GT ,
                        s.MedicaidFemaleDisabled ,
                        s.MedicaidFemaleAged ,
                        s.MedicaidMaleDisabled ,
                        s.MedicaidMaleAged ,
                        s.OriginallyDisabledFemale ,
                        s.OriginallyDisabledMale ,
                        s.HCC001 ,
                        s.HCC002 ,
                        s.HCC006 ,
                        s.HCC008 ,
                        s.HCC009 ,
                        s.HCC010 ,
                        s.HCC011 ,
                        s.HCC012 ,
                        s.HCC017 ,
                        s.HCC018 ,
                        s.HCC019 ,
                        s.HCC021 ,
                        s.HCC022 ,
                        s.HCC023 ,
                        s.HCC027 ,
                        s.HCC028 ,
                        s.HCC029 ,
                        s.HCC033 ,
                        s.HCC034 ,
                        s.HCC035 ,
                        s.HCC039 ,
                        s.HCC040 ,
                        s.HCC046 ,
                        s.HCC047 ,
                        s.HCC048 ,
                        s.HCC054 ,
                        s.HCC055 ,
                        s.HCC057 ,
                        s.HCC058 ,
                        s.HCC070 ,
                        s.HCC071 ,
                        s.HCC072 ,
                        s.HCC073 ,
                        s.HCC074 ,
                        s.HCC075 ,
                        s.HCC076 ,
                        s.HCC077 ,
                        s.HCC078 ,
                        s.HCC079 ,
                        s.HCC080 ,
                        s.HCC082 ,
                        s.HCC083 ,
                        s.HCC084 ,
                        s.HCC085 ,
                        s.HCC086 ,
                        s.HCC087 ,
                        s.HCC088 ,
                        s.HCC096 ,
                        s.HCC099 ,
                        s.HCC100 ,
                        s.HCC103 ,
                        s.HCC104 ,
                        s.HCC106 ,
                        s.HCC107 ,
                        s.HCC108 ,
                        s.HCC110 ,
                        s.HCC111 ,
                        s.HCC112 ,
                        s.HCC114 ,
                        s.HCC115 ,
                        s.HCC122 ,
                        s.HCC124 ,
                        s.HCC134 ,
                        s.HCC135 ,
                        s.HCC136 ,
                        s.HCC137 ,
                        s.HCC157 ,
                        s.HCC158 ,
                        s.HCC161 ,
                        s.HCC162 ,
                        s.HCC166 ,
                        s.HCC167 ,
                        s.HCC169 ,
                        s.HCC170 ,
                        s.HCC173 ,
                        s.HCC176 ,
                        s.HCC186 ,
                        s.HCC188 ,
                        s.HCC189 ,
                        s.DD_HCC006 ,
                        s.DD_HCC034 ,
                        s.DD_HCC046 ,
                        s.DD_HCC054 ,
                        s.DD_HCC055 ,
                        s.DD_HCC110 ,
                        s.DD_HCC176 ,
                        s.CANCER_IMMUNE ,
                        s.CHF_COPD ,
                        s.CHF_RENAL ,
                        s.COPD_CARD_RESP_FAIL ,
                        s.DIABETES_CHF ,
                        s.SEPSIS_CARD_RESP_FAIL ,
                        s.MEDICAID ,
                        s.Orginaly_Disabled ,
                        s.DD_HCC039 ,
                        s.DD_HCC077 ,
                        s.DD_HCC085 ,
                        s.DD_HCC161 ,
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
                        s.RecordSource ,
                        s.LoadDate ,
                        s.HashDiff
                FROM    CHSStaging.mor.MOR_CRecord_Stage s
                        LEFT JOIN dbo.LS_MOR_CRecord c ON s.L_Member_MOR_RK = c.L_Member_MOR_RK
                                                          AND c.RecordEndDate IS NULL
                                                          AND s.HashDiff = c.HashDiff
                WHERE   c.LS_MOR_CRecord_RK IS NULL; 
	
	   --RECORD END DATE CLEANUP
        UPDATE  dbo.LS_MOR_CRecord
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                    FROM      dbo.LS_MOR_CRecord AS z
                                    WHERE     z.L_Member_MOR_RK = a.L_Member_MOR_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.LS_MOR_CRecord a
        WHERE   a.RecordEndDate IS NULL;
	
    END;
GO
