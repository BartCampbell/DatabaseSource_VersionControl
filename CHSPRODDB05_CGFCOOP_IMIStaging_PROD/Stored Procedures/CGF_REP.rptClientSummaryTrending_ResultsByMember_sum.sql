SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[rptClientSummaryTrending_ResultsByMember_sum] 
@client VARCHAR(100) = NULL,
@endseeddate DATETIME = NULL
AS

if @client is null 
	select @Client = max(Client) from cgf.ResultsByMember_sum

IF @endseeddate IS NULL
	SELECT @endseeddate = MAX(endseeddate) 
		FROM CGF.ResultsByMember_sum 
		WHERE IsDenominator = 1
			AND client = @Client



insert into cgf_rep.ReportVariableLog
	(RunDate ,
	ProcName ,
	Var1Name ,
	Var1Val ,
	Var2Name,
	Var2Val )
SELECT RunDate = GETDATE(),
	ProcName = OBJECT_NAME( @@PROCID),
	Var1Name = '@Client',
	Var1Val = @client,
	Var2Name = '@endseeddate',
	Var2Val = @endseeddate

--SELECT @client = 'DHMP', @endseeddate = MAX(EndSeedDate) FROM CGF.ResultsByMember_Sum rbm

SELECT 
		rbm.client,
		rbm.EndSeedDate,
		rbm.MeasureSet,
		rbm.Measure,
		rbm.MeasureDesc,
		rbm.MeasureMetricDesc,
		rbm.IsNumerator ,
		rbm.IsDenominator,
		ComplianceRate = CONVERT(NUMERIC(11,3),rbm.ComplianceRate),
		PrevMonthComplianceRate = (SELECT CONVERT(NUMERIC(11,3),a.ComplianceRate)
									FROM CGF.ResultsByMember_Sum a
											WHERE  a.Client = rbm.Client
												AND a.MeasureMetricDesc = rbm.MeasureMetricDesc
												AND a.EndSeedDate  =  DATEADD(day,-1,DATEADD(month,-1,DATEADD(DAY,1,rbm.EndSeedDate)))
									) , 
		PrevMonth_6mthAvg = (SELECT CONVERT(NUMERIC(11,3),AVG(a.ComplianceRate))
								FROM CGF.ResultsByMember_Sum a
										WHERE  a.Client = rbm.Client
											AND a.MeasureMetricDesc = rbm.MeasureMetricDesc
											AND a.EndSeedDate BETWEEN DATEADD(day,-1,DATEADD(month,-7,DATEADD(DAY,1,rbm.EndSeedDate)))
																AND DATEADD(day,-1,DATEADD(month,-1,DATEADD(DAY,1,rbm.EndSeedDate)))
								),
		CurrMonth_6mthAvg = (SELECT CONVERT(NUMERIC(11,3),AVG(a.ComplianceRate))
								FROM CGF.ResultsByMember_Sum a
										WHERE  a.Client = rbm.Client
											AND a.MeasureMetricDesc = rbm.MeasureMetricDesc
											AND a.EndSeedDate BETWEEN DATEADD(day,-1,DATEADD(month,-6,DATEADD(DAY,1,rbm.EndSeedDate)))
																AND rbm.EndSeedDate
								)
	FROM CGF.ResultsByMember_Sum rbm
	WHERE rbm.Client = @client
		AND rbm.EndSeedDate = @endseeddate
	ORDER BY rbm.MeasureMetricDesc
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[rptClientSummaryTrending_ResultsByMember_sum] TO [db_ViewProcedures]
GO
