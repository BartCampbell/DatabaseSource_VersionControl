CREATE TABLE [dbo].[Client]
(
[ClientID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Client_ClientID] DEFAULT (newid()),
[ClientName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [uniqueidentifier] NOT NULL,
[SystemID] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Client] ADD CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED  ([ClientID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Client] ADD CONSTRAINT [FK_Client_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customer] ([CustomerID])
GO
