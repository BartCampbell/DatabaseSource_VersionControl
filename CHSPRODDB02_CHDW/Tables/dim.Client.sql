CREATE TABLE [dim].[Client]
(
[ClientID] [int] NOT NULL IDENTITY(1, 1),
[CentauriClientID] [int] NOT NULL,
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_Client_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_Client_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[Client] ADD CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED  ([ClientID]) ON [PRIMARY]
GO
