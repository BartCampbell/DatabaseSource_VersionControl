CREATE TABLE [dbo].[Wellcare_ChartID_Crosswalk]
(
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Start ] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ending] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Wellcare_ChartID_Crosswalk] ADD CONSTRAINT [PK_Wellcare_ChartID_Crosswalk] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
