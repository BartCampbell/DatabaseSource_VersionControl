SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetFPCDateRanges]
(	
	@MemberID int = NULL
)
RETURNS @Results TABLE 
(
	[MemberMeasureSampleID] [int] NOT NULL,
	[MemberID] [int] NOT NULL,
	[MeasureID] [int] NOT NULL,
	[EventDate] datetime NOT NULL,
	[CountExpected] [int] NULL,
	[DeliveryDate] [datetime] NOT NULL,
	[AdminDeliveryDate] [datetime] NOT NULL,
	[MRDeliveryDate] [datetime] NULL,
	[GestDays] [int] NULL,
	[GestWeeks] [decimal](20, 0) NULL,
	[GestStartDate] [datetime] NULL,
	[LastSegBeginDate] [datetime] NULL,
	[EnrollDays] [int] NULL,
	[EnrollMonths] [decimal](21, 9) NULL
)
AS 
BEGIN
	DECLARE @PPCDeliveryDateMatchingWindow int;
	SET @PPCDeliveryDateMatchingWindow = ISNULL(ABS(dbo.GetPPCDeliveryDateMatchingWindow()),
												180);
	DECLARE @MeasureID int;
	SELECT  @MeasureID = MeasureID
	FROM    dbo.Measure
	WHERE   HEDISMeasure = 'FPC';

	DECLARE @FPCKey TABLE
	(
		EnrollMonths smallint NOT NULL,
		GestWeeks tinyint NOT NULL,
		CountExpected smallint NOT NULL,
		PRIMARY KEY CLUSTERED (EnrollMonths, GestWeeks)
	);

	--Copied from Ncqa.FPC_ExpectedVisitsKey...
	WITH    FPCKey(EnrollMonths, GestWeeks, CountExpected)
			  AS (
				  /*Adapted from POP_HEDIS_FACT_FPC*/
				  SELECT    0,
							6,
							0
				  UNION ALL
				  SELECT    0,
							7,
							0
				  UNION ALL
				  SELECT    0,
							8,
							1
				  UNION ALL
				  SELECT    0,
							9,
							1
				  UNION ALL
				  SELECT    0,
							10,
							1
				  UNION ALL
				  SELECT    0,
							11,
							1
				  UNION ALL
				  SELECT    0,
							12,
							2
				  UNION ALL
				  SELECT    0,
							13,
							2
				  UNION ALL
				  SELECT    0,
							14,
							2
				  UNION ALL
				  SELECT    0,
							15,
							2
				  UNION ALL
				  SELECT    0,
							16,
							3
				  UNION ALL
				  SELECT    0,
							17,
							3
				  UNION ALL
				  SELECT    0,
							18,
							3
				  UNION ALL
				  SELECT    0,
							19,
							3
				  UNION ALL
				  SELECT    0,
							20,
							4
				  UNION ALL
				  SELECT    0,
							21,
							4
				  UNION ALL
				  SELECT    0,
							22,
							4
				  UNION ALL
				  SELECT    0,
							23,
							4
				  UNION ALL
				  SELECT    0,
							24,
							5
				  UNION ALL
				  SELECT    0,
							25,
							5
				  UNION ALL
				  SELECT    0,
							26,
							5
				  UNION ALL
				  SELECT    0,
							27,
							5
				  UNION ALL
				  SELECT    0,
							28,
							6
				  UNION ALL
				  SELECT    0,
							29,
							6
				  UNION ALL
				  SELECT    0,
							30,
							7
				  UNION ALL
				  SELECT    0,
							31,
							7
				  UNION ALL
				  SELECT    0,
							32,
							8
				  UNION ALL
				  SELECT    0,
							33,
							8
				  UNION ALL
				  SELECT    0,
							34,
							9
				  UNION ALL
				  SELECT    0,
							35,
							9
				  UNION ALL
				  SELECT    0,
							36,
							10
				  UNION ALL
				  SELECT    0,
							37,
							11
				  UNION ALL
				  SELECT    0,
							38,
							12
				  UNION ALL
				  SELECT    0,
							39,
							13
				  UNION ALL
				  SELECT    0,
							40,
							14
				  UNION ALL
				  SELECT    0,
							41,
							15
				  UNION ALL
				  SELECT    0,
							42,
							16
				  UNION ALL
				  SELECT    1,
							6,
							0
				  UNION ALL
				  SELECT    1,
							7,
							0
				  UNION ALL
				  SELECT    1,
							8,
							1
				  UNION ALL
				  SELECT    1,
							9,
							1
				  UNION ALL
				  SELECT    1,
							10,
							1
				  UNION ALL
				  SELECT    1,
							11,
							1
				  UNION ALL
				  SELECT    1,
							12,
							2
				  UNION ALL
				  SELECT    1,
							13,
							2
				  UNION ALL
				  SELECT    1,
							14,
							2
				  UNION ALL
				  SELECT    1,
							15,
							2
				  UNION ALL
				  SELECT    1,
							16,
							3
				  UNION ALL
				  SELECT    1,
							17,
							3
				  UNION ALL
				  SELECT    1,
							18,
							3
				  UNION ALL
				  SELECT    1,
							19,
							3
				  UNION ALL
				  SELECT    1,
							20,
							4
				  UNION ALL
				  SELECT    1,
							21,
							4
				  UNION ALL
				  SELECT    1,
							22,
							4
				  UNION ALL
				  SELECT    1,
							23,
							4
				  UNION ALL
				  SELECT    1,
							24,
							5
				  UNION ALL
				  SELECT    1,
							25,
							5
				  UNION ALL
				  SELECT    1,
							26,
							5
				  UNION ALL
				  SELECT    1,
							27,
							5
				  UNION ALL
				  SELECT    1,
							28,
							6
				  UNION ALL
				  SELECT    1,
							29,
							6
				  UNION ALL
				  SELECT    1,
							30,
							7
				  UNION ALL
				  SELECT    1,
							31,
							7
				  UNION ALL
				  SELECT    1,
							32,
							8
				  UNION ALL
				  SELECT    1,
							33,
							8
				  UNION ALL
				  SELECT    1,
							34,
							9
				  UNION ALL
				  SELECT    1,
							35,
							9
				  UNION ALL
				  SELECT    1,
							36,
							10
				  UNION ALL
				  SELECT    1,
							37,
							11
				  UNION ALL
				  SELECT    1,
							38,
							12
				  UNION ALL
				  SELECT    1,
							39,
							13
				  UNION ALL
				  SELECT    1,
							40,
							14
				  UNION ALL
				  SELECT    1,
							41,
							15
				  UNION ALL
				  SELECT    1,
							42,
							16
				  UNION ALL
				  SELECT    2,
							6,
							0
				  UNION ALL
				  SELECT    2,
							7,
							0
				  UNION ALL
				  SELECT    2,
							8,
							0
				  UNION ALL
				  SELECT    2,
							9,
							0
				  UNION ALL
				  SELECT    2,
							10,
							0
				  UNION ALL
				  SELECT    2,
							11,
							0
				  UNION ALL
				  SELECT    2,
							12,
							1
				  UNION ALL
				  SELECT    2,
							13,
							1
				  UNION ALL
				  SELECT    2,
							14,
							1
				  UNION ALL
				  SELECT    2,
							15,
							1
				  UNION ALL
				  SELECT    2,
							16,
							2
				  UNION ALL
				  SELECT    2,
							17,
							2
				  UNION ALL
				  SELECT    2,
							18,
							2
				  UNION ALL
				  SELECT    2,
							19,
							2
				  UNION ALL
				  SELECT    2,
							20,
							3
				  UNION ALL
				  SELECT    2,
							21,
							3
				  UNION ALL
				  SELECT    2,
							22,
							3
				  UNION ALL
				  SELECT    2,
							23,
							3
				  UNION ALL
				  SELECT    2,
							24,
							4
				  UNION ALL
				  SELECT    2,
							25,
							4
				  UNION ALL
				  SELECT    2,
							26,
							4
				  UNION ALL
				  SELECT    2,
							27,
							4
				  UNION ALL
				  SELECT    2,
							28,
							5
				  UNION ALL
				  SELECT    2,
							29,
							5
				  UNION ALL
				  SELECT    2,
							30,
							6
				  UNION ALL
				  SELECT    2,
							31,
							6
				  UNION ALL
				  SELECT    2,
							32,
							7
				  UNION ALL
				  SELECT    2,
							33,
							7
				  UNION ALL
				  SELECT    2,
							34,
							8
				  UNION ALL
				  SELECT    2,
							35,
							8
				  UNION ALL
				  SELECT    2,
							36,
							9
				  UNION ALL
				  SELECT    2,
							37,
							10
				  UNION ALL
				  SELECT    2,
							38,
							11
				  UNION ALL
				  SELECT    2,
							39,
							12
				  UNION ALL
				  SELECT    2,
							40,
							13
				  UNION ALL
				  SELECT    2,
							41,
							14
				  UNION ALL
				  SELECT    2,
							42,
							15
				  UNION ALL
				  SELECT    3,
							6,
							0
				  UNION ALL
				  SELECT    3,
							7,
							0
				  UNION ALL
				  SELECT    3,
							8,
							0
				  UNION ALL
				  SELECT    3,
							9,
							0
				  UNION ALL
				  SELECT    3,
							10,
							0
				  UNION ALL
				  SELECT    3,
							11,
							0
				  UNION ALL
				  SELECT    3,
							12,
							0
				  UNION ALL
				  SELECT    3,
							13,
							0
				  UNION ALL
				  SELECT    3,
							14,
							0
				  UNION ALL
				  SELECT    3,
							15,
							0
				  UNION ALL
				  SELECT    3,
							16,
							1
				  UNION ALL
				  SELECT    3,
							17,
							1
				  UNION ALL
				  SELECT    3,
							18,
							1
				  UNION ALL
				  SELECT    3,
							19,
							1
				  UNION ALL
				  SELECT    3,
							20,
							2
				  UNION ALL
				  SELECT    3,
							21,
							2
				  UNION ALL
				  SELECT    3,
							22,
							2
				  UNION ALL
				  SELECT    3,
							23,
							2
				  UNION ALL
				  SELECT    3,
							24,
							3
				  UNION ALL
				  SELECT    3,
							25,
							3
				  UNION ALL
				  SELECT    3,
							26,
							3
				  UNION ALL
				  SELECT    3,
							27,
							3
				  UNION ALL
				  SELECT    3,
							28,
							4
				  UNION ALL
				  SELECT    3,
							29,
							4
				  UNION ALL
				  SELECT    3,
							30,
							5
				  UNION ALL
				  SELECT    3,
							31,
							5
				  UNION ALL
				  SELECT    3,
							32,
							6
				  UNION ALL
				  SELECT    3,
							33,
							6
				  UNION ALL
				  SELECT    3,
							34,
							7
				  UNION ALL
				  SELECT    3,
							35,
							7
				  UNION ALL
				  SELECT    3,
							36,
							8
				  UNION ALL
				  SELECT    3,
							37,
							9
				  UNION ALL
				  SELECT    3,
							38,
							10
				  UNION ALL
				  SELECT    3,
							39,
							11
				  UNION ALL
				  SELECT    3,
							40,
							12
				  UNION ALL
				  SELECT    3,
							41,
							13
				  UNION ALL
				  SELECT    3,
							42,
							14
				  UNION ALL
				  SELECT    4,
							6,
							0
				  UNION ALL
				  SELECT    4,
							7,
							0
				  UNION ALL
				  SELECT    4,
							8,
							0
				  UNION ALL
				  SELECT    4,
							9,
							0
				  UNION ALL
				  SELECT    4,
							10,
							0
				  UNION ALL
				  SELECT    4,
							11,
							0
				  UNION ALL
				  SELECT    4,
							12,
							0
				  UNION ALL
				  SELECT    4,
							13,
							0
				  UNION ALL
				  SELECT    4,
							14,
							0
				  UNION ALL
				  SELECT    4,
							15,
							0
				  UNION ALL
				  SELECT    4,
							16,
							0
				  UNION ALL
				  SELECT    4,
							17,
							0
				  UNION ALL
				  SELECT    4,
							18,
							0
				  UNION ALL
				  SELECT    4,
							19,
							0
				  UNION ALL
				  SELECT    4,
							20,
							1
				  UNION ALL
				  SELECT    4,
							21,
							1
				  UNION ALL
				  SELECT    4,
							22,
							1
				  UNION ALL
				  SELECT    4,
							23,
							1
				  UNION ALL
				  SELECT    4,
							24,
							2
				  UNION ALL
				  SELECT    4,
							25,
							2
				  UNION ALL
				  SELECT    4,
							26,
							2
				  UNION ALL
				  SELECT    4,
							27,
							2
				  UNION ALL
				  SELECT    4,
							28,
							3
				  UNION ALL
				  SELECT    4,
							29,
							3
				  UNION ALL
				  SELECT    4,
							30,
							4
				  UNION ALL
				  SELECT    4,
							31,
							4
				  UNION ALL
				  SELECT    4,
							32,
							5
				  UNION ALL
				  SELECT    4,
							33,
							5
				  UNION ALL
				  SELECT    4,
							34,
							6
				  UNION ALL
				  SELECT    4,
							35,
							6
				  UNION ALL
				  SELECT    4,
							36,
							7
				  UNION ALL
				  SELECT    4,
							37,
							8
				  UNION ALL
				  SELECT    4,
							38,
							9
				  UNION ALL
				  SELECT    4,
							39,
							10
				  UNION ALL
				  SELECT    4,
							40,
							11
				  UNION ALL
				  SELECT    4,
							41,
							12
				  UNION ALL
				  SELECT    4,
							42,
							13
				  UNION ALL
				  SELECT    5,
							6,
							0
				  UNION ALL
				  SELECT    5,
							7,
							0
				  UNION ALL
				  SELECT    5,
							8,
							0
				  UNION ALL
				  SELECT    5,
							9,
							0
				  UNION ALL
				  SELECT    5,
							10,
							0
				  UNION ALL
				  SELECT    5,
							11,
							0
				  UNION ALL
				  SELECT    5,
							12,
							0
				  UNION ALL
				  SELECT    5,
							13,
							0
				  UNION ALL
				  SELECT    5,
							14,
							0
				  UNION ALL
				  SELECT    5,
							15,
							0
				  UNION ALL
				  SELECT    5,
							16,
							0
				  UNION ALL
				  SELECT    5,
							17,
							0
				  UNION ALL
				  SELECT    5,
							18,
							0
				  UNION ALL
				  SELECT    5,
							19,
							0
				  UNION ALL
				  SELECT    5,
							20,
							0
				  UNION ALL
				  SELECT    5,
							21,
							0
				  UNION ALL
				  SELECT    5,
							22,
							0
				  UNION ALL
				  SELECT    5,
							23,
							0
				  UNION ALL
				  SELECT    5,
							24,
							1
				  UNION ALL
				  SELECT    5,
							25,
							1
				  UNION ALL
				  SELECT    5,
							26,
							1
				  UNION ALL
				  SELECT    5,
							27,
							1
				  UNION ALL
				  SELECT    5,
							28,
							1
				  UNION ALL
				  SELECT    5,
							29,
							1
				  UNION ALL
				  SELECT    5,
							30,
							2
				  UNION ALL
				  SELECT    5,
							31,
							2
				  UNION ALL
				  SELECT    5,
							32,
							3
				  UNION ALL
				  SELECT    5,
							33,
							3
				  UNION ALL
				  SELECT    5,
							34,
							4
				  UNION ALL
				  SELECT    5,
							35,
							4
				  UNION ALL
				  SELECT    5,
							36,
							5
				  UNION ALL
				  SELECT    5,
							37,
							6
				  UNION ALL
				  SELECT    5,
							38,
							7
				  UNION ALL
				  SELECT    5,
							39,
							8
				  UNION ALL
				  SELECT    5,
							40,
							9
				  UNION ALL
				  SELECT    5,
							41,
							10
				  UNION ALL
				  SELECT    5,
							42,
							11
				  UNION ALL
				  SELECT    6,
							6,
							0
				  UNION ALL
				  SELECT    6,
							7,
							0
				  UNION ALL
				  SELECT    6,
							8,
							0
				  UNION ALL
				  SELECT    6,
							9,
							0
				  UNION ALL
				  SELECT    6,
							10,
							0
				  UNION ALL
				  SELECT    6,
							11,
							0
				  UNION ALL
				  SELECT    6,
							12,
							0
				  UNION ALL
				  SELECT    6,
							13,
							0
				  UNION ALL
				  SELECT    6,
							14,
							0
				  UNION ALL
				  SELECT    6,
							15,
							0
				  UNION ALL
				  SELECT    6,
							16,
							0
				  UNION ALL
				  SELECT    6,
							17,
							0
				  UNION ALL
				  SELECT    6,
							18,
							0
				  UNION ALL
				  SELECT    6,
							19,
							0
				  UNION ALL
				  SELECT    6,
							20,
							0
				  UNION ALL
				  SELECT    6,
							21,
							0
				  UNION ALL
				  SELECT    6,
							22,
							0
				  UNION ALL
				  SELECT    6,
							23,
							0
				  UNION ALL
				  SELECT    6,
							24,
							0
				  UNION ALL
				  SELECT    6,
							25,
							0
				  UNION ALL
				  SELECT    6,
							26,
							0
				  UNION ALL
				  SELECT    6,
							27,
							0
				  UNION ALL
				  SELECT    6,
							28,
							1
				  UNION ALL
				  SELECT    6,
							29,
							1
				  UNION ALL
				  SELECT    6,
							30,
							1
				  UNION ALL
				  SELECT    6,
							31,
							1
				  UNION ALL
				  SELECT    6,
							32,
							2
				  UNION ALL
				  SELECT    6,
							33,
							2
				  UNION ALL
				  SELECT    6,
							34,
							3
				  UNION ALL
				  SELECT    6,
							35,
							3
				  UNION ALL
				  SELECT    6,
							36,
							4
				  UNION ALL
				  SELECT    6,
							37,
							5
				  UNION ALL
				  SELECT    6,
							38,
							6
				  UNION ALL
				  SELECT    6,
							39,
							7
				  UNION ALL
				  SELECT    6,
							40,
							8
				  UNION ALL
				  SELECT    6,
							41,
							9
				  UNION ALL
				  SELECT    6,
							42,
							10
				  UNION ALL
				  SELECT    7,
							6,
							0
				  UNION ALL
				  SELECT    7,
							7,
							0
				  UNION ALL
				  SELECT    7,
							8,
							0
				  UNION ALL
				  SELECT    7,
							9,
							0
				  UNION ALL
				  SELECT    7,
							10,
							0
				  UNION ALL
				  SELECT    7,
							11,
							0
				  UNION ALL
				  SELECT    7,
							12,
							0
				  UNION ALL
				  SELECT    7,
							13,
							0
				  UNION ALL
				  SELECT    7,
							14,
							0
				  UNION ALL
				  SELECT    7,
							15,
							0
				  UNION ALL
				  SELECT    7,
							16,
							0
				  UNION ALL
				  SELECT    7,
							17,
							0
				  UNION ALL
				  SELECT    7,
							18,
							0
				  UNION ALL
				  SELECT    7,
							19,
							0
				  UNION ALL
				  SELECT    7,
							20,
							0
				  UNION ALL
				  SELECT    7,
							21,
							0
				  UNION ALL
				  SELECT    7,
							22,
							0
				  UNION ALL
				  SELECT    7,
							23,
							0
				  UNION ALL
				  SELECT    7,
							24,
							0
				  UNION ALL
				  SELECT    7,
							25,
							0
				  UNION ALL
				  SELECT    7,
							26,
							0
				  UNION ALL
				  SELECT    7,
							27,
							0
				  UNION ALL
				  SELECT    7,
							28,
							0
				  UNION ALL
				  SELECT    7,
							29,
							0
				  UNION ALL
				  SELECT    7,
							30,
							1
				  UNION ALL
				  SELECT    7,
							31,
							1
				  UNION ALL
				  SELECT    7,
							32,
							1
				  UNION ALL
				  SELECT    7,
							33,
							1
				  UNION ALL
				  SELECT    7,
							34,
							2
				  UNION ALL
				  SELECT    7,
							35,
							2
				  UNION ALL
				  SELECT    7,
							36,
							3
				  UNION ALL
				  SELECT    7,
							37,
							4
				  UNION ALL
				  SELECT    7,
							38,
							5
				  UNION ALL
				  SELECT    7,
							39,
							6
				  UNION ALL
				  SELECT    7,
							40,
							7
				  UNION ALL
				  SELECT    7,
							41,
							8
				  UNION ALL
				  SELECT    7,
							42,
							9
				  UNION ALL
				  SELECT    8,
							6,
							0
				  UNION ALL
				  SELECT    8,
							7,
							0
				  UNION ALL
				  SELECT    8,
							8,
							0
				  UNION ALL
				  SELECT    8,
							9,
							0
				  UNION ALL
				  SELECT    8,
							10,
							0
				  UNION ALL
				  SELECT    8,
							11,
							0
				  UNION ALL
				  SELECT    8,
							12,
							0
				  UNION ALL
				  SELECT    8,
							13,
							0
				  UNION ALL
				  SELECT    8,
							14,
							0
				  UNION ALL
				  SELECT    8,
							15,
							0
				  UNION ALL
				  SELECT    8,
							16,
							0
				  UNION ALL
				  SELECT    8,
							17,
							0
				  UNION ALL
				  SELECT    8,
							18,
							0
				  UNION ALL
				  SELECT    8,
							19,
							0
				  UNION ALL
				  SELECT    8,
							20,
							0
				  UNION ALL
				  SELECT    8,
							21,
							0
				  UNION ALL
				  SELECT    8,
							22,
							0
				  UNION ALL
				  SELECT    8,
							23,
							0
				  UNION ALL
				  SELECT    8,
							24,
							0
				  UNION ALL
				  SELECT    8,
							25,
							0
				  UNION ALL
				  SELECT    8,
							26,
							0
				  UNION ALL
				  SELECT    8,
							27,
							0
				  UNION ALL
				  SELECT    8,
							28,
							0
				  UNION ALL
				  SELECT    8,
							29,
							0
				  UNION ALL
				  SELECT    8,
							30,
							0
				  UNION ALL
				  SELECT    8,
							31,
							0
				  UNION ALL
				  SELECT    8,
							32,
							0
				  UNION ALL
				  SELECT    8,
							33,
							0
				  UNION ALL
				  SELECT    8,
							34,
							1
				  UNION ALL
				  SELECT    8,
							35,
							1
				  UNION ALL
				  SELECT    8,
							36,
							1
				  UNION ALL
				  SELECT    8,
							37,
							2
				  UNION ALL
				  SELECT    8,
							38,
							3
				  UNION ALL
				  SELECT    8,
							39,
							4
				  UNION ALL
				  SELECT    8,
							40,
							5
				  UNION ALL
				  SELECT    8,
							41,
							6
				  UNION ALL
				  SELECT    8,
							42,
							7
				  UNION ALL
				  SELECT    9,
							6,
							0
				  UNION ALL
				  SELECT    9,
							7,
							0
				  UNION ALL
				  SELECT    9,
							8,
							0
				  UNION ALL
				  SELECT    9,
							9,
							0
				  UNION ALL
				  SELECT    9,
							10,
							0
				  UNION ALL
				  SELECT    9,
							11,
							0
				  UNION ALL
				  SELECT    9,
							12,
							0
				  UNION ALL
				  SELECT    9,
							13,
							0
				  UNION ALL
				  SELECT    9,
							14,
							0
				  UNION ALL
				  SELECT    9,
							15,
							0
				  UNION ALL
				  SELECT    9,
							16,
							0
				  UNION ALL
				  SELECT    9,
							17,
							0
				  UNION ALL
				  SELECT    9,
							18,
							0
				  UNION ALL
				  SELECT    9,
							19,
							0
				  UNION ALL
				  SELECT    9,
							20,
							0
				  UNION ALL
				  SELECT    9,
							21,
							0
				  UNION ALL
				  SELECT    9,
							22,
							0
				  UNION ALL
				  SELECT    9,
							23,
							0
				  UNION ALL
				  SELECT    9,
							24,
							0
				  UNION ALL
				  SELECT    9,
							25,
							0
				  UNION ALL
				  SELECT    9,
							26,
							0
				  UNION ALL
				  SELECT    9,
							27,
							0
				  UNION ALL
				  SELECT    9,
							28,
							0
				  UNION ALL
				  SELECT    9,
							29,
							0
				  UNION ALL
				  SELECT    9,
							30,
							0
				  UNION ALL
				  SELECT    9,
							31,
							0
				  UNION ALL
				  SELECT    9,
							32,
							0
				  UNION ALL
				  SELECT    9,
							33,
							0
				  UNION ALL
				  SELECT    9,
							34,
							0
				  UNION ALL
				  SELECT    9,
							35,
							0
				  UNION ALL
				  SELECT    9,
							36,
							0
				  UNION ALL
				  SELECT    9,
							37,
							0
				  UNION ALL
				  SELECT    9,
							38,
							0
				  UNION ALL
				  SELECT    9,
							39,
							1
				  UNION ALL
				  SELECT    9,
							40,
							1
				  UNION ALL
				  SELECT    9,
							41,
							2
				  UNION ALL
				  SELECT    9,
							42,
							3
				 ),
			PseudoTallyBase1(N)
			  AS (SELECT    1
				  UNION ALL
				  SELECT    1
				 ),
			PseudoTallyBase2(N)
			  AS (SELECT    1
				  FROM      PseudoTallyBase1 AS t1,
							PseudoTallyBase1 AS t2,
							PseudoTallyBase1 AS t3,
							PseudoTallyBase1 AS t4
				 ),
			PseudoTally(N)
			  AS (SELECT    ROW_NUMBER() OVER (ORDER BY (SELECT NULL
														))
				  FROM      PseudoTallyBase2 AS t1,
							PseudoTallyBase2 AS t2,
							PseudoTallyBase2 AS t3,
							PseudoTallyBase2 AS t4
				 )
		INSERT INTO @FPCKey
		SELECT DISTINCT
				EnrollMonths,
				GestWeeks,
				CountExpected
		FROM    FPCKey
		UNION
		SELECT DISTINCT
				EnrollMonths,
				GestWeeks + N AS GestWeeks,
				CountExpected + N AS CountExpected
		FROM    FPCKey AS FPC
				INNER JOIN PseudoTally AS t ON t.N BETWEEN 1 AND 10
		WHERE   GestWeeks = 42;

	WITH    FPCBase
			  AS (SELECT    MMS.MemberMeasureSampleID,
							MMS.MemberID,
							MMS.MeasureID,
							MMS.EventDate,
							ISNULL(GA.DeliveryDate, MMS.PPCDeliveryDate) AS DeliveryDate,
							CONVERT(int, COALESCE(GA.GestDays,
												  MMS.PPCGestationalDays, 280)) AS GestDays,
							COALESCE(MMS.PPCLastEnrollSegStartDate,
									 MMS.PPCPrenatalCareStartDate, GA.DeliveryDate,
									 MMS.PPCDeliveryDate) AS LastSegBeginDate,
							MMS.PPCDeliveryDate AS AdminDeliveryDate,
							GA.DeliveryDate AS MRDeliveryDate
				  FROM      dbo.MemberMeasureSample AS MMS
							OUTER APPLY (SELECT NULLIF(MIN(tGA.DeliveryDate), CONVERT(datetime, 0)) AS DeliveryDate,
												NULLIF(MAX(COALESCE(tGA.CalculatedEDD,
																  tGA.GestationalAge,
																  0) * 7), 0) AS GestDays
										 FROM   dbo.MedicalRecordFPCGA AS tGA
												INNER JOIN dbo.PursuitEvent AS tRV ON tGA.PursuitEventID = tRV.PursuitEventID
												INNER JOIN dbo.Pursuit AS tR ON tRV.PursuitID = tR.PursuitID
										 WHERE  tR.MemberID = MMS.MemberID AND
												tRV.MeasureID = MMS.MeasureID AND                                   
												tRV.EventDate = MMS.EventDate AND
												(                                          
													(tGA.DeliveryDate BETWEEN DATEADD(dd,
																	  (@PPCDeliveryDateMatchingWindow *
																	  -1),
																	  MMS.PPCDeliveryDate)
																	 AND
																	  DATEADD(dd,
																	  @PPCDeliveryDateMatchingWindow,
																	  MMS.PPCDeliveryDate)) OR
													(tGA.DeliveryDate IS NULL) OR
													(tGA.DeliveryDate = CONVERT(datetime, 0))                                              
												)                                                                
										) AS GA
				  WHERE     (MMS.MeasureID = @MeasureID) AND
							((@MemberID IS NULL) OR (MMS.MemberID = @MemberID))
				 )
		INSERT INTO @Results
		SELECT  MemberMeasureSampleID,
				MemberID,
				MeasureID,
				EventDate,
				CONVERT(int, NULL) AS CountExpected,
				DeliveryDate,
				AdminDeliveryDate,
				MRDeliveryDate,
				GestDays,
				FLOOR(CONVERT(decimal(18, 6), GestDays) / 7) AS GestWeeks,
				DATEADD(dd, (GestDays * -1), DeliveryDate) AS GestStartDate,
				LastSegBeginDate,
				DATEDIFF(dd, DATEADD(dd, (GestDays * -1), DeliveryDate),
						 LastSegBeginDate) AS EnrollDays,
				ROUND(CONVERT(decimal(18, 6), DATEDIFF(dd,
													   DATEADD(dd, (GestDays * -1),
															   DeliveryDate),
													   LastSegBeginDate)) / 30, 0) AS EnrollMonths
		FROM    FPCBase;

		UPDATE @Results SET EnrollDays = 0, EnrollMonths = 0 WHERE EnrollDays < 0;

		UPDATE  FPC
		SET     CountExpected = K.CountExpected
		FROM    @Results AS FPC
				INNER JOIN @FPCKey AS K ON FPC.GestWeeks = K.GestWeeks AND
										   FPC.EnrollMonths = K.EnrollMonths; 

		RETURN;
END

GO
