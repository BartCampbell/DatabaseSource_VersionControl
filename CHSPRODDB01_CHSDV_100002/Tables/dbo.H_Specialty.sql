CREATE TABLE [dbo].[H_Specialty]
(
[H_Specialty_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SpecialtyCode_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Specialty] ADD CONSTRAINT [PK_H_Specialty] PRIMARY KEY CLUSTERED  ([H_Specialty_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
