CREATE TABLE [dbo].[tblEncounter]
(
[encounter_pk] [bigint] NOT NULL IDENTITY(1, 1),
[department_pk] [smallint] NULL,
[provider_pk] [smallint] NULL,
[FIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_pk] [int] NULL,
[DOS] [date] NULL,
[CPT_EM_Org] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPT_Other_Org] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCPCS] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AD] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Diag] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoderNote] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserted_user_pk] [smallint] NULL,
[inserted_date] [datetime] NULL,
[parent_encounter_pk] [bigint] NULL,
[tmp] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[h_id] [smallint] NULL,
[change] [smallint] NULL,
[query] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[task_hold] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[case_pk] [bigint] NULL,
[specialty] [smallint] NULL CONSTRAINT [DF_tblEncounter_specialty] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEncounter] ADD CONSTRAINT [PK_tblEncounter] PRIMARY KEY CLUSTERED  ([encounter_pk]) ON [PRIMARY]
GO
