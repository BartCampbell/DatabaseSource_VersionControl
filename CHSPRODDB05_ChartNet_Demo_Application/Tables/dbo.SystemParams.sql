CREATE TABLE [dbo].[SystemParams]
(
[SystemParamID] [int] NOT NULL IDENTITY(1, 1),
[ParamName] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParamIntValue] [int] NULL,
[ParamCharValue] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientName] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SystemParams] ADD CONSTRAINT [PK_SystemParams] PRIMARY KEY CLUSTERED  ([SystemParamID]) ON [PRIMARY]
GO
