begin;

  insert into common.group (slug, name, description) values ('default', 'Default Group', 'Group that should be assigned to a user by default.');

commit;
