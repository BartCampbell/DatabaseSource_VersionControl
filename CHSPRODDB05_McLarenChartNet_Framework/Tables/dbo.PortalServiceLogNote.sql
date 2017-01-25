CREATE TABLE [dbo].[PortalServiceLogNote]
(
[PortalServiceLogNoteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogNote_ServiceLogNoteID] DEFAULT (newid()),
[PortalServiceLogID] [uniqueidentifier] NOT NULL,
[PortalUserID] [uniqueidentifier] NOT NULL,
[PortalServiceLogNoteDate] [datetime] NOT NULL CONSTRAINT [DF_PortalServiceLogNote_ServiceLogNoteDate] DEFAULT (getdate()),
[OwnerID] [uniqueidentifier] NULL,
[AssignedUserID] [uniqueidentifier] NULL,
[PortalServiceLogStatusID] [uniqueidentifier] NULL,
[PortalServiceLogSeverityID] [uniqueidentifier] NULL,
[PortalServiceLogImportanceID] [uniqueidentifier] NULL,
[PortalServiceLogComplexityID] [uniqueidentifier] NULL,
[PortalServiceLogResolutionTypeID] [uniqueidentifier] NULL,
[PortalServiceLogResolutionOther] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PortalServiceLogCategoryID] [uniqueidentifier] NULL,
[PortalServiceLogCategoryOther] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsWorkOrder] [bit] NULL CONSTRAINT [DF_PortalServiceLogNote_IsWorkOrder] DEFAULT ((0)),
[ServiceLogNoteText] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogNote] ADD CONSTRAINT [PK_PortalServiceLogNote] PRIMARY KEY CLUSTERED  ([PortalServiceLogNoteID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogNote] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogNote_PortalServiceLog] FOREIGN KEY ([PortalServiceLogID]) REFERENCES [dbo].[PortalServiceLog] ([PortalServiceLogID])
GO
ALTER TABLE [dbo].[PortalServiceLogNote] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogNote_PortalServiceLogCategory] FOREIGN KEY ([PortalServiceLogCategoryID]) REFERENCES [dbo].[PortalServiceLogCategory] ([PortalServiceLogCategoryID])
GO
ALTER TABLE [dbo].[PortalServiceLogNote] ADD CONSTRAINT [FK_PortalServiceLogNote_PortalServiceLogComplexity] FOREIGN KEY ([PortalServiceLogComplexityID]) REFERENCES [dbo].[PortalServiceLogComplexity] ([PortalServiceLogComplexityID])
GO
ALTER TABLE [dbo].[PortalServiceLogNote] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogNote_PortalServiceLogImportance] FOREIGN KEY ([PortalServiceLogImportanceID]) REFERENCES [dbo].[PortalServiceLogImportance] ([PortalServiceLogImportanceID])
GO
ALTER TABLE [dbo].[PortalServiceLogNote] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogNote_PortalServiceLogResolutionType] FOREIGN KEY ([PortalServiceLogResolutionTypeID]) REFERENCES [dbo].[PortalServiceLogResolutionType] ([PortalServiceLogResolutionTypeID])
GO
ALTER TABLE [dbo].[PortalServiceLogNote] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogNote_PortalServiceLogSeverity] FOREIGN KEY ([PortalServiceLogSeverityID]) REFERENCES [dbo].[PortalServiceLogSeverity] ([PortalServiceLogSeverityID])
GO
ALTER TABLE [dbo].[PortalServiceLogNote] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogNote_PortalServiceLogStatus] FOREIGN KEY ([PortalServiceLogStatusID]) REFERENCES [dbo].[PortalServiceLogStatus] ([PortalServiceLogStatusID])
GO
ALTER TABLE [dbo].[PortalServiceLogNote] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogNote_PortalUser] FOREIGN KEY ([PortalUserID]) REFERENCES [dbo].[PortalUser] ([PortalUserID])
GO
