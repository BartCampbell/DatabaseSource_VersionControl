SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- =============================================
---- Author:		Travis Parker
---- Create date:	12/22/2016
---- Description:	Gets the latest Apixio Return data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetApixioReturn '01/01/2016'
---- =============================================
CREATE PROC [dw].[spGetApixioReturn]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  s.ReferenceNbr ,
            s.ProviderNPI ,
            s.ProviderLast ,
            s.ProviderFirst ,
            s.DateOfService ,
            s.ProviderType ,
            s.MemberID ,
            s.MemberHICN ,
            s.MemberLast ,
            s.MemberFirst ,
            s.MemberDOB ,
            s.MemberGender ,
            s.HCC ,
            s.ICD9 ,
            s.ICD10 ,
            s.Comments ,
            s.PatientUUID ,
            s.DocumentUUID ,
            s.ChartID ,
            s.Page ,
            s.CoderHistory ,
            s.CoderAnnotationHistory ,
            s.CodingDate ,
            s.Delivered ,
            s.PhaseComplete ,
            s.LoadDate ,
            s.RecordSource ,
            m.Member_BK AS CentauriMemberID ,
            lp.CentauriProviderID ,
		  c.Client_BK AS ClientID
    FROM    dbo.H_ApixioReturn h
            INNER JOIN dbo.S_ApixioReturn s ON s.H_ApixioReturn_RK = h.H_ApixioReturn_RK--19171
            LEFT JOIN dbo.L_MemberApixioReturn lm ON lm.H_ApixioReturn_RK = h.H_ApixioReturn_RK
            LEFT JOIN dbo.H_Member m ON m.H_Member_RK = lm.H_Member_RK
            LEFT JOIN ( SELECT  t.H_ApixioReturn_RK ,
                                t.CentauriProviderID ,
                                t.rown
                        FROM    ( SELECT    lp.H_ApixioReturn_RK ,
                                            p.Provider_BK AS CentauriProviderID ,
                                            ROW_NUMBER() OVER ( PARTITION BY lp.H_ApixioReturn_RK ORDER BY lp.LoadDate DESC, lp.RecordSource DESC ) AS rown
                                  FROM      dbo.L_ProviderApixioReturn lp
                                            INNER JOIN dbo.H_Provider p ON p.H_Provider_RK = lp.H_Provider_RK
                                ) t
                        WHERE   t.rown = 1
                      ) lp ON lp.H_ApixioReturn_RK = h.H_ApixioReturn_RK
            CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime; --12571




GO
