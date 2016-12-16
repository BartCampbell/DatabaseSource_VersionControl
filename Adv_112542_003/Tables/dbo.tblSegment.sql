CREATE TABLE [dbo].[tblSegment]
(
[Segment_PK] [tinyint] NOT NULL IDENTITY(1, 1),
[Segment] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSegment] ADD CONSTRAINT [PK_tblSegment] PRIMARY KEY CLUSTERED  ([Segment_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
