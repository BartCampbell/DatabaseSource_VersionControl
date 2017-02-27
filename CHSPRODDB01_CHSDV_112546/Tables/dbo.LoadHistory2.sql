CREATE TABLE [dbo].[LoadHistory2]
(
[TableName_PK] [int] NOT NULL,
[HashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordSource_PK] [int] NOT NULL,
[pkey] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
