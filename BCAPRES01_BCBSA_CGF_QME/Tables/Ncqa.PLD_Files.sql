CREATE TABLE [Ncqa].[PLD_Files]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasHeader] [bit] NOT NULL CONSTRAINT [DF_PLD_Files_HasHeader] DEFAULT ((1)),
[MeasureSetID] [int] NOT NULL,
[PldFileGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PLD_Files_PldFileGuid] DEFAULT (newid()),
[PldFileID] [int] NOT NULL,
[PldFileProcessID] [tinyint] NOT NULL CONSTRAINT [DF_PLD_Files_PldFileProcessID] DEFAULT ((1)),
[PldFileTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PLD_Files] ADD CONSTRAINT [PK_PLD_Files] PRIMARY KEY CLUSTERED  ([PldFileID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PLD_Files_PldFileGuid] ON [Ncqa].[PLD_Files] ([PldFileGuid]) ON [PRIMARY]
GO
