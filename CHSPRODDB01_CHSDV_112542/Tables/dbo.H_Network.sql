CREATE TABLE [dbo].[H_Network]
(
[H_Network_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Network_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientNetworkID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_H_Network_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Network] ADD CONSTRAINT [PK_H_Network] PRIMARY KEY CLUSTERED  ([H_Network_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
