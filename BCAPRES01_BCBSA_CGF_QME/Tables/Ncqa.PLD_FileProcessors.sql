CREATE TABLE [Ncqa].[PLD_FileProcessors]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PldFileProcessGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PLD_FileProcessors_PldFileProcessGuid] DEFAULT (newid()),
[PldFileProcessID] [tinyint] NOT NULL,
[ProcName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PLD_FileProcessors] ADD CONSTRAINT [PK_PLD_FileProcessors] PRIMARY KEY CLUSTERED  ([PldFileProcessID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PLD_FileProcessors_PldFileProcessGuid] ON [Ncqa].[PLD_FileProcessors] ([PldFileProcessGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PLD_FileProcessors_Proc] ON [Ncqa].[PLD_FileProcessors] ([ProcSchema], [ProcName]) ON [PRIMARY]
GO
