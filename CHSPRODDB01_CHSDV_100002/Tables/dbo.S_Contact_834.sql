CREATE TABLE [dbo].[S_Contact_834]
(
[S_Contact_834_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact3Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Contact_834] ADD CONSTRAINT [PK_S_Contact_834] PRIMARY KEY CLUSTERED  ([S_Contact_834_RK], [LoadDate]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Contact_834] ADD CONSTRAINT [FK_S_Contact_834_H_Contact] FOREIGN KEY ([H_Contact_RK]) REFERENCES [dbo].[H_Contact] ([H_Contact_RK])
GO
