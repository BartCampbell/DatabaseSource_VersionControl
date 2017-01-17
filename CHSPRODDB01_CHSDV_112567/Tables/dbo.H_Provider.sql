CREATE TABLE [dbo].[H_Provider]
(
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Provider_BK] [int] NULL,
[ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_H_Provider_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Provider] ADD CONSTRAINT [PK_H_Provider] PRIMARY KEY CLUSTERED  ([H_Provider_RK]) ON [PRIMARY]
GO
