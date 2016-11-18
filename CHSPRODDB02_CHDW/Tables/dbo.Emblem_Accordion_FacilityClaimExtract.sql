CREATE TABLE [dbo].[Emblem_Accordion_FacilityClaimExtract]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[Member_ID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Member_DOB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Gender] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Metal_Level] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Member_LOB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Specialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Claim_Line_Num] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[From_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[To_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_DIAG_ADMIT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_DIAG_01] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD_PROC_01] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD10_OR_HIGHER] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROC_CODE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_MOD_1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_MOD_2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Emblem_Accordion_FacilityClaimExtract] ADD CONSTRAINT [PK_Emblem_Accordion_FacilityClaimExtract] PRIMARY KEY CLUSTERED  ([RecordID]) ON [PRIMARY]
GO
