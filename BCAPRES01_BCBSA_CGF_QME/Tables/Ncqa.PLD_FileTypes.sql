CREATE TABLE [Ncqa].[PLD_FileTypes]
(
[ColumnDelimiter] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PldFileTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PLD_FileTypes_PldFileTypeGuid] DEFAULT (newid()),
[PldFileTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PLD_FileTypes] ADD CONSTRAINT [PK_PLD_FileTypes] PRIMARY KEY CLUSTERED  ([PldFileTypeID]) ON [PRIMARY]
GO
