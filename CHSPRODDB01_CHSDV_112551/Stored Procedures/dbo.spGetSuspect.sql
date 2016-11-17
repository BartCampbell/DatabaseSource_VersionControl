SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/06/2016
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

        SELECT  h.Suspect_BK AS CentauriSuspectID ,
                j.Project_BK AS CentauriProjectID ,
                p.Provider_BK AS CentauriProviderID ,
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
                @CCI AS [ClientID] ,
                s.[RecordSource] ,
                s.[LoadDate]
        FROM    [dbo].[H_Suspect] h
                INNER JOIN dbo.S_SuspectDetail s ON s.H_Suspect_RK = h.H_Suspect_RK
                LEFT OUTER JOIN ( SELECT    u.User_PK AS ScannedUser ,
                                            a.H_Suspect_RK
                                  FROM      L_SuspectUser a
                                            INNER JOIN dbo.S_SuspectDetail sa ON sa.H_Suspect_RK = a.H_Suspect_RK
                                            LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = a.H_User_RK
                                  WHERE     sa.Scanned_User_PK = u.ClientUserID
                                ) AS scan ON h.H_Suspect_RK = scan.H_Suspect_RK
                LEFT OUTER JOIN ( SELECT    u.User_PK AS CNAUser ,
                                            b.H_Suspect_RK
                                  FROM      L_SuspectUser b
                                            INNER JOIN dbo.S_SuspectDetail sb ON sb.H_Suspect_RK = b.H_Suspect_RK
                                            LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = b.H_User_RK
                                  WHERE     sb.CNA_User_PK = u.ClientUserID
                                ) AS CNA ON h.H_Suspect_RK = CNA.H_Suspect_RK
                LEFT OUTER JOIN ( SELECT    u.User_PK AS CodedUser ,
                                            c.H_Suspect_RK
                                  FROM      L_SuspectUser c
                                            INNER JOIN dbo.S_SuspectDetail sc ON sc.H_Suspect_RK = c.H_Suspect_RK
                                            LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = c.H_User_RK
                                  WHERE     sc.Coded_User_PK = u.ClientUserID
                                ) AS Coded ON h.H_Suspect_RK = Coded.H_Suspect_RK
                LEFT OUTER JOIN ( SELECT    u.User_PK AS QAUser ,
                                            d.H_Suspect_RK
                                  FROM      L_SuspectUser d
                                            INNER JOIN dbo.S_SuspectDetail sd ON sd.H_Suspect_RK = d.H_Suspect_RK
                                            LEFT OUTER JOIN dbo.H_User u ON u.H_User_RK = d.H_User_RK
                                  WHERE     sd.QA_User_PK = u.ClientUserID
                                ) AS QA ON h.H_Suspect_RK = QA.H_Suspect_RK
                LEFT OUTER JOIN dbo.L_SuspectProvider lsp ON h.H_Suspect_RK = lsp.H_Suspect_RK
                --LEFT OUTER JOIN  (SELECT lpm.H_ProviderMaster_RK,MIN(p.Provider_BK) AS Provider_BK FROM dbo.L_ProviderProviderMaster lpm
					--			INNER JOIN dbo.H_Provider p ON p.H_Provider_RK = lpm.H_Provider_RK
						--		GROUP BY lpm.H_ProviderMaster_RK) lp ON lp.H_ProviderMaster_RK = l.H_ProviderMaster_RK
                LEFT OUTER JOIN dbo.H_Provider p ON p.H_Provider_RK = lsp.H_Provider_RK
                LEFT OUTER JOIN dbo.L_SuspectMember lcm ON lcm.H_Suspect_RK = h.H_Suspect_RK
                LEFT OUTER JOIN dbo.H_Member hm ON hm.H_Member_RK = lcm.H_Member_RK
                LEFT OUTER JOIN dbo.L_SuspectProject ljp ON ljp.H_Suspect_RK = h.H_Suspect_RK
                LEFT OUTER JOIN dbo.H_Project j ON j.H_Project_RK = ljp.H_Project_RK
			WHERE   s.LoadDate > @LoadDate;

    END;

--GO
GO
