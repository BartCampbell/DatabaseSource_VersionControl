CREATE TABLE [dbo].[S_Type]
(
[S_Type_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Type_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeDesc] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Type] ADD CONSTRAINT [PK_S_Type] PRIMARY KEY CLUSTERED  ([S_Type_RK], [LoadDate]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Type] ADD CONSTRAINT [FK_S_Type_H_Type] FOREIGN KEY ([H_Type_RK]) REFERENCES [dbo].[H_Type] ([H_Type_RK])
GO
