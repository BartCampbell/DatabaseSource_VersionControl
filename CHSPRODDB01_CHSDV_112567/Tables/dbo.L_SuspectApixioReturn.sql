CREATE TABLE [dbo].[L_SuspectApixioReturn]
(
[L_SuspectApixioReturn_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ApixioReturn_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectApixioReturn] ADD CONSTRAINT [PK_L_SuspectApixioReturn] PRIMARY KEY CLUSTERED  ([L_SuspectApixioReturn_RK]) ON [PRIMARY]
GO
