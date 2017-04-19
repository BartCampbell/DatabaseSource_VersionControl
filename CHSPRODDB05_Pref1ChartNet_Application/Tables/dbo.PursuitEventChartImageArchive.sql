CREATE TABLE [dbo].[PursuitEventChartImageArchive]
(
[PursuitEventChartImageID] [int] NOT NULL IDENTITY(1, 1),
[PursuitEventID] [int] NOT NULL,
[ImageOrdinal] [smallint] NOT NULL,
[ImageName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MimeType] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ImageData] [varbinary] (max) NOT NULL,
[AnnotationContent] [xml] NULL,
[AnnotationData] [varbinary] (max) NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL,
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
