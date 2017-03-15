CREATE TABLE [dbo].[DVLoadConfig]
(
[DVLoadConfigID] [int] NOT NULL IDENTITY(1, 1),
[DVLoad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CentauriClientID] [int] NOT NULL,
[ClientDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InboundDirectory] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_DVLoadConfig_Active] DEFAULT ((1))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[DVLoadConfig] ADD CONSTRAINT [PK_DVLoadConfig] PRIMARY KEY CLUSTERED  ([DVLoadConfigID]) ON [PRIMARY]
GO
