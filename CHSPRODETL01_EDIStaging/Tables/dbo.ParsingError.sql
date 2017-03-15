CREATE TABLE [dbo].[ParsingError]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[Message] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ParsingError] ADD CONSTRAINT [PK_ParsingError_dbo] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
