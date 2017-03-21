CREATE TABLE [dbo].[tblProject]
(
[Project_PK] [int] NOT NULL IDENTITY(1, 1),
[Project_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScan] [bit] NULL,
[IsCode] [bit] NULL,
[Client_PK] [smallint] NULL,
[dtInsert] [datetime] NULL,
[IsProspective] [bit] NULL CONSTRAINT [DF__tblProjec__IsPro__236943A5] DEFAULT ((0)),
[IsRetrospective] [bit] NULL,
[IsHEDIS] [bit] NULL,
[ProjectGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroup_PK] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblProjectClient] ON [dbo].[tblProject] ([Client_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ProjectPK_IsRetro] ON [dbo].[tblProject] ([IsRetrospective], [Project_PK]) ON [PRIMARY]
GO
