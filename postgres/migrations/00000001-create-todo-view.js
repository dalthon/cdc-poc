module.exports = {
  up (queryInterface, DataTypes) {
    return queryInterface.sequelize.query(`
      CREATE TABLE new_todo (
        id bigserial PRIMARY KEY,
        todo varchar,
        user_id bigint REFERENCES "Users",
        created_at timestamptz,
        updated_at timestamptz
      );

      CREATE OR REPLACE VIEW todo_view AS
        SELECT
          new_todo.id,
          new_todo.todo,
          new_todo.user_id,
          new_todo.created_at::varchar,
          new_todo.updated_at::varchar
        FROM new_todo;

      CREATE OR REPLACE FUNCTION todo_trigger_fn() RETURNS trigger AS $$
      BEGIN
        INSERT INTO new_todo (
          id, todo, user_id, created_at, updated_at
        ) VALUES (
          NEW.id, NEW.todo, NEW.user_id, NEW.created_at::timestamptz, NEW.updated_at::timestamptz
        ) ON CONFLICT DO NOTHING;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER todo_trigger
        INSTEAD OF INSERT OR UPDATE ON todo_view
        FOR EACH ROW EXECUTE PROCEDURE todo_trigger_fn();
    `)
  },

  down (queryInterface) {},
}
