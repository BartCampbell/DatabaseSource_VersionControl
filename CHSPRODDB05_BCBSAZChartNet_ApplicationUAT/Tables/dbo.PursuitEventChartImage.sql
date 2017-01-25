CREATE TABLE [dbo].[PursuitEventChartImage]
(
[PursuitEventChartImageID] [int] NOT NULL IDENTITY(1, 1),
[PursuitEventID] [int] NOT NULL,
[ImageOrdinal] [smallint] NOT NULL,
[ImageName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MimeType] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ImageData] [varbinary] (max) NOT NULL,
[AnnotationContent] [xml] NULL,
[AnnotationData] [varbinary] (max) NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_PursuitEventChartImage_CreatedDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_PursuitEventChartImage_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventChartImage] ADD CONSTRAINT [PK_PursuitEventChartImage] PRIMARY KEY CLUSTERED  ([PursuitEventChartImageID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventChartImage] ADD CONSTRAINT [FK_PursuitEventChartImage_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
