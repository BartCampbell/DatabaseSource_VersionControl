CREATE TABLE [adv].[tblProjectStage]
(
[Project_PK] [int] NOT NULL,
[Project_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScan] [bit] NULL,
[IsCode] [bit] NULL,
[Client_PK] [smallint] NULL,
[dtInsert] [datetime] NULL,
[IsProspective] [bit] NULL CONSTRAINT [DF__tblProjec__IsPro__5265C05E] DEFAULT ((0)),
[IsRetrospective] [bit] NULL,
[IsHEDIS] [bit] NULL,
[ProjectGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroup_PK] [int] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblProjec__LoadD__5359E497] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProjectStage] ADD CONSTRAINT [PK_tblProjectStage] PRIMARY KEY CLUSTERED  ([Project_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
