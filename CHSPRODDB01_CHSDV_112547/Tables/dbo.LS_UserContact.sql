CREATE TABLE [dbo].[LS_UserContact]
(
[LS_UserContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_UserContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_UserContact] ADD CONSTRAINT [PK_LS_UserContact] PRIMARY KEY CLUSTERED  ([LS_UserContact_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_UserContact] ADD CONSTRAINT [FK_L_UserContact_RK1] FOREIGN KEY ([L_UserContact_RK]) REFERENCES [dbo].[L_UserContact] ([L_UserContact_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
