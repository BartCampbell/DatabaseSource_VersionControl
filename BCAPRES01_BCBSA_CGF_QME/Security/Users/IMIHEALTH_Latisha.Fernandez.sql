IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\Latisha.Fernandez')
CREATE LOGIN [IMIHEALTH\Latisha.Fernandez] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\Latisha.Fernandez] FOR LOGIN [IMIHEALTH\Latisha.Fernandez] WITH DEFAULT_SCHEMA=[IMIHEALTH\Latisha.Fernandez]
GO
REVOKE CONNECT TO [IMIHEALTH\Latisha.Fernandez]
