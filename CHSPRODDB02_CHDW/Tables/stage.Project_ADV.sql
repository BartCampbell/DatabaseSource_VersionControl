CREATE TABLE [stage].[Project_ADV]
(
[CentauriProjectID] [int] NOT NULL,
[Project_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScan] [bit] NULL,
[IsCode] [bit] NULL,
[Client_PK] [smallint] NULL,
[dtInsert] [datetime] NULL,
[IsProspective] [bit] NULL,
[IsRetrospective] [bit] NULL,
[IsHEDIS] [bit] NULL,
[ProjectGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroup_PK] [int] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
