CREATE TABLE [dbo].[WellCare_2ndChaseList]
(
[Chart ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewZip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludeFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExclusionTab1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExclusionTab2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
