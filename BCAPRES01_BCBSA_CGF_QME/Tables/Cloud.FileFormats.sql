CREATE TABLE [Cloud].[FileFormats]
(
[AllowAutoFields] [bit] NOT NULL CONSTRAINT [DF_FileFormats_AllowAutoFields] DEFAULT ((0)),
[CalculateXml] [bit] NOT NULL CONSTRAINT [DF_FileFormats_CalculateXml] DEFAULT ((0)),
[CreatedBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FileFormats_CreatedBy] DEFAULT (suser_sname()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_FileFormats_CreatedDate] DEFAULT (getdate()),
[CreatedSpId] [int] NOT NULL CONSTRAINT [DF_FileFormats_CreatedSpId] DEFAULT (@@spid),
[Descr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileFormatCtgyID] [tinyint] NOT NULL,
[FileFormatGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_FileFormats_FileFormatGuid] DEFAULT (newid()),
[FileFormatID] [int] NOT NULL IDENTITY(1, 1),
[FileFormatTypeID] [smallint] NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_FileFormats_IsEnabled] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[FileFormats] ADD CONSTRAINT [PK_FileFormats] PRIMARY KEY CLUSTERED  ([FileFormatID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FileFormats_FileFormatGuid] ON [Cloud].[FileFormats] ([FileFormatGuid]) ON [PRIMARY]
GO
