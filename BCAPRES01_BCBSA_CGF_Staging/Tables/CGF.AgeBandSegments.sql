CREATE TABLE [CGF].[AgeBandSegments]
(
[AgeBandGuid] [uniqueidentifier] NOT NULL,
[AgeBandSegGuid] [uniqueidentifier] NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromAgeMonths] [smallint] NULL,
[FromAgeTotMonths] [int] NULL,
[FromAgeYears] [smallint] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToAgeMonths] [smallint] NULL,
[ToAgeTotMonths] [int] NULL,
[ToAgeYears] [smallint] NULL
) ON [PRIMARY]
GO
