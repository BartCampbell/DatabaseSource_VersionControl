CREATE TABLE [stage].[tblProject2nd]
(
[Project_PK] [int] NOT NULL IDENTITY(1, 1),
[Project_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScan] [bit] NULL,
[IsCode] [bit] NULL,
[Client_PK] [smallint] NULL,
[dtInsert] [datetime] NULL,
[IsProspective] [bit] NULL CONSTRAINT [DF__tblProjec__IsPro__481BA567] DEFAULT ((0)),
[IsRetrospective] [bit] NULL,
[IsHEDIS] [bit] NULL,
[ProjectGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroup_PK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [stage].[tblProject2nd] ADD CONSTRAINT [PK_tblProject] PRIMARY KEY CLUSTERED  ([Project_PK]) ON [PRIMARY]
GO
