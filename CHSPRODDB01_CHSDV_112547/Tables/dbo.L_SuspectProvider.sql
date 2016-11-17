CREATE TABLE [dbo].[L_SuspectProvider]
(
[L_SuspectProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectProvider] ADD CONSTRAINT [PK_L_SuspectProvider] PRIMARY KEY CLUSTERED  ([L_SuspectProvider_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectProvider] ADD CONSTRAINT [FK_H_Provider_RK5] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_SuspectProvider] ADD CONSTRAINT [FK_H_Suspect_RK2] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
