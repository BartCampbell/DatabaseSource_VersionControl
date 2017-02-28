CREATE TABLE [dbo].[MAO004_Trailer]
(
[TrailerId] [int] NOT NULL IDENTITY(1, 1),
[HeaderId] [int] NOT NULL,
[RecordType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportId] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAContractId] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNumberOfRecords] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAO004_Trailer] ADD CONSTRAINT [PK_MAO004_Trailer] PRIMARY KEY CLUSTERED  ([TrailerId]) ON [PRIMARY]
GO
