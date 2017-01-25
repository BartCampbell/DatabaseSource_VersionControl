CREATE TABLE [Random].[ZipCodes]
(
[AreaCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[County] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DST] [bit] NOT NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[Latitude] [decimal] (8, 4) NOT NULL,
[Longitude] [decimal] (8, 4) NOT NULL,
[TimeZone] [smallint] NOT NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Random].[ZipCodes] ADD CONSTRAINT [PK_Random_ZipCodes] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Random_ZipCodes] ON [Random].[ZipCodes] ([ZipCode], [City], [State], [County]) ON [PRIMARY]
GO
