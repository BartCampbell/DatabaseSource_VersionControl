CREATE TABLE [dbo].[Frequency]
(
[FreqID] [int] NOT NULL IDENTITY(1, 1),
[FreqDesc] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreqValue] [int] NULL,
[FreqValueDesc] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Frequency] ADD CONSTRAINT [PK_Frequency] PRIMARY KEY CLUSTERED  ([FreqID]) ON [PRIMARY]
GO
