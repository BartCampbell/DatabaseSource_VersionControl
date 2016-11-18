CREATE TABLE [dim].[Date]
(
[ID] [int] NOT NULL,
[Date] [datetime] NOT NULL,
[Day] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DaySuffix] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DayOfWeek] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DOWInMonth] [tinyint] NOT NULL,
[DayOfYear] [int] NOT NULL,
[WeekOfYear] [tinyint] NOT NULL,
[WeekOfMonth] [tinyint] NOT NULL,
[Month] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MonthName] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Quarter] [tinyint] NOT NULL,
[QuarterName] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Year] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StandardDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HolidayText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[Date] ADD CONSTRAINT [PK_dim_Date] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_dim_Date_Date] ON [dim].[Date] ([Date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_Day] ON [dim].[Date] ([Day]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_DayOfWeek] ON [dim].[Date] ([DayOfWeek]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_DayOfYear] ON [dim].[Date] ([DayOfYear]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_DOWInMonth] ON [dim].[Date] ([DOWInMonth]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Time_HolidayText] ON [dim].[Date] ([HolidayText]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_Month] ON [dim].[Date] ([Month]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_MonthName] ON [dim].[Date] ([MonthName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_Quarter] ON [dim].[Date] ([Quarter]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_QuarterName] ON [dim].[Date] ([QuarterName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_WeekOfMonth] ON [dim].[Date] ([WeekOfMonth]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_WeekOfYear] ON [dim].[Date] ([WeekOfYear]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_dim_Date_Year] ON [dim].[Date] ([Year]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
