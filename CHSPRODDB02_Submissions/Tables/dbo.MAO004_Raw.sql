CREATE TABLE [dbo].[MAO004_Raw]
(
[RecId] [int] NOT NULL IDENTITY(1, 1),
[InboundFileName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDateTime] [datetime] NOT NULL,
[ProcessedFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MAO004_RawData] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAO004_Raw] ADD CONSTRAINT [PK_MAO004_Raw] PRIMARY KEY CLUSTERED  ([RecId]) ON [PRIMARY]
GO
