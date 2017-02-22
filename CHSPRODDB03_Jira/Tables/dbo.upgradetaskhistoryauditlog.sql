CREATE TABLE [dbo].[upgradetaskhistoryauditlog]
(
[ID] [numeric] (18, 0) NOT NULL,
[UPGRADE_TASK_FACTORY_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[BUILD_NUMBER] [int] NULL,
[STATUS] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[UPGRADE_TYPE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TIMEPERFORMED] [datetime] NULL,
[ACTION] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[upgradetaskhistoryauditlog] ADD CONSTRAINT [PK_upgradetaskhistoryauditlog] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
