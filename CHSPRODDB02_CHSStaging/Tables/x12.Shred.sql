CREATE TABLE [x12].[Shred]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowIDParent] [int] NULL,
[CentauriClientID] [int] NULL,
[FileLogID] [int] NULL,
[TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoopSegment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoopName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoopXML] [xml] NULL,
[NodePathRoot] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [x12].[Shred] ADD CONSTRAINT [PK_X12Shred] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxX12ShredRowFileLogID] ON [x12].[Shred] ([FileLogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxX12ShredRowLoopSegment] ON [x12].[Shred] ([LoopSegment]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxX12ShredRowIDParent] ON [x12].[Shred] ([RowIDParent]) ON [PRIMARY]
GO
CREATE PRIMARY XML INDEX [idxX12LoopXML]
ON [x12].[Shred] ([LoopXML])
GO
