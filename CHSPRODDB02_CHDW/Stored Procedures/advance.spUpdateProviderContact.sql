SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	06/22/2016
-- Description:	updates the provider contact data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spUpdateProviderContact'001', 112546
-- =============================================
CREATE PROC [advance].[spUpdateProviderContact]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    DECLARE @CurrentDate DATETIME = GETDATE()
    
    SET NOCOUNT ON; 

    IF OBJECT_ID('tempdb..#PhoneList') IS NOT NULL
        DROP TABLE #PhoneList;
    IF OBJECT_ID('tempdb..#FaxList') IS NOT NULL
        DROP TABLE #FaxList;

    SELECT  pc.Phone ,
            pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            COUNT(*) AS PhoneCount ,
            ROW_NUMBER() OVER ( PARTITION BY pl.Advance_Addr1, pl.Advance_Zip ORDER BY COUNT(*) DESC ) rown
    INTO    #PhoneList
    FROM    fact.OEC o
            INNER JOIN dim.ProviderContact pc ON o.ProviderContactID = pc.ProviderContactID
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON op.ClientID = c.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID
    GROUP BY pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            pc.Phone
    ORDER BY pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            PhoneCount DESC; 

    SELECT  pc.Fax ,
            pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            COUNT(*) AS FaxCount ,
            ROW_NUMBER() OVER ( PARTITION BY pl.Advance_Addr1, pl.Advance_Zip ORDER BY COUNT(*) DESC ) rown
    INTO    #FaxList
    FROM    fact.OEC o
            INNER JOIN dim.ProviderContact pc ON o.ProviderContactID = pc.ProviderContactID
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON op.ClientID = c.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID
    GROUP BY pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            pc.Fax
    ORDER BY pl.Advance_Addr1 ,
            pl.Advance_Zip ,
            FaxCount DESC; 


    UPDATE  pl
    SET     pl.Advance_Phone = t.AdvancePhone, pl.LastUpdate = @CurrentDate
    FROM    fact.OEC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON op.ClientID = c.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
            INNER JOIN ( SELECT DISTINCT
                                a2.Advance_Addr1 ,
                                a2.Advance_Zip ,
                                ISNULL(SUBSTRING(( SELECT   ',' + a1.Phone AS [text()]
                                                   FROM     #PhoneList a1
                                                   WHERE    a1.Advance_Addr1 = a2.Advance_Addr1
                                                            AND a1.Advance_Zip = a2.Advance_Zip
                                                            AND a1.Phone <> ''
                                                   ORDER BY a1.Advance_Addr1 ,
                                                            a1.Advance_Zip ,
                                                            a1.rown
                                                 FOR
                                                   XML PATH('')
                                                 ), 2, 1000), '') AdvancePhone
                         FROM   #PhoneList a2
                       ) t ON pl.Advance_Addr1 = t.Advance_Addr1
                              AND pl.Advance_Zip = t.Advance_Zip;  

    UPDATE  pl
    SET     pl.Advance_Fax = t.AdvanceFax, pl.LastUpdate = @CurrentDate
    FROM    fact.OEC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON op.ClientID = c.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
            INNER JOIN ( SELECT DISTINCT
                                a2.Advance_Addr1 ,
                                a2.Advance_Zip ,
                                ISNULL(SUBSTRING(( SELECT   ',' + a1.Fax AS [text()]
                                                   FROM     #FaxList a1
                                                   WHERE    a1.Advance_Addr1 = a2.Advance_Addr1
                                                            AND a1.Advance_Zip = a2.Advance_Zip
                                                            AND a1.Fax <> ''
                                                   ORDER BY a1.Advance_Addr1 ,
                                                            a1.Advance_Zip ,
                                                            a1.rown
                                                 FOR
                                                   XML PATH('')
                                                 ), 2, 1000), '') AdvanceFax
                         FROM   #FaxList a2
                       ) t ON pl.Advance_Addr1 = t.Advance_Addr1
                              AND pl.Advance_Zip = t.Advance_Zip;  



		  
GO
