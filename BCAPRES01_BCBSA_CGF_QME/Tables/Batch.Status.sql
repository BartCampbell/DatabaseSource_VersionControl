CREATE TABLE [Batch].[Status]
(
[Abbrev] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BatchStatusGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Status_BatchStatusGuid] DEFAULT (newid()),
[BatchStatusID] [smallint] NOT NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DoesWork] [bit] NOT NULL CONSTRAINT [DF_Status_DoesWork] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Batch].[Status] ADD CONSTRAINT [PK_Batch_Status] PRIMARY KEY CLUSTERED  ([BatchStatusID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Batch_Status_Abbrev] ON [Batch].[Status] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Batch_Status_BatchStatusGuid] ON [Batch].[Status] ([BatchStatusGuid]) ON [PRIMARY]
GO
