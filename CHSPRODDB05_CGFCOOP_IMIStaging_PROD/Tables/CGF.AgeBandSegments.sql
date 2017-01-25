CREATE TABLE [CGF].[AgeBandSegments]
(
[AgeBandID] [int] NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AgeBandGuid] [uniqueidentifier] NOT NULL,
[AgeBandSegGuid] [uniqueidentifier] NOT NULL,
[FromAgeMonths] [smallint] NULL,
[FromAgeTotMonths] [int] NULL,
[FromAgeYears] [smallint] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToAgeMonths] [smallint] NULL,
[ToAgeTotMonths] [int] NULL,
[ToAgeYears] [smallint] NULL,
[AgeBandSegID] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AgeBandSegments] ON [CGF].[AgeBandSegments] ([AgeBandSegGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_AgeBandSegments] ON [CGF].[AgeBandSegments] ([AgeBandSegGuid])
GO
