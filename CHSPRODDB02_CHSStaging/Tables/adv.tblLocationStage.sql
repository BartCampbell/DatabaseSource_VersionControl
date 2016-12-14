CREATE TABLE [adv].[tblLocationStage]
(
[Location_PK] [tinyint] NOT NULL,
[Location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblLocationStage] ADD CONSTRAINT [PK_tblLocation] PRIMARY KEY CLUSTERED  ([Location_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
