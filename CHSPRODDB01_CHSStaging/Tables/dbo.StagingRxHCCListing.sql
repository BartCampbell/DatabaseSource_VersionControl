CREATE TABLE [dbo].[StagingRxHCCListing]
(
[Variable ] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Disease Group ] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Community, Non-Low Income, Age≥65 ] [float] NULL,
[Community, Non-Low Income, Age<65 ] [float] NULL,
[Community, Low Income, Age≥65 ] [float] NULL,
[Community, Low Income, Age<65 ] [float] NULL,
[Institutional ] [float] NULL
) ON [PRIMARY]
GO
