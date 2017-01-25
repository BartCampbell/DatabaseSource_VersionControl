SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	Exchange Membership
Author:		Ivette Villalobos
Copyright:	© 2014
Date:		02/07/2014
Purpose:	
Parameters:	
Depends On:	
Calls:		
Called By:	
Returns:	
Notes:		
Process:	
Test Script:
	
-- Create extract tables
--EXEC repExchangeMembership '4/1/2014','4/30/2014'  --change date when needed

SELECT * FROM FileExtr.ExchangeMembership where 'Member ID' = '00880034900'

ToDo:		
*************************************************************************************/

CREATE PROCEDURE [dbo].[repExchangeMembership]
    (@p_startDate DATE,
     @p_endDate DATE
    )--create parameters
AS

BEGIN

    --DECLARE @p_startDate DATE = '4/1/2014'
    --DECLARE @p_endDate DATE = '4/30/2014'

    DECLARE @BeginDate VARCHAR(8)
    DECLARE @EndDate VARCHAR(8)

    SET @BeginDate = CONVERT(VARCHAR(8), @p_startDate, 112)--call parameter
    SET @EndDate = CONVERT(VARCHAR(8), @p_endDate, 112)--call parameter

    IF OBJECT_ID('TEMPDB..#ins_id') IS NOT NULL
        DROP TABLE #ins_id
 
    SELECT DISTINCT ek.insuredid,
            m.memid,
            m.entityid,
            e.entid,
            e.lastname,
            e.firstname,
            e.middlename,
			ek.carriermemid
        INTO #ins_id
        FROM [PlanData_PROD].dbo.member m WITH (NOLOCK)
            JOIN [PlanData_PROD].dbo.enrollkeys ek WITH (NOLOCK)
                ON m.memid = ek.memid
            JOIN [PlanData_PROD].dbo.entity e WITH (NOLOCK)
                ON m.entityid = e.entid
        WHERE ek.insuredid = m.memid

    IF OBJECT_ID('FileExtr.ExchangeMembership') IS NOT NULL
        DROP TABLE FileExtr.ExchangeMembership

    SELECT  MemberID = RTRIM(ek.carriermemid),
            SecondaryID = RTRIM(m.secondaryid) ,
            QNXTID = RTRIM(m.memid ),
            SubscriberFirstName = RTRIM(id.firstname) ,
            SubscriberLastName = RTRIM(id.lastname ),
            SubscriberMiddleName = RTRIM(id.middlename ),
			SubscriberMemberID = RTRIM(id.carriermemid),
			SubscriberFullName = RTRIM(id.LastName) + ', ' + rTRIM(id.FirstName),
            ARAccountID = ISNULL(ar.araccountid, '') ,
            ARAccountStatus = ISNULL(ar.status, '') ,
            LastName = RTRIM(e.lastname ),
            FirstName = RTRIM(e.firstname ),
            FullName = RTRIM(e.lastname ) + ', ' + RTRIM(e.firstname ),
			Address1 = RTRIM(e.addr1),
            Address2 = RTRIM(e.addr2) ,
            City = RTRIM(e.city) ,
            State = RTRIM(e.state) ,
            Zip = e.zip ,
			CityStateZip = RTRIM(e.city) + ', ' + RTRIM(e.state)+ ' ' + RTRIM(e.zip),
            County = e.county ,
            Phone = e.phone ,
            EmergencyPhone = e.emerphone ,
            Sex = m.sex ,
            DOB = CONVERT(DATE, m.dob) ,
            RateDescription = r.description ,
            RateCode = ek.ratecode ,
            EffDate = CONVERT(DATE, ec.effdate) ,
            TermDate = CONVERT (DATE, ec.termdate) ,
            InvoiceID = ai.arinvoiceid ,
            SubsidyAmt = ISNULL(ms.amount, 0.00) ,
            SubscriberAmt = ISNULL(pid.premiumamt, 0.00) ,
            PremiumAmt = pisda.posspremiumamt ,
            Broker = (CASE WHEN ma.attributeid = 'MSC000000136   '
							   AND ma.thevalue = 'ZZZDenverHealthMedic ZZZSalesTeam'
						  THEN 'Denver Health'
						  WHEN ma.attributeid = 'MSC000000136   '
							   AND ma.thevalue = 'ZZZZ4C4Connect C ZZZZC4SalesTeam'
						  THEN 'C4 Connect'
						  WHEN ma.attributeid = 'MSC000000136   '
							   AND ma.thevalue NOT IN (
							   'ZZZDenverHealthMedic ZZZSalesTeam',
							   'ZZZZ4C4Connect C ZZZZC4SalesTeam') THEN ma.thevalue
						  ELSE 'No Broker'
						 END) 
        --INTO FileExtr.ExchangeMembership
        FROM [PlanData_PROD].dbo.member m WITH (NOLOCK)
            JOIN [PlanData_PROD].dbo.enrollkeys ek WITH (NOLOCK)
                ON m.memid = ek.memid
            JOIN [PlanData_PROD].dbo.enrollcoverage ec WITH (NOLOCK)
                ON ec.enrollid = ek.enrollid
            JOIN [PlanData_PROD].dbo.ratesuffix r WITH (NOLOCK)
                ON ek.rateid = r.rateid
                AND ek.ratecode = r.ratecode
            JOIN [PlanData_PROD].dbo.entity e WITH (NOLOCK)
                ON m.entityid = e.entid
            LEFT JOIN #ins_id id
                ON id.insuredid = ek.insuredid
            LEFT JOIN [PlanData_PROD].dbo.premiuminvoicesubdetailadj pisda WITH (NOLOCK)
                ON ek.enrollid = pisda.enrollid
                AND pisda.periodstart = @BeginDate
            LEFT JOIN (SELECT EnrollID,
								BilledStart, 
								PremiumAmt = SUM(ISNULL(pid.premiumamt, 0))
							FROM [PlanData_PROD].dbo.premiuminvoicedetail pid WITH (NOLOCK)
							GROUP BY EnrollID,
								BilledStart) pid
                ON pid.enrollid = pisda.enrollid
                AND pid.billedstart = pisda.periodstart
            LEFT JOIN [PlanData_PROD].dbo.membersubsidy ms WITH (NOLOCK)
                ON ms.memid = m.memid
                AND ms.subsidytype = 'APTC'
                AND ms.SubsidyCategory = 'Premium        '
            LEFT JOIN [PlanData_PROD].dbo.araccount ar WITH (NOLOCK)
                ON ar.memid = m.memid
            LEFT JOIN [PlanData_PROD].dbo.arinvoice ai WITH (NOLOCK)
                ON ar.araccountid = ai.araccountid
                AND ai.invoicedate = @BeginDate
            LEFT JOIN [PlanData_PROD].dbo.memberattribute ma WITH (NOLOCK)
                ON ma.memid = m.memid
                AND ma.attributeid = 'MSC000000136   '
        WHERE ec.termdate >= @BeginDate
            AND ec.effdate <= @EndDate
            AND e.enttype = 'MEMBER'
            AND ek.segtype = 'INT'
            AND pisda.posspremiumamt != 0
        ORDER BY 1

END

GO
GRANT VIEW DEFINITION ON  [dbo].[repExchangeMembership] TO [db_ViewProcedures]
GO
