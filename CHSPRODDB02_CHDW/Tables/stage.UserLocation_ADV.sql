CREATE TABLE [stage].[UserLocation_ADV]
(
[CentauriUserid] [int] NULL,
[CentauriAdvanceLocationID] [int] NULL,
[address] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zipcode_pk] [int] NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[ClientID] [int] NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
