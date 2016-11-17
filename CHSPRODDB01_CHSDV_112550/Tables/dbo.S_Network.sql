CREATE TABLE [dbo].[S_Network]
(
[S_Network_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Network_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Network] ADD CONSTRAINT [PK_S_Network] PRIMARY KEY CLUSTERED  ([S_Network_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Network] ADD CONSTRAINT [FK_S_Network_H_Network] FOREIGN KEY ([H_Network_RK]) REFERENCES [dbo].[H_Network] ([H_Network_RK])
GO
