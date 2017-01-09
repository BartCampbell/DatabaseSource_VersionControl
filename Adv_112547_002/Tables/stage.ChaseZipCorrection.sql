CREATE TABLE [stage].[ChaseZipCorrection]
(
[Chart ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIP] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode_PK] [int] NOT NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldZipCode_PK] [int] NULL,
[OldZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OldState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
