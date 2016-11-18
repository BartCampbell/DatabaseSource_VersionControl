CREATE TABLE [ref].[ICDtoHCCCommercial]
(
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code_Description] [varchar] (230) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[V12HCC] [tinyint] NULL,
[V21HCC] [tinyint] NULL,
[V22HCC] [tinyint] NULL,
[RxHCC] [tinyint] NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[IsICD10] [bit] NOT NULL,
[RecID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [ref].[ICDtoHCCCommercial] ADD CONSTRAINT [PK_ModelCode] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
