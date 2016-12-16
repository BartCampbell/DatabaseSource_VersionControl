CREATE TABLE [dbo].[S_ProviderMasterDemo]
(
[S_ProviderMasterDemo_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMaster_PK] [bigint] NULL,
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ProviderMasterDemo] ADD CONSTRAINT [PK_S_ProviderMasterDemo] PRIMARY KEY CLUSTERED  ([S_ProviderMasterDemo_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ProviderMasterDemo] ADD CONSTRAINT [FK_H_Provider_RK14] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
