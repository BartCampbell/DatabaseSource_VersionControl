CREATE TABLE [dbo].[tmpEncounterAll]
(
[Physician Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PowerChart Fin #] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Medical Record #] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date of Service] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCH Orig CPT -E & M] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCH Orig CPT - Other] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCH Orig DX] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Department] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMI CPT - E & M] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMI CPT - Other] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMI DX] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reasoning for Action Taken] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date Coded] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coder ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Task] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS] [date] NULL,
[CodedDate] [date] NULL,
[Dept] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
