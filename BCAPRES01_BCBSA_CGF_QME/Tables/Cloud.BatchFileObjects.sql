CREATE TABLE [Cloud].[BatchFileObjects]
(
[BatchFileObjectID] [int] NOT NULL IDENTITY(1, 1),
[BatchID] [int] NOT NULL,
[CountRecords] [bigint] NULL,
[CountVerified] [bigint] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_BatchFileObjects_CreatedDate] DEFAULT (getdate()),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[FileFormatID] [int] NOT NULL,
[FileObjectID] [int] NOT NULL,
[IsVerified] [bit] NOT NULL CONSTRAINT [DF_BatchFileObjects_IsVerified] DEFAULT ((0)),
[VerifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[BatchFileObjects] ADD CONSTRAINT [PK_Cloud_BatchFileObjects] PRIMARY KEY CLUSTERED  ([BatchFileObjectID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Cloud_BatchFileObjects] ON [Cloud].[BatchFileObjects] ([BatchID], [FileObjectID]) ON [PRIMARY]
GO
