CREATE TABLE [dbo].[FHNSanteCllaims]
(
[LOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Adjustment_Indicator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Check_Num] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Patient_Account_Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Check_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Admission_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Allowed_Amt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Bill_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Charged_Amt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Discharge_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Discharge_Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Submitted_DRG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Computed_DRG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Paid_Amt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Place_of_Service] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Provider_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Paid_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Line_Amount_Allow] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Line_Amount_Charge] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Line_Amount_Paid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Line_CPT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Line_Date_of_Service_Begin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Line_Date_of_Service_End] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Line_Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Line_Revenue_Code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Modifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Modifier2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Modifier3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Modifier4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Units_Billed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Admitting] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Principal] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proc_Code1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proc_Code2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proc_Code3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proc_Code4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Principal_Procedure] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Par] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Specialty_Code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Taxonomy_Code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_TIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Full_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentStart1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentEnd1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentStart2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentEnd2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentStart3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentEnd3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentStart4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentEnd4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentStart5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentEnd5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_address_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_address_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Date_of_Birth] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_First_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Gender] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Last_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Middle_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Menber_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary6] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary7] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary8] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary9] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary10] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary11] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary12] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary13] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary14] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary15] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary16] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary17] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary18] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary19] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_Diagnosis_Secondary20] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
