SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/20/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update 09/29/2018 Adding Channel_PK and EDGEMemberID  PJ
--Update 10/04/2016 Replace RecordEndDate/LoadDate with Link Satellite PJ
--Update 10/25/2016 Adding ProviderOffice PJ
-- Description:	Gets Suspects details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetSuspect]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT DISTINCT
                h.Suspect_BK AS CentauriSuspectID ,
                j.Project_BK AS CentauriProjectID ,
                p.Provider_BK AS CentauriProviderID ,
				po.ProviderOffice_BK AS CentauriProviderOfficeID,
                hm.Member_BK AS CentauriMemberID ,
                s.[IsScanned] ,
                s.[IsCNA] ,
                s.[IsCoded] ,
                s.[IsQA] ,
                scan.ScannedUser AS [Scanned_CentauriUserID] ,
                CNA.CNAUser AS [CNA_CentauriUserID] ,
                Coded.CodedUser AS [Coded_CentauriUserID] ,
                QA.QAUser AS [QA_CentauriUserID] ,
                s.[Scanned_Date] ,
                s.[CNA_Date] ,
                s.[Coded_Date] ,
                s.[QA_Date] ,
                s.[IsDiagnosisCoded] ,
                s.[IsNotesCoded] ,
                s.[LastAccessed_Date] ,
                s.[LastUpdated] ,
                s.[dtCreated] ,
                s.[IsInvoiced] ,
                s.[MemberStatus] ,
                s.[ProspectiveFormStatus] ,
                s.[InvoiceRec_Date] ,
                s.[ChartRec_FaxIn_Date] ,
                s.[ChartRec_MailIn_Date] ,
                s.[ChartRec_InComp_Date] ,
                s.[IsHighPriority] ,
                s.[IsInComp_Replied] ,
                s.[ChaseID] ,
                s.[ContractCode] ,
                s.[REN_PROVIDER_SPECIALTY] ,
                s.[ChartPriority] ,
                s.[ChartRec_Date] ,
                s.[InvoiceExt_Date] ,
                s.[Channel_PK] ,
                s.[EDGEMemberID] ,
                @CCI AS [ClientID] ,
                s.[RecordSource] ,
                s.[LoadDate]
        FROM    [dbo].[H_Suspect] h
                INNER JOIN dbo.S_SuspectDetail s ON s.H_Suspect_RK = h.H_Suspect_RK
                                                    AND s.RecordEndDate IS NULL
                LEFT OUTER JOIN ( SELECT    u.User_PK AS ScannedUser ,
                                            a.H_Suspect_RK
                                  FROM      L_SuspectUser a
                                            INNER JOIN dbo.S_SuspectDetail sa ON sa.H_Suspect_RK = a.H_Suspect_RK
                                                                                 AND sa.RecordEndDate IS NULL
                                            LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = a.H_User_RK
                                  WHERE     sa.Scanned_User_PK = u.ClientUserID
                                                          ) AS scan ON h.H_Suspect_RK = scan.H_Suspect_RK
                LEFT OUTER JOIN ( SELECT    u.User_PK AS CNAUser ,
                                            b.H_Suspect_RK
                                  FROM      L_SuspectUser b
                                            INNER JOIN dbo.S_SuspectDetail sb ON sb.H_Suspect_RK = b.H_Suspect_RK
                                                                                 AND sb.RecordEndDate IS NULL
                                            LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = b.H_User_RK
                                  WHERE     sb.CNA_User_PK = u.ClientUserID
                                            
                                ) AS CNA ON h.H_Suspect_RK = CNA.H_Suspect_RK
                LEFT OUTER JOIN ( SELECT    u.User_PK AS CodedUser ,
                                            c.H_Suspect_RK
                                  FROM      L_SuspectUser c
                                            INNER JOIN dbo.S_SuspectDetail sc ON sc.H_Suspect_RK = c.H_Suspect_RK
                                                                                 AND sc.RecordEndDate IS NULL
                                            LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = c.H_User_RK
                                  WHERE     sc.Coded_User_PK = u.ClientUserID
                                            
                                ) AS Coded ON h.H_Suspect_RK = Coded.H_Suspect_RK
                LEFT OUTER JOIN ( SELECT    u.User_PK AS QAUser ,
                                            d.H_Suspect_RK
                                  FROM      L_SuspectUser d
                                            INNER JOIN dbo.S_SuspectDetail sd ON sd.H_Suspect_RK = d.H_Suspect_RK
                                                                                 AND sd.RecordEndDate IS NULL
                                            LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = d.H_User_RK
                                  WHERE     sd.QA_User_PK = u.ClientUserID
                                            
                                ) AS QA ON h.H_Suspect_RK = QA.H_Suspect_RK
                LEFT OUTER JOIN ( SELECT    llsp.H_Suspect_RK ,
                                            llsp.H_Provider_RK,lspl.H_ProviderOffice_RK,
											lspl.LoadDate
                                  FROM      dbo.L_SuspectProvider llsp
                                            INNER JOIN dbo.LS_SuspectProvider lspl ON lspl.L_SuspectProvider_RK = llsp.L_SuspectProvider_RK
                                                                                      AND lspl.RecordEndDate IS NULL
                                ) lsp ON h.H_Suspect_RK = lsp.H_Suspect_RK
                LEFT OUTER JOIN dbo.H_Provider p ON p.H_Provider_RK = lsp.H_Provider_RK
				LEFT OUTER JOIN dbo.H_ProviderOffice po ON po.H_ProviderOffice_RK = lsp.H_ProviderOffice_RK
                LEFT OUTER JOIN ( SELECT    llcm.H_Suspect_RK ,
                                            llcm.H_Member_RK,lcml.LoadDate
                                  FROM      dbo.L_SuspectMember llcm
                                            INNER JOIN LS_SuspectMember lcml ON lcml.L_SuspectMember_RK = llcm.L_SuspectMember_RK
                                                                                AND lcml.RecordEndDate IS NULL
                                ) lcm ON lcm.H_Suspect_RK = h.H_Suspect_RK
                LEFT OUTER JOIN dbo.H_Member hm ON hm.H_Member_RK = lcm.H_Member_RK
                LEFT OUTER JOIN ( SELECT    lljp.H_Suspect_RK ,
                                            lljp.H_Project_RK,ljpl.LoadDate
                                  FROM      dbo.L_SuspectProject lljp
                                            INNER JOIN dbo.LS_SuspectProject ljpl ON ljpl.L_SuspectProject_RK = lljp.L_SuspectProject_RK
                                                                                     AND ljpl.RecordEndDate IS NULL
                                ) ljp ON ljp.H_Suspect_RK = h.H_Suspect_RK
                LEFT OUTER JOIN dbo.H_Project j ON j.H_Project_RK = ljp.H_Project_RK
        WHERE   s.LoadDate > @LoadDate OR lsp.LoadDate>@LoadDate OR lcm.LoadDate>@LoadDate OR ljp.LoadDate>@LoadDate;

    END;

--GO


GO
