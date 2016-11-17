CREATE TABLE [dbo].[S_ScannedDataDetail]
(
[S_ScannedDataDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ScannedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[is_deleted] [bit] NULL,
[CodedStatus] [tinyint] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ScannedDataDetail] ADD CONSTRAINT [PK_S_ScannedDataDetail] PRIMARY KEY CLUSTERED  ([S_ScannedDataDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ScannedDataDetail] ADD CONSTRAINT [FK_H_ScannedData_RK2] FOREIGN KEY ([H_ScannedData_RK]) REFERENCES [dbo].[H_ScannedData] ([H_ScannedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
