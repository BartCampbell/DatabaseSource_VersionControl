CREATE TABLE [Cloud].[FileFormatTypes]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileExtension] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileFormatTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_FileFormatTypes_FileFormatTypeGuid] DEFAULT (newid()),
[FileFormatTypeID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[FileFormatTypes] ADD CONSTRAINT [PK_FileFormatTypes] PRIMARY KEY CLUSTERED  ([FileFormatTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FileFormatTypes_FileFormatTypeGuid] ON [Cloud].[FileFormatTypes] ([FileFormatTypeGuid]) ON [PRIMARY]
GO
