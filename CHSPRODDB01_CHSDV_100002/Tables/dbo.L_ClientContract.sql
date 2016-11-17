CREATE TABLE [dbo].[L_ClientContract]
(
[L_ClientContract_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contract_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ClientContract] ADD CONSTRAINT [PK_L_ClientContract] PRIMARY KEY CLUSTERED  ([L_ClientContract_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ClientContract] ADD CONSTRAINT [FK_L_ClientContract_H_Client] FOREIGN KEY ([H_Client_RK]) REFERENCES [dbo].[H_Client] ([H_Client_RK])
GO
ALTER TABLE [dbo].[L_ClientContract] ADD CONSTRAINT [FK_L_ClientContract_H_Contract] FOREIGN KEY ([H_Contract_RK]) REFERENCES [dbo].[H_Contract] ([H_Contract_RK])
GO
