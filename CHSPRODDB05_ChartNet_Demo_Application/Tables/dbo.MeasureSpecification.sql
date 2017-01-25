CREATE TABLE [dbo].[MeasureSpecification]
(
[MeasureID] [int] NOT NULL,
[SpecificationText] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureSpecification] ADD CONSTRAINT [PK_MeasureSpecification] PRIMARY KEY CLUSTERED  ([MeasureID]) ON [PRIMARY]
GO
