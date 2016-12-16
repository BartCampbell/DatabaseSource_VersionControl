CREATE TABLE [dbo].[S_Network]
(
[S_Network_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Network_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Network] ADD CONSTRAINT [PK_S_Network] PRIMARY KEY CLUSTERED  ([S_Network_RK]) ON [PRIMARY]
GO
