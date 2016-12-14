CREATE TABLE [adv].[tblCodedSourceStage]
(
[CodedSource_PK] [smallint] NOT NULL,
[CodedSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sortOrder] [smallint] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodedSourceHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblCodedSourceStage] ADD CONSTRAINT [PK_tblCodedSourceStage] PRIMARY KEY CLUSTERED  ([CodedSource_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
