CREATE TABLE [dbo].[H_esi1900]
(
[H_esi1900_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[esi1900_BK] [int] NULL,
[Clientesi1900ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_H_esi1900_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_esi1900] ADD CONSTRAINT [PK_H_esi1900] PRIMARY KEY CLUSTERED  ([H_esi1900_RK]) ON [PRIMARY]
GO
