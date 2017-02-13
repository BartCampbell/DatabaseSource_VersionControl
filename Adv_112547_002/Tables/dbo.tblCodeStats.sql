CREATE TABLE [dbo].[tblCodeStats]
(
[Chart_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InAdvance] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Coded] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasImage] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Priority] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Coded1] ON [dbo].[tblCodeStats] ([Coded], [InAdvance], [Priority], [HasImage]) INCLUDE ([Chart_ID]) ON [PRIMARY]
GO
