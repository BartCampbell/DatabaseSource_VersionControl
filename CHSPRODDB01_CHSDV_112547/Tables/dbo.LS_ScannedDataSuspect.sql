CREATE TABLE [dbo].[LS_ScannedDataSuspect]
(
[LS_ScannedDataSuspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ScannedDataSuspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ScannedDataSuspect] ADD CONSTRAINT [PK_LS_ScannedDataSuspect] PRIMARY KEY CLUSTERED  ([LS_ScannedDataSuspect_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-143518] ON [dbo].[LS_ScannedDataSuspect] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ScannedDataSuspect] ADD CONSTRAINT [FK_L_ScannedDataSuspect_RK1] FOREIGN KEY ([L_ScannedDataSuspect_RK]) REFERENCES [dbo].[L_ScannedDataSuspect] ([L_ScannedDataSuspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
