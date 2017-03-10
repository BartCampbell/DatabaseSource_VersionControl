IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\Latisha.Fernandez')
CREATE LOGIN [IMIHEALTH\Latisha.Fernandez] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\Latisha.Fernandez] FOR LOGIN [IMIHEALTH\Latisha.Fernandez]
GO
GRANT VIEW DEFINITION TO [IMIHEALTH\Latisha.Fernandez]
