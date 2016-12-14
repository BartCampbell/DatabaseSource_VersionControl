SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
--Update 09/20/2016 for WellCare PJ
--Update 09/29/2018 Adding Channel_PK and EDGEMemberID  /fixing CHASID update PJ
--Udpate 10/06/2016 adding in SuspectLoad tabel to avoid dupes PJ 
--Update 10/17/2016 adding iscentauri flag PJ
--Update 10/25/2016 adding ClientID and ProviderOfficeID PJ
--Update 12/09/2016 Update to iscentauri flag to use channel_pk for WellCare PJ
-- Description:	merges the stage to dim for advance Suspect 
 -- Usage:				  EXECUTE dbo.spAdvMergeSuspect
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeSuspect]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN

        TRUNCATE TABLE stage.SuspectLoad_ADV;
        INSERT  INTO stage.SuspectLoad_ADV
                ( [CentauriSuspectID] ,
                  [IsScanned] ,
                  [IsCNA] ,
                  [IsCoded] ,
                  [IsQA] ,
                  [Scanned_Date] ,
                  [CNA_Date] ,
                  [Coded_Date] ,
                  [QA_Date] ,
                  [IsDiagnosisCoded] ,
                  [IsNotesCoded] ,
                  [LastAccessed_Date] ,
                  [LastUpdated] ,
                  [dtCreated] ,
                  [IsInvoiced] ,
                  [MemberStatus] ,
                  [ProspectiveFormStatus] ,
                  [InvoiceRec_Date] ,
                  [ChartRec_FaxIn_Date] ,
                  [ChartRec_MailIn_Date] ,
                  [ChartRec_InComp_Date] ,
                  [IsHighPriority] ,
                  [IsInComp_Replied] ,
                  [ChaseID] ,
                  [ContractCode] ,
                  [REN_PROVIDER_SPECIALTY] ,
                  [ChartPriority] ,
                  [ChartRec_Date] ,
                  [InvoiceExt_Date] ,
                  [Channel_PK] ,
                  [EDGEMemberID]
                )
                SELECT  ps.[CentauriSuspectID] ,
                        ps.[IsScanned] ,
                        ps.[IsCNA] ,
                        ps.[IsCoded] ,
                        ps.[IsQA] ,
                        ps.[Scanned_Date] ,
                        ps.[CNA_Date] ,
                        ps.[Coded_Date] ,
                        ps.[QA_Date] ,
                        ps.[IsDiagnosisCoded] ,
                        ps.[IsNotesCoded] ,
                        ps.[LastAccessed_Date] ,
                        ps.[LastUpdated] ,
                        ps.[dtCreated] ,
                        ps.[IsInvoiced] ,
                        ps.[MemberStatus] ,
                        ps.[ProspectiveFormStatus] ,
                        ps.[InvoiceRec_Date] ,
                        ps.[ChartRec_FaxIn_Date] ,
                        ps.[ChartRec_MailIn_Date] ,
                        ps.[ChartRec_InComp_Date] ,
                        ps.[IsHighPriority] ,
                        ps.[IsInComp_Replied] ,
                        ps.[ChaseID] ,
                        ps.[ContractCode] ,
                        ps.[REN_PROVIDER_SPECIALTY] ,
                        ps.[ChartPriority] ,
                        ps.[ChartRec_Date] ,
                        ps.[InvoiceExt_Date] ,
                        ps.Channel_PK ,
                        ps.EDGEMemberID
                FROM    [stage].[Suspect_ADV] ps;

        UPDATE  stage.SuspectLoad_ADV
        SET     Scanned_UserID = su.[UserID]
        FROM    stage.SuspectLoad_ADV a
                INNER JOIN [stage].[Suspect_ADV] ps ON ps.CentauriSuspectID = a.CentauriSuspectID
                INNER JOIN dim.[User] su ON su.CentauriUserid = ps.Scanned_CentauriUserID;

        UPDATE  stage.SuspectLoad_ADV
        SET     CNA_UserID = cu.[UserID]
        FROM    stage.SuspectLoad_ADV a
                INNER JOIN [stage].[Suspect_ADV] ps ON ps.CentauriSuspectID = a.CentauriSuspectID
                INNER JOIN dim.[User] cu ON cu.CentauriUserid = ps.CNA_CentauriUserID;

        UPDATE  stage.SuspectLoad_ADV
        SET     Coded_UserID = du.[UserID]
        FROM    stage.SuspectLoad_ADV a
                INNER JOIN [stage].[Suspect_ADV] ps ON ps.CentauriSuspectID = a.CentauriSuspectID
                INNER JOIN dim.[User] du ON du.CentauriUserid = ps.Coded_CentauriUserID;

        UPDATE  stage.SuspectLoad_ADV
        SET     QA_UserID = qu.[UserID]
        FROM    stage.SuspectLoad_ADV a
                INNER JOIN [stage].[Suspect_ADV] ps ON ps.CentauriSuspectID = a.CentauriSuspectID
                INNER JOIN dim.[User] qu ON qu.CentauriUserID = ps.QA_CentauriUserID;

        UPDATE  stage.SuspectLoad_ADV
        SET     [ProjectID] = pj.[ProjectID]
        FROM    stage.SuspectLoad_ADV a
                INNER JOIN [stage].[Suspect_ADV] ps ON ps.CentauriSuspectID = a.CentauriSuspectID
                INNER JOIN [dim].[ADVProject] pj ON pj.CentauriProjectID = ps.CentauriProjectID;

        UPDATE  stage.SuspectLoad_ADV
        SET     [ProviderID] = po.[ProviderID]
        FROM    stage.SuspectLoad_ADV a
                INNER JOIN [stage].[Suspect_ADV] ps ON ps.CentauriSuspectID = a.CentauriSuspectID
                INNER JOIN [dim].[Provider] po ON po.CentauriProviderID = ps.CentauriProviderID;

        UPDATE  stage.SuspectLoad_ADV
        SET     [MemberID] = me.[MemberID]
        FROM    stage.SuspectLoad_ADV a
                INNER JOIN [stage].[Suspect_ADV] ps ON ps.CentauriSuspectID = a.CentauriSuspectID
                INNER JOIN [dim].[Member] me ON me.CentauriMemberID = ps.CentauriMemberID;

         UPDATE stage.SuspectLoad_ADV
        SET    ProviderOfficeID    = po.ProviderOfficeID
		 FROM    stage.SuspectLoad_ADV a
                INNER JOIN [stage].[Suspect_ADV] ps ON ps.CentauriSuspectID = a.CentauriSuspectID
                INNER JOIN [dim].[ProviderOffice] po ON po.CentauriProviderOfficeID = ps.CentauriProviderOfficeID AND po.CentauriProviderID = ps.CentauriProviderID;
		     
			 
         UPDATE stage.SuspectLoad_ADV
        SET    ClientID    = po.ClientID
		 FROM    stage.SuspectLoad_ADV a
                INNER JOIN [stage].[Suspect_ADV] ps ON ps.CentauriSuspectID = a.CentauriSuspectID
                INNER JOIN [dim].[Client] po ON po.CentauriClientID = ps.ClientID;
		     


        MERGE INTO fact.Suspect AS t
        USING
            ( SELECT    [CentauriSuspectID] ,
                        [ProjectID] ,
                        [ProviderID] ,
                        [MemberID] ,
                        [IsScanned] ,
                        [IsCNA] ,
                        [IsCoded] ,
                        [IsQA] ,
                        Scanned_UserID ,
                        CNA_UserID ,
                        Coded_UserID ,
                        QA_UserID ,
                        Scanned_Date ,
                        [CNA_Date] ,
                        [Coded_Date] ,
                        [QA_Date] ,
                        [IsDiagnosisCoded] ,
                        [IsNotesCoded] ,
                        [LastAccessed_Date] ,
                        [LastUpdated] ,
                        [dtCreated] ,
                        [IsInvoiced] ,
                        [MemberStatus] ,
                        [ProspectiveFormStatus] ,
                        [InvoiceRec_Date] ,
                        [ChartRec_FaxIn_Date] ,
                        [ChartRec_MailIn_Date] ,
                        [ChartRec_InComp_Date] ,
                        [IsHighPriority] ,
                        [IsInComp_Replied] ,
                        [ChaseID] ,
                        [ContractCode] ,
                        [REN_PROVIDER_SPECIALTY] ,
                        [ChartPriority] ,
                        [ChartRec_Date] ,
                        [InvoiceExt_Date] ,
                        Channel_PK ,
                        EDGEMemberID,
						ProviderOfficeID,
						ClientID
              FROM      stage.SuspectLoad_ADV
            ) AS s
        ON t.CentauriSuspectID = s.CentauriSuspectID
        WHEN MATCHED AND ( ISNULL(t.[ProjectID], 0) <> ISNULL(s.[ProjectID], 0)
                           OR ISNULL(t.[ProviderID], 0) <> ISNULL(s.[ProviderID], 0)
						   OR ISNULL(t.[ProviderOfficeID], 0) <> ISNULL(s.[ProviderOfficeID], 0)
                           OR ISNULL(t.[MemberID], 0) <> ISNULL(s.[MemberID], 0)
                           OR ISNULL(t.[IsScanned], 0) <> ISNULL(s.[IsScanned], 0)
                           OR ISNULL(t.[IsCNA], 0) <> ISNULL(s.[IsCNA], 0)
                           OR ISNULL(t.[IsCoded], 0) <> ISNULL(s.[IsCoded], 0)
                           OR ISNULL(t.[IsQA], 0) <> ISNULL(s.[IsQA], 0)
                           OR ISNULL(t.[Scanned_UserID], 0) <> ISNULL(s.[Scanned_UserID], 0)
                           OR ISNULL(t.[CNA_UserID], 0) <> ISNULL(s.[CNA_UserID], 0)
                           OR ISNULL(t.[Coded_UserID], 0) <> ISNULL(s.[Coded_UserID], 0)
                           OR ISNULL(t.[QA_UserID], 0) <> ISNULL(s.[QA_UserID], 0)
                           OR ISNULL(t.[Scanned_Date], '') <> ISNULL(s.[Scanned_Date], '')
                           OR ISNULL(t.[CNA_Date], '') <> ISNULL(s.[CNA_Date], '')
                           OR ISNULL(t.[Coded_Date], '') <> ISNULL(s.[Coded_Date], '')
                           OR ISNULL(t.[QA_Date], '') <> ISNULL(s.[QA_Date], '')
                           OR ISNULL(t.[IsDiagnosisCoded], 0) <> ISNULL(s.[IsDiagnosisCoded], 0)
                           OR ISNULL(t.[IsNotesCoded], 0) <> ISNULL(s.[IsNotesCoded], 0)
                           OR ISNULL(t.[LastAccessed_Date], '') <> ISNULL(s.[LastAccessed_Date], '')
                           OR ISNULL(t.[LastUpdated], '') <> ISNULL(s.[LastUpdated], '')
                           OR ISNULL(t.[dtCreated], '') <> ISNULL(s.[dtCreated], '')
                           OR ISNULL(t.[IsInvoiced], 0) <> ISNULL(s.[IsInvoiced], 0)
                           OR ISNULL(t.[MemberStatus], 0) <> ISNULL(s.[MemberStatus], 0)
                           OR ISNULL(t.[ProspectiveFormStatus], 0) <> ISNULL(s.[ProspectiveFormStatus], 0)
                           OR ISNULL(t.[InvoiceRec_Date], '') <> ISNULL(s.[InvoiceRec_Date], '')
                           OR ISNULL(t.[ChartRec_FaxIn_Date], '') <> ISNULL(s.[ChartRec_FaxIn_Date], '')
                           OR ISNULL(t.[ChartRec_MailIn_Date], '') <> ISNULL(s.[ChartRec_MailIn_Date], '')
                           OR ISNULL(t.[ChartRec_InComp_Date], '') <> ISNULL(s.[ChartRec_InComp_Date], '')
                           OR ISNULL(t.[IsHighPriority], 0) <> ISNULL(s.[IsHighPriority], 0)
                           OR ISNULL(t.[IsInComp_Replied], 0) <> ISNULL(s.[IsInComp_Replied], 0)
                           OR ISNULL(t.ChaseID, '') <> ISNULL(s.ChaseID, '')
                           OR ISNULL(t.ContractCode, '') <> ISNULL(s.ContractCode, '')
                           OR ISNULL(t.REN_PROVIDER_SPECIALTY, '') <> ISNULL(s.REN_PROVIDER_SPECIALTY, '')
                           OR ISNULL(t.ChartPriority, '') <> ISNULL(s.ChartPriority, '')
                           OR ISNULL(t.ChartRec_Date, '') <> ISNULL(s.ChartRec_Date, '')
                           OR ISNULL(t.InvoiceExt_Date, '') <> ISNULL(s.InvoiceExt_Date, '')
                           OR ISNULL(t.[Channel_PK], '') <> ISNULL(s.[Channel_PK], '')
                           OR ISNULL(t.EDGEMemberID, '') <> ISNULL(s.EDGEMemberID, '')
						   OR ISNULL(t.ClientID, '') <> ISNULL(s.ClientID, '')
                         ) THEN
            UPDATE SET
                    t.[ProjectID] = s.[ProjectID] ,
                    t.[ProviderID] = s.[ProviderID] ,
                    t.[MemberID] = s.[MemberID] ,
                    t.[IsScanned] = s.[IsScanned] ,
                    t.[IsCNA] = s.[IsCNA] ,
                    t.[IsCoded] = s.[IsCoded] ,
                    t.[IsQA] = s.[IsQA] ,
                    t.[Scanned_UserID] = s.[Scanned_UserID] ,
                    t.[CNA_UserID] = s.[CNA_UserID] ,
                    t.[Coded_UserID] = s.[Coded_UserID] ,
                    t.[QA_UserID] = s.[QA_UserID] ,
                    t.[Scanned_Date] = s.[Scanned_Date] ,
                    t.[CNA_Date] = s.[CNA_Date] ,
                    t.[Coded_Date] = s.[Coded_Date] ,
                    t.[QA_Date] = s.[QA_Date] ,
                    t.[IsDiagnosisCoded] = s.[IsDiagnosisCoded] ,
                    t.[IsNotesCoded] = s.[IsNotesCoded] ,
                    t.[LastAccessed_Date] = s.[LastAccessed_Date] ,
                    t.[LastUpdated] = s.[LastUpdated] ,
                    t.[dtCreated] = s.[dtCreated] ,
                    t.[IsInvoiced] = s.[IsInvoiced] ,
                    t.[MemberStatus] = s.[MemberStatus] ,
                    t.[ProspectiveFormStatus] = s.[ProspectiveFormStatus] ,
                    t.[InvoiceRec_Date] = s.[InvoiceRec_Date] ,
                    t.[ChartRec_FaxIn_Date] = s.[ChartRec_FaxIn_Date] ,
                    t.[ChartRec_MailIn_Date] = s.[ChartRec_MailIn_Date] ,
                    t.[ChartRec_InComp_Date] = s.[ChartRec_InComp_Date] ,
                    t.[IsHighPriority] = s.[IsHighPriority] ,
                    t.[IsInComp_Replied] = s.[IsInComp_Replied] ,
                    t.ChaseID = s.ChaseID ,
                    t.ContractCode = s.ContractCode ,
                    t.REN_PROVIDER_SPECIALTY = s.REN_PROVIDER_SPECIALTY ,
                    t.ChartPriority = s.ChartPriority ,
                    t.ChartRec_Date = s.ChartRec_Date ,
                    t.InvoiceExt_Date = s.InvoiceExt_Date ,
                    t.Channel_PK = s.Channel_PK ,
                    t.EDGEMemberID = s.EDGEMemberID ,
					t.ProviderOfficeID = s.ProviderOfficeID ,
					t.ClientID = s.ClientID ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriSuspectID] ,
                     [ProjectID] ,
                     [ProviderID] ,
                     [MemberID] ,
                     [IsScanned] ,
                     [IsCNA] ,
                     [IsCoded] ,
                     [IsQA] ,
                     [Scanned_UserID] ,
                     [CNA_UserID] ,
                     [Coded_UserID] ,
                     [QA_UserID] ,
                     [Scanned_Date] ,
                     [CNA_Date] ,
                     [Coded_Date] ,
                     [QA_Date] ,
                     [IsDiagnosisCoded] ,
                     [IsNotesCoded] ,
                     [LastAccessed_Date] ,
                     [LastUpdated] ,
                     [dtCreated] ,
                     [IsInvoiced] ,
                     [MemberStatus] ,
                     [ProspectiveFormStatus] ,
                     [InvoiceRec_Date] ,
                     [ChartRec_FaxIn_Date] ,
                     [ChartRec_MailIn_Date] ,
                     [ChartRec_InComp_Date] ,
                     [IsHighPriority] ,
                     [IsInComp_Replied] ,
                     [ChaseID] ,
                     [ContractCode] ,
                     [REN_PROVIDER_SPECIALTY] ,
                     [ChartPriority] ,
                     [ChartRec_Date] ,
                     [InvoiceExt_Date] ,
                     Channel_PK ,
                     EDGEMemberID,
					 ProviderOfficeID,
					 ClientID
                   )
            VALUES ( [CentauriSuspectID] ,
                     [ProjectID] ,
                     [ProviderID] ,
                     [MemberID] ,
                     [IsScanned] ,
                     [IsCNA] ,
                     [IsCoded] ,
                     [IsQA] ,
                     [Scanned_UserID] ,
                     [CNA_UserID] ,
                     [Coded_UserID] ,
                     [QA_UserID] ,
                     [Scanned_Date] ,
                     [CNA_Date] ,
                     [Coded_Date] ,
                     [QA_Date] ,
                     [IsDiagnosisCoded] ,
                     [IsNotesCoded] ,
                     [LastAccessed_Date] ,
                     [LastUpdated] ,
                     [dtCreated] ,
                     [IsInvoiced] ,
                     [MemberStatus] ,
                     [ProspectiveFormStatus] ,
                     [InvoiceRec_Date] ,
                     [ChartRec_FaxIn_Date] ,
                     [ChartRec_MailIn_Date] ,
                     [ChartRec_InComp_Date] ,
                     [IsHighPriority] ,
                     [IsInComp_Replied] ,
                     [ChaseID] ,
                     [ContractCode] ,
                     [REN_PROVIDER_SPECIALTY] ,
                     [ChartPriority] ,
                     [ChartRec_Date] ,
                     [InvoiceExt_Date] ,
                     Channel_PK ,
                     EDGEMemberID,
					 ProviderOfficeID,
					 ClientID
                   );

       
	--   SELECT  a.SuspectID INTO #tmp
 --   FROM [CHSDW].[fact].[Suspect] a
 --   --INNER JOIN  dim.ProviderClient c ON c.ProviderID = a.ProviderID AND c.RecordEndDate='2999-12-31'
	--INNER JOIN  dim.Client d  ON d.ClientID = a.ClientID AND d.ClientName ='WellCare'
 --   WHERE ChaseID LIKE '%CENT' AND a.iscentauri IS NULL
	
	--INSERT INTO #tmp 
	--SELECT a.SuspectID
	--FROM [CHSDW].[fact].[Suspect] a
 --   --INNER JOIN  dim.ProviderClient c ON c.ProviderID = a.ProviderID AND c.RecordEndDate='2999-12-31'
	--INNER JOIN  dim.Client d  ON d.ClientID = a.ClientID AND d.ClientName ='WellCare'
	--INNER join dim.ADVProject p ON p.ClientID = d.ClientID AND p.ProjectID = a.ProjectID AND p.ProjectGroup='Chase List 02'
 --   WHERE  a.iscentauri IS NULL
	

	   SELECT  a.SuspectID INTO #tmp
    FROM [CHSDW].[fact].[Suspect] a
    --INNER JOIN  dim.ProviderClient c ON c.ProviderID = a.ProviderID AND c.RecordEndDate='2999-12-31'
	INNER JOIN  dim.Client d  ON d.ClientID = a.ClientID AND d.ClientName ='WellCare'
    WHERE a.Channel_PK=10 --AND a.iscentauri IS NULL

	
	   SELECT  a.SuspectID INTO #tmp2
    FROM [CHSDW].[fact].[Suspect] a
    --INNER JOIN  dim.ProviderClient c ON c.ProviderID = a.ProviderID AND c.RecordEndDate='2999-12-31'
	INNER JOIN  dim.Client d  ON d.ClientID = a.ClientID AND d.ClientName ='WellCare'
    WHERE a.Channel_PK<>10 --AND a.iscentauri IS NULL


	INSERT INTO #tmp 
     SELECT  a.SuspectID 
    FROM [CHSDW].[fact].[Suspect] a
  --  INNER JOIN  dim.ProviderClient c
  --ON c.ProviderID = a.ProviderID AND c.RecordEndDate='2999-12-31'
  INNER JOIN  dim.Client d  ON d.ClientID = a.ClientID AND d.ClientName <>'WellCare'
    WHERE  a.iscentauri IS NULL

	
	  UPDATE fact.Suspect 
		SET iscentauri =1
	WHERE SuspectID IN (SELECT SuspectID FROM #tmp)

	UPDATE fact.Suspect
		SET iscentauri =0
	WHERE iscentauri IS NULL  AND SuspectID NOT IN (SELECT SuspectID FROM #tmp)

	
	UPDATE fact.Suspect
		SET iscentauri =0
	WHERE  SuspectID IN (SELECT SuspectID FROM #tmp2)

	

	 END; 
	
GO
