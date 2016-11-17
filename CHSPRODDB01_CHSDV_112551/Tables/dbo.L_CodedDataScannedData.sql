CREATE TABLE [dbo].[L_CodedDataScannedData]
(
[L_CodedDataScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_CodedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataScannedData] ADD CONSTRAINT [PK_L_CodedDataScannedData] PRIMARY KEY CLUSTERED  ([L_CodedDataScannedData_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataScannedData] ADD CONSTRAINT [FK_H_CodedData_RK4] FOREIGN KEY ([H_CodedData_RK]) REFERENCES [dbo].[H_CodedData] ([H_CodedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_CodedDataScannedData] ADD CONSTRAINT [FK_H_ScannedData_RK1] FOREIGN KEY ([H_ScannedData_RK]) REFERENCES [dbo].[H_ScannedData] ([H_ScannedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
