CREATE TABLE [Result].[ResultTypes]
(
[Abbrev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ResultTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ResultTypes_ResultTypeGuid] DEFAULT (newid()),
[ResultTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[ResultTypes] ADD CONSTRAINT [PK_ResultTypes] PRIMARY KEY CLUSTERED  ([ResultTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ResultTypes_Abbrev] ON [Result].[ResultTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ResultTypes_ResultTypeGuid] ON [Result].[ResultTypes] ([ResultTypeGuid]) ON [PRIMARY]
GO
