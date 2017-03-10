CREATE TABLE [dbo].[FaxQueue]
(
[FaxQueueID] [int] NOT NULL IDENTITY(1, 1),
[FaxQueueStatusID] [int] NOT NULL,
[DocumentPath] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxServiceReferenceID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PageCount] [int] NULL,
[ProviderSiteID] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxQueue] ADD CONSTRAINT [PK_FaxQueue] PRIMARY KEY CLUSTERED  ([FaxQueueID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxQueue] ADD CONSTRAINT [FK_FaxQueue_FaxQueueStatus] FOREIGN KEY ([FaxQueueStatusID]) REFERENCES [dbo].[FaxQueueStatus] ([FaxQueueStatusID])
GO
