CREATE TABLE [dim].[UserClient]
(
[UserClientID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[ClientID] [int] NOT NULL,
[ClientUserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_UserClient_RecordStartDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_UserClient_RecordEndDate] DEFAULT ('2999-12-31')
) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserClient] ADD CONSTRAINT [PK_UserClient] PRIMARY KEY CLUSTERED  ([UserClientID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[UserClient] ADD CONSTRAINT [FK_UserClient_Client] FOREIGN KEY ([ClientID]) REFERENCES [dim].[Client] ([ClientID])
GO
ALTER TABLE [dim].[UserClient] ADD CONSTRAINT [FK_UserClient_User] FOREIGN KEY ([UserID]) REFERENCES [dim].[User] ([UserID])
GO
