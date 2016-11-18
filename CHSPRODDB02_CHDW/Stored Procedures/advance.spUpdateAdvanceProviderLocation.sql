SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	06/21/2016
-- Description:	updates the provider office data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spUpdateAdvanceProviderLocation '001', 112546
-- =============================================
CREATE PROC [advance].[spUpdateAdvanceProviderLocation]
    --@ProjectID VARCHAR(20) ,
    --@CentauriClientID INT
AS
    SET NOCOUNT ON; 


    UPDATE  pl
    SET     Advance_Addr1 = t.Address ,
            Advance_Zip = t.Zip
    FROM    ( SELECT    providerlocationid ,
                        REPLACE(address + ' ' + suite + ' ' + LEFT([address parse.city],
                                                                   LEN([address parse.city]) - CHARINDEX(' ', REVERSE([address parse.city]))), '  ', ' ') AS Address ,
                        REVERSE(SUBSTRING(REVERSE([address parse.city]), 1, CHARINDEX(' ', REVERSE([address parse.city])) - 1)) AS city ,
                        [address parse.zip] AS zip ,
                        AddressIn ,
                        Standardized
              FROM      dbo.cozyrocaddress
              WHERE     CHARINDEX(' ', [address parse.city]) > 0
              UNION
              SELECT    providerlocationid ,
                        REPLACE(address + ' ' + suite, '  ', ' ') AS Address ,
                        [address parse.city] AS city ,
                        [address parse.zip] AS zip ,
                        AddressIn ,
                        Standardized
              FROM      dbo.cozyrocaddress
              WHERE     CHARINDEX(' ', [address parse.city]) = 0
            ) t
            INNER JOIN dim.providerlocation pl ON t.providerlocationid = pl.providerlocationid
            --INNER JOIN fact.oec o ON pl.ProviderLocationID = o.ProviderLocationID
            --INNER JOIN dim.OECProject op ON o.OECProjectID = op.OECProjectID
            --INNER JOIN dim.Client c ON o.ClientID = c.ClientID
    --WHERE   op.ProjectID = @ProjectID
    --        AND c.CentauriClientID = @CentauriClientID;


		  
GO
