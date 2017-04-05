SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[prLoadHedis]
	@cCurYearMonth	char( 8 ) = NULL,
	@cStartDate	char( 8 ) = NULL,
	@cEndDate	char( 8 ) = NULL,
	@cTestDeck	char( 10 )= NULL
AS

--	prLoadHedis '20071231', '20070101', '20071231', 'BCS_Sample'

-- Load the support tables
EXECUTE dbo.prLoadHedisSupport @cTestDeck 
print 'dw_hedis table loads complete: '+convert(varchar(50),getdate())

--truncate table utb_hedis_cont_enroll
--INSERT INTO utb_hedis_cont_enroll
EXEC usp_break_in_coverage  @cStartDate, @cEndDate

print 'utb_hedis_cont_enroll table load complete: '+convert(varchar(50),getdate())

-- Load measure tables if appropriate
--IF @cCurYearMonth IS NOT NULL
--BEGIN
--	EXECUTE dbo.prLoadHedisMeasureTables @cCurYearMonth, @cStartDate, @cEndDate
--END




GO
