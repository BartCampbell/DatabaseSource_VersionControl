CREATE TABLE [Batch].[BatchData]
(
[BatchID] [int] NOT NULL,
[CreatedBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BatchData_CreatedBy] DEFAULT (suser_sname()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_BatchData_CreatedDate] DEFAULT (getdate()),
[Data] [xml] NULL,
[DataID] [int] NOT NULL IDENTITY(1, 1),
[FileFormatID] [int] NOT NULL
) ON [BTCH] TEXTIMAGE_ON [BTCH2]
GO
ALTER TABLE [Batch].[BatchData] ADD CONSTRAINT [PK_BatchData] PRIMARY KEY CLUSTERED  ([DataID]) ON [BTCH]
GO
CREATE NONCLUSTERED INDEX [IX_BatchData] ON [Batch].[BatchData] ([BatchID], [FileFormatID]) ON [IDX1]
GO
