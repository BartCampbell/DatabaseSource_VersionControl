CREATE TABLE [dbo].[RecordSources]
(
[RecordSource_PK] [int] NOT NULL IDENTITY(1, 1),
[RecordSource] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LoadDate] [datetime] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__RecordSou__Creat__45A94D10] DEFAULT (getdate())
) ON [PRIMARY]
GO
