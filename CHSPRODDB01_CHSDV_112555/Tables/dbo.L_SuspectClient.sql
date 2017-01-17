CREATE TABLE [dbo].[L_SuspectClient]
(
[L_SuspectClient_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectClient] ADD CONSTRAINT [PK_L_SuspectClient] PRIMARY KEY CLUSTERED  ([L_SuspectClient_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectClient] ADD CONSTRAINT [FK_H_Client_RK9] FOREIGN KEY ([H_Client_RK]) REFERENCES [dbo].[H_Client] ([H_Client_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_SuspectClient] ADD CONSTRAINT [FK_H_Suspect_RK] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
