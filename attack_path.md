# Compromising Client and Demonstrating Impact without DA/EA

## Attack Paths

### Attack Path 1: RDP to Web Server and Exploit Permissions

1. **Initial Access**:
    - Gain access to a "beachhead" machine.

2. **RDP into Web Server**:
    - Utilize RDP credentials or exploit to gain access to the web server.

3. **Exploit World Readable Directory**:
    - Identify the world-readable directory with overly permissive ACLs.
    - Extract the connection string to MSSQL1 located in a configuration file within this directory.

4. **Access MSSQL1**:
    - Use the extracted connection string to authenticate to MSSQL1 as "vendorsDB".

5. **Linked Server Elevation**:
    - Identify a linked server configuration from MSSQL1.
    - Exploit the "vendorsDB" SA privileges on the linked server to execute queries against other databases, including the target "5G_enzyme_experimental" database.

6. **Data Exfiltration**:
    - Extract data from the "5G_enzyme_experimental" database through the linked server connection.

### Attack Path 2: SQL Injection on Webpage

1. **Identify SQLi Vulnerability**:
    - Discover a SQL injection vulnerability on a webpage that interacts with a backend database (dbAccountDetails).

2. **Exploit SQLi**:
    - Craft and execute a SQL injection attack to retrieve sensitive information from dbAccountDetails, specifically targeting username and password records for the MSSQL instance.

3. **Gain Database Access**:
    - Use the dumped credentials to authenticate to the MSSQL server.

4. **Privilege Escalation**:
    - Identify and exploit SQL Server vulnerabilities or misconfigurations for privilege escalation, if needed.

5. **Target Database Access**:
    - Access the "5G_enzyme_experimental" database using the escalated privileges or directly with the dumped credentials.

6. **Data Exfiltration**:
    - Extract desired data from the "5G_enzyme_experimental" database.

## Environment Setup

### Servers

- **db01**
- **db02**

### Group Managed Service Accounts (gMSAs)

- **gmsa_db01**: Runs SQL Server on db01
- **gmsa_db02**: Runs SQL Server on db02

### Local Users

- **public_db_reader**: Read permissions on both db01 and db02
- **private_db_reader**: Read permissions on db02

### Permissions Structure

- **gmsa_db01**: 
    - Permissions on both db01 and db02
    - db02 being a linked server

- **gmsa_db02**: 
    - Permissions on db02

- **public_db_reader**: 
    - Read permissions on both db01 and db02

- **private_db_reader**: 
    - Read permissions on db02

### Restrictions

- No accounts have write or modify access, only read.

---

End of Document
