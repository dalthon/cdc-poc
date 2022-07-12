module.exports = {
  up (queryInterface, DataTypes) {
    return queryInterface.sequelize.query(`
      CREATE TABLE new_todo (
        id         bigserial PRIMARY KEY,
        todo       varchar,
        user_id    bigint REFERENCES "Users",
        created_at timestamptz,
        updated_at timestamptz
      );

      CREATE OR REPLACE FUNCTION todo_trigger_fn() RETURNS trigger AS $$
      DECLARE
        todo RECORD;
      BEGIN
        SELECT *
        INTO todo
        FROM new_todo
        WHERE id = NEW.id;

        IF NOT FOUND THEN
          RETURN NEW;
        ELSE
          RETURN NULL;
        END IF;
      END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER todo_trigger
        BEFORE INSERT ON new_todo
        FOR EACH ROW EXECUTE PROCEDURE todo_trigger_fn();
    `)
  },

  down (queryInterface) {},
}
