CREATE TABLE [dbo].[NLP_Autocode_VIVA_20160301]
(
[Id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Medphrase] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Medlex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Icd9Code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Icd9Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Processed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NLP_Autocode_VIVA_20160301] ADD CONSTRAINT [PK_NLP_Autocode_VIVA_20160301] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
