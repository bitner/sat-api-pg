BEGIN;
\set QUIET on
\set ON_ERROR_STOP on
set client_min_messages to warning;
truncate data.collections restart identity cascade;
truncate data.items restart identity cascade;
\ir data.sql
COMMIT;
