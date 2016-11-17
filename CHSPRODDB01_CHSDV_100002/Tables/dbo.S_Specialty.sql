CREATE TABLE [dbo].[S_Specialty]
(
[S_Specialty_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Specialty_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialtyDesc] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Specialty] ADD CONSTRAINT [PK_S_Specialty] PRIMARY KEY CLUSTERED  ([S_Specialty_RK], [LoadDate]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Specialty] ADD CONSTRAINT [FK_S_Specialty_H_Specialty] FOREIGN KEY ([H_Specialty_RK]) REFERENCES [dbo].[H_Specialty] ([H_Specialty_RK])
GO
