docker exec db pg_dump -d postgres -U postgres | gzip > output/facilities.gz
