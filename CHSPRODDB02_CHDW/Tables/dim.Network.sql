CREATE TABLE [dim].[Network]
(
[NetworkID] [int] NOT NULL IDENTITY(1, 1),
[CentauriNetworkID] [int] NOT NULL,
[Network] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetworkName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_Network_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NOT NULL CONSTRAINT [DF_Network_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[Network] ADD CONSTRAINT [PK_Network] PRIMARY KEY CLUSTERED  ([NetworkID]) ON [PRIMARY]
GO
