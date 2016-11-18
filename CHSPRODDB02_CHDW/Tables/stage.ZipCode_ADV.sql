CREATE TABLE [stage].[ZipCode_ADV]
(
[CentauriZipCodeID] [int] NULL,
[ZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Longitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
