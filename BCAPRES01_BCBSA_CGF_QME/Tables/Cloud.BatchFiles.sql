CREATE TABLE [Cloud].[BatchFiles]
(
[AssignedDate] [datetime] NULL,
[AssignedEngine] [uniqueidentifier] NULL,
[BatchFileGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_BatchFiles_FileGuid] DEFAULT (newid()),
[BatchFileID] [int] NOT NULL IDENTITY(1, 1),
[BatchID] [int] NOT NULL,
[ChkSha256] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_BatchFiles_CreatedDate] DEFAULT (getdate()),
[CryptoIV] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CryptoKey] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileFormatID] [int] NOT NULL,
[FileName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsAssigned] [bit] NOT NULL CONSTRAINT [DF_BatchFiles_IsNotified] DEFAULT ((0)),
[IsRetrieved] [bit] NOT NULL CONSTRAINT [DF_BatchFiles_IsRetrieved] DEFAULT ((0)),
[IsSubmitted] [bit] NOT NULL CONSTRAINT [DF_BatchFiles_IsSubmitted] DEFAULT ((0)),
[IsVerified] [bit] NOT NULL CONSTRAINT [DF_BatchFiles_IsVerified] DEFAULT ((0)),
[RetrievedDate] [datetime] NULL,
[SizeCompressed] [bigint] NOT NULL,
[SizeUncompressed] [bigint] NOT NULL,
[SubmittedDate] [datetime] NULL,
[VerifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[BatchFiles] ADD CONSTRAINT [PK_BatchFiles] PRIMARY KEY CLUSTERED  ([BatchFileID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_BatchFiles_BatchFileGuid] ON [Cloud].[BatchFiles] ([BatchFileGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_BatchFiles] ON [Cloud].[BatchFiles] ([BatchID], [FileFormatID], [FileName]) ON [PRIMARY]
GO
