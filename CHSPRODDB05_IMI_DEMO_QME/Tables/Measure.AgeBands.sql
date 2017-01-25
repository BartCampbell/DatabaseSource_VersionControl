CREATE TABLE [Measure].[AgeBands]
(
[AgeBandID] [int] NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AgeBandGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_AgeBands_AgeBandGuid] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[AgeBands] ADD CONSTRAINT [PK_AgeBands] PRIMARY KEY CLUSTERED  ([AgeBandID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AgeBands] ON [Measure].[AgeBands] ([AgeBandGuid]) ON [PRIMARY]
GO
