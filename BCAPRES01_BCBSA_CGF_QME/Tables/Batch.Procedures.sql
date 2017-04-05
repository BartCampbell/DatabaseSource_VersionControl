CREATE TABLE [Batch].[Procedures]
(
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_Procedures_IsEnabled] DEFAULT ((1)),
[ProcGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Procedures_ProcGuid] DEFAULT (newid()),
[ProcID] [smallint] NOT NULL,
[ProcName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RunOrder] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[Procedures] ADD CONSTRAINT [PK_Procedures] PRIMARY KEY CLUSTERED  ([ProcID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Procedures_ProcGuid] ON [Batch].[Procedures] ([ProcGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Procedures_RunOrder] ON [Batch].[Procedures] ([RunOrder]) ON [PRIMARY]
GO
