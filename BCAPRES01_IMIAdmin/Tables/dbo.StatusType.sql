CREATE TABLE [dbo].[StatusType]
(
[StatusTypeID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_StatusType_StatusTypeID] DEFAULT (newid()),
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StatusType] ADD CONSTRAINT [StatusType_PK] PRIMARY KEY CLUSTERED  ([StatusTypeID]) ON [PRIMARY]
GO
