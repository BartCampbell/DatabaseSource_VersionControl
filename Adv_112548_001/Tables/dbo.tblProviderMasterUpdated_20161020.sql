CREATE TABLE [dbo].[tblProviderMasterUpdated_20161020]
(
[ProviderMaster_PK] [bigint] NOT NULL,
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
