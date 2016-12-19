CREATE TABLE [dbo].[tblProviderMaster]
(
[ProviderMaster_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Lastname] [varchar] (75) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LastUpdated] [smalldatetime] NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderMaster] ADD CONSTRAINT [PK_tblProviderMaster] PRIMARY KEY CLUSTERED  ([ProviderMaster_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
