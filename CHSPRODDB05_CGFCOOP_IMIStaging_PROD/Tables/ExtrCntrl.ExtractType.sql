CREATE TABLE [ExtrCntrl].[ExtractType]
(
[ExtractTypeID] [int] NOT NULL IDENTITY(1, 1),
[ExtractTypeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractTypeDesc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ExtrCntrl].[ExtractType] ADD CONSTRAINT [pk_ExtractType] PRIMARY KEY CLUSTERED  ([ExtractTypeID]) ON [PRIMARY]
GO
