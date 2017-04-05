CREATE TABLE [Report].[Fields]
(
[AllowComparison] [bit] NOT NULL CONSTRAINT [DF_Fields_AllowComparison] DEFAULT ((1)),
[AllowDetail] [bit] NOT NULL CONSTRAINT [DF_Fields_AllowDetail] DEFAULT ((1)),
[AllowProviders] [bit] NOT NULL CONSTRAINT [DF_Fields_AllowProviders] DEFAULT ((1)),
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FieldGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Fields_FieldGuid] DEFAULT (newid()),
[FieldID] [tinyint] NOT NULL,
[FieldName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NumberFormat] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Report].[Fields] ADD CONSTRAINT [PK_Fields] PRIMARY KEY CLUSTERED  ([FieldID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Fields] ON [Report].[Fields] ([FieldName]) ON [PRIMARY]
GO
