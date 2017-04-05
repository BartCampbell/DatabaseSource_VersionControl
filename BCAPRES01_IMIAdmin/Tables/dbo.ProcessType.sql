CREATE TABLE [dbo].[ProcessType]
(
[ProcessTypeID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ProcessType_ProcessTypeID] DEFAULT (newid()),
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProcessType] ADD CONSTRAINT [ProcessType_PK] PRIMARY KEY CLUSTERED  ([ProcessTypeID]) ON [PRIMARY]
GO
