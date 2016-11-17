CREATE TABLE [dbo].[LS_UserAdvanceLocation]
(
[LS_UserAdvanceLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_UserAdvanceLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_AdvanceLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_UserAdvanceLocation] ADD CONSTRAINT [PK_LS_UserAdvanceLocation] PRIMARY KEY CLUSTERED  ([LS_UserAdvanceLocation_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_UserAdvanceLocation] ADD CONSTRAINT [FK_L_UserAdvanceLocation_RK1] FOREIGN KEY ([L_UserAdvanceLocation_RK]) REFERENCES [dbo].[L_UserAdvanceLocation] ([L_UserAdvanceLocation_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
