todo:
- Set up and run the MCP filesystem server for the DeliveryX project:
  - Command: `npx @modelcontextprotocol/server-filesystem /Users/fahdayoubi/dev/deliveryx`
  - Confirm the server is running and accessible on stdio.
  - Document basic usage (security context, endpoints if any, shutdown command).
  - (If needed, add a README section describing how team members can use this integration.)

- Use the alias = testing-debt-admin-portal.md
- docker-compose: remove version: '3.8' - WARN[0000] /Users/fahdayoubi/dev/deliveryx/oapp/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
- 

Admin-portal:
- complete testing-debt-admin-portal.md 


Tech-debt:
- Story: Remove the need for the approval database (now in the Menu Service)
PGPASSWORD=deliveryx_dev_pass psql -h localhost -p 5435 -U deliveryx -d deliveryx_approval
deliveryx_approval=# \dt
               List of relations
 Schema |       Name        | Type  |   Owner   
--------+-------------------+-------+-----------
 public | approval_logs     | table | deliveryx
 public | schema_migrations | table | deliveryx
(2 rows)


Menu Service:
