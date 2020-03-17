# Acronis MySQL restore script
Use this script to create database dumps from backups. You can restore the backup using the script.

## Requirements
1. Your backup is created using [our documentation](https://support.yourwebhoster.eu/en-us/article/91-backup-mysql-using-acronis-cloud-backup).
2. The MySQL data in the backup is not corrupted.

## How to install
1. Run the code below.
2. Follow [our documentation](https://support.yourwebhoster.eu/en-us/article/91-backup-mysql-using-acronis-cloud-backup).

```
cat /var/lib/Acronis/
git clone git@github.com:Yourwebhostereu/acronis-mysql.git mysql
```

## How to restore a database
[Check our documentation for a complete restore how-to](https://support.yourwebhoster.eu/en-us/article/100-restore-a-mysql-backup-from-acronis)
1. Restore the contents of the mysql data directory to /tmp_mysql
2. Run  `/var/lib/Acronis/mysql/dump.sh -d DATABASE_NAME`.
3. A database dump is created in /tmp_mysql/DATABASE_NAME.sql
4. Restore the database to your MySQL cluster.
5. Once done, delete /tmp_mysql

# FAQ
## Q: When should I use this script?
A: When you use Acronis backup for DirectAdmin of an other panel.

## Q: Where can I get low-prices Acronis backup storage?
A: You can [order Acronis backup in The Netherlands for just € 0.02 per GB at Yourwebhoster.eu](https://www.yourwebhoster.eu/acronis-backup/).

## Q: Can I use this with the control panels Plesk and cPanel?
A: There is native integration available for these panels. [Learn how to backup cPanel with Acronis here](https://support.yourwebhoster.eu/en-us/article/89-backup-cpanel-with-acronis-cloud-backup) and [learn how to backup Plesk with Acronis here](https://support.yourwebhoster.eu/en-us/article/90-backup-plesk-with-acronis-cloud-backup).

## Q: I have problems with restoring my backup from Acronis
A: [Contact us here (English and Dutch support available)](https://support.yourwebhoster.eu/en-us/conversation/new)

## Q: Can I resell Acronis backup (whitelabel) and use this script?
A: Yes, you can sell Acronis backup for servers, desktops, smartphones, cloud (office365, Gsuite) and more. [Contact us for more information.](https://support.yourwebhoster.eu/en-us/conversation/new)