CREATE TABLE [bre].[DataSource]
(
[DataSourceID] [int] NOT NULL IDENTITY(1, 1),
[Source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BusinessKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [bre].[DataSource] ADD CONSTRAINT [PK_DataSource] PRIMARY KEY CLUSTERED  ([DataSourceID]) ON [PRIMARY]
GO
