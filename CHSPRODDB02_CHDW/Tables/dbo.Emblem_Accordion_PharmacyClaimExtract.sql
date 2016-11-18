CREATE TABLE [dbo].[Emblem_Accordion_PharmacyClaimExtract]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[Member_ID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Member_DOB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Gender] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Metal_Level] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Member_LOB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_Specialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_ID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Claim_Line_Num] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Diagnosis_Codes] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NDC] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Emblem_Accordion_PharmacyClaimExtract] ADD CONSTRAINT [PK_Emblem_Accordion_PharmacyClaimExtract] PRIMARY KEY CLUSTERED  ([RecordID]) ON [PRIMARY]
GO
