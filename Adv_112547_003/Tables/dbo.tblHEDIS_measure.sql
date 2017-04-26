CREATE TABLE [dbo].[tblHEDIS_measure]
(
[measure_PK] [smallint] NOT NULL IDENTITY(1, 1),
[hedis_year] [smallint] NULL,
[measure_description] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHEDIS_measure] ADD CONSTRAINT [PK_tblHEDIS_measure] PRIMARY KEY CLUSTERED  ([measure_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
