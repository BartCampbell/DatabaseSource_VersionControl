CREATE TABLE [dbo].[FaxQueueConfiguration]
(
[FaxQueueConfigurationID] [int] NOT NULL,
[ConfigurationValue] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConfigurationDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxQueueConfiguration] ADD CONSTRAINT [PK_FaxQueueConfiguration] PRIMARY KEY CLUSTERED  ([FaxQueueConfigurationID]) ON [PRIMARY]
GO
