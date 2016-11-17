CREATE TABLE [dbo].[H_ProviderMaster]
(
[H_ProviderMaster_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProviderMaster_BK] [int] NULL,
[ClientProviderMasterID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Provide__LoadD__3552E9B6] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ProviderMaster] ADD CONSTRAINT [PK_H_ProviderMaster] PRIMARY KEY CLUSTERED  ([H_ProviderMaster_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
