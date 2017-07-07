IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Client.Services.Quality')
CREATE LOGIN [INTERNAL\Client.Services.Quality] FROM WINDOWS
GO
CREATE USER [INTERNAL\Client.Services.Quality] FOR LOGIN [INTERNAL\Client.Services.Quality]
GO
GRANT VIEW DEFINITION TO [INTERNAL\Client.Services.Quality]
