CREATE TABLE [dbo].[AbstractionType]
(
[AbstractionTypeID] [int] NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Destination] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AbstractionType] ADD CONSTRAINT [PK_AbstractionType] PRIMARY KEY CLUSTERED  ([AbstractionTypeID]) ON [PRIMARY]
GO
