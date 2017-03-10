CREATE TABLE [dbo].[FaxMeasureContent]
(
[ClientID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureID] [int] NULL,
[FaxMeasureInstruction] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
