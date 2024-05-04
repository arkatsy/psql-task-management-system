CREATE TABLE IF NOT EXISTS User (
    user_id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    username VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    projects INT[] REFERENCES Project(project_id)
)

CREATE TABLE IF NOT EXISTS Project (
    project_id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    project_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_by INT REFERENCES User(user_id),
    tasks INT[] REFERENCES Task(task_id)
);

CREATE TABLE IF NOT EXISTS Task (
    task_id SERIAL PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    task_name VARCHAR(255) NOT NULL,
    description TEXT,
    deadline DATE,
    status VARCHAR(20) NOT NULL,
    assigned_to INT REFERENCES User(user_id),
    project INT REFERENCES Project(project_id)
);

-- Trigger for updating the updated_at column
CREATE OR REPLACE FUNCTION trigger_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Loops through all the tables above and creates a trigger for the updated_at column
DO $$
DECLARE
    table_record RECORD;
BEGIN
    FOR table_record IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public'
    LOOP
        EXECUTE format('
            CREATE TRIGGER update_timestamp_%I
            BEFORE UPDATE ON %I
            FOR EACH ROW
            EXECUTE FUNCTION trigger_update_timestamp()
        ', table_record.table_name, table_record.table_name);
    END LOOP;
END $$;