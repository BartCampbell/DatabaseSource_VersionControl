CREATE TABLE [dbo].[H_ScannedData]
(
[H_ScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScannedData_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientScannedDataID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Scanned__LoadD__00AA174D] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ScannedData] ADD CONSTRAINT [PK_H_ScannedData] PRIMARY KEY CLUSTERED  ([H_ScannedData_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
