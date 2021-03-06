CREATE TABLE [dbo].[ApixioReturn]
(
[REFERENCE_NBR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER_NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER_LAST] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER_FIRST] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATE_OF_SERVICE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER_TYPE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_HICN] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_LAST] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_FIRST] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_DOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_GENDER] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD9] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD10] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMMENTS] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PATIENT_UUID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOCUMENT_UUID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAGE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CODER_HISTORY] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CODER_ANNOTATION_HISTORY] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CODING_DATE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DELIVERED] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHASECOMPLETE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suspect_PK] [int] NULL,
[ScannedData_PK] [int] NULL,
[Provider_PK] [int] NULL,
[FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[ClientID] [int] NULL,
[CentauriProviderID] [int] NULL,
[CentauriMemberID] [int] NULL,
[CentauriClientID] [int] NULL,
[H_Member_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_Provider_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ApixioReturn_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_ApixioReturn_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_MemberApixioReturn_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L_ProviderApixioReturn_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
