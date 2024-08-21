
## Commands to Create Accounts and Set Permissions

### Create Local Users

```
-- On db01
use [public_research];
CREATE LOGIN [public_db_reader] WITH PASSWORD = 'your_secure_password';
CREATE USER [public_db_reader] FOR LOGIN [public_db_reader];
GRANT SELECT ON DATABASE::[public_research] TO [public_db_reader];
CREATE LOGIN [umbrellacorp\gmsa_db01$] FROM WINDOWS;
CREATE USER [gmsa_db01] FOR LOGIN [umbrellacorp\gmsa_db01$];
GRANT SELECT ON DATABASE::[public_research] TO [gmsa_db01];

-- On db02
use [_5G_enzyme_experimental];
CREATE LOGIN [public_db_reader] WITH PASSWORD = 'your_secure_password';
CREATE USER [public_db_reader] FOR LOGIN [public_db_reader];
CREATE LOGIN [private_db_reader] WITH PASSWORD = 'your_secure_password';
CREATE USER [private_db_reader] FOR LOGIN [private_db_reader];
GRANT SELECT ON DATABASE::[_5G_enzyme_experimental] TO [public_db_reader];
GRANT SELECT ON DATABASE::[_5G_enzyme_experimental] TO [private_db_reader];
CREATE LOGIN [umbrellacorp\gmsa_db01$] FROM WINDOWS;
CREATE USER [gmsa_db01] FOR LOGIN [umbrellacorp\gmsa_db01$];
GRANT SELECT ON DATABASE::[_5G_enzyme_experimental] TO [gmsa_db01];
CREATE LOGIN [umbrellacorp\gmsa_db02$] FROM WINDOWS;
CREATE USER [gmsa_db02] FOR LOGIN [umbrellacorp\gmsa_db02$];
GRANT SELECT ON DATABASE::[_5G_enzyme_experimental] TO [gmsa_db02];
```

### Linked Server Configuration

```
-- On db01
EXEC sp_addlinkedserver 
   @server=N'db02', 
   @srvproduct=N'SQL Server';

EXEC sp_addlinkedsrvlogin 
   @rmtsrvname=N'db02', 
   @useself=N'False', 
   @locallogin=N'public_db_reader', 
   @rmtuser=N'public_db_reader', 
   @rmtpassword='your_secure_password';
```
