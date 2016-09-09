CREATE TABLE [dbo].[tblEncounter]
(
[encounter_pk] [bigint] NOT NULL IDENTITY(1, 1),
[department_pk] [smallint] NULL,
[provider_pk] [smallint] NULL,
[FIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_pk] [int] NULL,
[DOS] [date] NULL,
[CPT_EM_Org] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_Other_Org] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DX_Org] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_EM_TMI] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_Other_TMI] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DX_TMI] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[change_reason] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserted_user_pk] [smallint] NULL,
[inserted_date] [datetime] NULL,
[parent_encounter_pk] [bigint] NULL,
[tmp] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_EM_TMI_olc] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[h_id] [smallint] NULL,
[tpa] [smallint] NULL,
[mor] [smallint] NULL,
[change] [smallint] NULL,
[Admit_Date] [date] NULL,
[Discharge_Date] [date] NULL,
[m_id] [int] NULL,
[m_comments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEncounter] ADD CONSTRAINT [PK_tblEncounter] PRIMARY KEY CLUSTERED  ([encounter_pk]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblEncounter_department] ON [dbo].[tblEncounter] ([department_pk]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblEncounter_User] ON [dbo].[tblEncounter] ([inserted_user_pk]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblEncounter_member] ON [dbo].[tblEncounter] ([member_pk]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblEncounter_provider] ON [dbo].[tblEncounter] ([provider_pk]) ON [PRIMARY]
GO
