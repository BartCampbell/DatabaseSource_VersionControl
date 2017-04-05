SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
_____________________________________________________________________

      Author:    David Neal
Date Created:    06/03/2004
    Comments:    Use to send email using SMTP.
                Based on Microsoft KB 312839
                http://support.microsoft.com/default.aspx?scid=kb;en-us;312839&sd=tech

 Last Update:
   Update By:
      Reason:
Test:
EXEC usp_send_mail 'support@imihealth.com', 'leon.dowling@imihealth.com', 'E-mail test', 'See if this works.asdfasdfasd'
_____________________________________________________________________
*/
CREATE PROCEDURE [dbo].[usp_send_mail]
(
    @From varchar(100),
    @To varchar(100),
    @Subject varchar(100),
    @Body varchar(4000),
    @SMTPServer varchar(200) = 'smtp.imihealth.com'
)
AS

PRINT 'dbmail not configured yet'

--EXEC msdb.dbo.sp_send_dbmail
--	@profile_name = 'chsmail',
--	@recipients = @To,
--	@body = @Body,
--	@subject = @Subject

/*

DECLARE	@iMsg			int,
		@hr				int,
		@source			varchar(255),
		@description	varchar(500),
		@output			varchar(1000)

SET @From = 'support@imihealth.com'
-- ************* Create the CDO.Message Object ************************
   EXEC @hr = sp_OACreate 'CDO.Message', @iMsg OUT

-- ***************Configuring the Message Object ******************
-- This is to configure a remote SMTP server.
-- http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cdosys/html/_cdosys_schema_configuration_sendusing.asp
   EXEC @hr = sp_OASetProperty @iMsg, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusing").Value','2'

-- This is to configure the Server Name or IP address.
   EXEC @hr = sp_OASetProperty @iMsg, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserver").Value', @SMTPServer

-- Save the configurations to the message object.
   EXEC @hr = sp_OAMethod @iMsg, 'Configuration.Fields.Update', null

-- Set the e-mail parameters.
   EXEC @hr = sp_OASetProperty @iMsg, 'To', @To
   EXEC @hr = sp_OASetProperty @iMsg, 'From', @From
   EXEC @hr = sp_OASetProperty @iMsg, 'Subject', @Subject

-- If you are using HTML e-mail, use 'HTMLBody' instead of 'TextBody'.
   EXEC @hr = sp_OASetProperty @iMsg, 'TextBody', @Body
   EXEC @hr = sp_OAMethod @iMsg, 'Send', NULL

-- Error handling.
    IF @hr <> 0
    BEGIN
        SELECT @hr
        EXEC @hr = sp_OAGetErrorInfo NULL, @source OUT, @description OUT

        IF @hr = 0
        BEGIN
            SELECT @output = '  Source: ' + @source
            PRINT  @output
            SELECT @output = '  Description: ' + @description
            PRINT  @output
        END
        ELSE
            BEGIN
            PRINT '  sp_OAGetErrorInfo failed.'
            RETURN
        END
    END

-- Clean up the objects created.
    EXEC @hr = sp_OADestroy @iMsg



*/
GO
