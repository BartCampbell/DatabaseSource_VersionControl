CREATE TABLE [dbo].[L_CodedDataSuspect]
(
[L_CodedDataSuspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_CodedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataSuspect] ADD CONSTRAINT [PK_L_CodedDataSuspect] PRIMARY KEY CLUSTERED  ([L_CodedDataSuspect_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataSuspect] ADD CONSTRAINT [FK_H_CodedData_RK1] FOREIGN KEY ([H_CodedData_RK]) REFERENCES [dbo].[H_CodedData] ([H_CodedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_CodedDataSuspect] ADD CONSTRAINT [FK_H_Suspect_RK10] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
