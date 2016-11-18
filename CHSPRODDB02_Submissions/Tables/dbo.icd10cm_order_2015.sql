CREATE TABLE [dbo].[icd10cm_order_2015]
(
[LineID] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DxCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Indicator] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DxShortDescription] [varchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DxLongDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
