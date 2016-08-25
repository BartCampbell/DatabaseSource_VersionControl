CREATE TABLE [dbo].[tblProviderMaster]
(
[ProviderMaster_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderMaster] ADD CONSTRAINT [PK_tblProviderMaster] PRIMARY KEY CLUSTERED  ([ProviderMaster_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
