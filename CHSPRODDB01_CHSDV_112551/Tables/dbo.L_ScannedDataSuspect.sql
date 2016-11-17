CREATE TABLE [dbo].[L_ScannedDataSuspect]
(
[L_ScannedDataSuspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ScannedDataSuspect] ADD CONSTRAINT [PK_L_ScannedDataSuspect] PRIMARY KEY CLUSTERED  ([L_ScannedDataSuspect_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ScannedDataSuspect] ADD CONSTRAINT [FK_H_ScannedData_RK5] FOREIGN KEY ([H_ScannedData_RK]) REFERENCES [dbo].[H_ScannedData] ([H_ScannedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ScannedDataSuspect] ADD CONSTRAINT [FK_H_Suspect_RK12] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
