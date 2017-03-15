CREATE TABLE [dbo].[FunctionalGroup]
(
[Id] [int] NOT NULL,
[InterchangeId] [int] NOT NULL,
[FunctionalIdCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [datetime] NULL,
[ControlNumber] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Version] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FunctionalGroup] ADD CONSTRAINT [PK_FunctionalGroup_dbo] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
