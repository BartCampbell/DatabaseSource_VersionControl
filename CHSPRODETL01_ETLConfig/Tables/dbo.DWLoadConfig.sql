CREATE TABLE [dbo].[DWLoadConfig]
(
[DWLoadConfigID] [int] NOT NULL IDENTITY(1, 1),
[DWLoad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CentauriClientID] [int] NOT NULL,
[ClientDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_DWLoadConfig_Active] DEFAULT ((1)),
[LastLoad] [datetime] NULL,
[LastLoadStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DWLoadConfig] ADD CONSTRAINT [PK_DWLoadConfig] PRIMARY KEY CLUSTERED  ([DWLoadConfigID]) ON [PRIMARY]
GO
