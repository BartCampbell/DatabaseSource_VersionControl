CREATE TABLE [dbo].[upgradetaskhistory]
(
[ID] [numeric] (18, 0) NOT NULL,
[UPGRADE_TASK_FACTORY_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[BUILD_NUMBER] [int] NULL,
[STATUS] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[UPGRADE_TYPE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[upgradetaskhistory] ADD CONSTRAINT [PK_upgradetaskhistory] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
