-- Laboratory Work 3, variant 23: Breath-motion exercises.
-- PostgreSQL relational physical schema.
-- Camera frames stay in the browser; only body landmarks are persisted.

create TABLE users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);

CREATE TABLE exercises (
    exercise_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    exercise_name VARCHAR(150) NOT NULL,
    short_description VARCHAR(500) NOT NULL,
    CONSTRAINT exercises_name_not_empty CHECK (
        LENGTH(BTRIM(exercise_name)) > 0
    ),
    CONSTRAINT exercises_name_regex CHECK (
        exercise_name ~ '^[[:alnum:] -]+$'
    ),
    CONSTRAINT exercises_description_not_empty CHECK (
        LENGTH(BTRIM(short_description)) > 0
    )
);

CREATE TABLE exercise_phases (
    phase_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    exercise_id BIGINT NOT NULL REFERENCES exercises (exercise_id),
    phase_order INTEGER NOT NULL,
    phase_kind VARCHAR(10) NOT NULL,
    duration_seconds NUMERIC(6, 2) NOT NULL,
    movement_instruction TEXT NOT NULL,
    CONSTRAINT phases_order_positive CHECK (phase_order > 0),
    CONSTRAINT phases_kind_check CHECK (
        phase_kind IN ('inhale', 'exhale', 'pause')
    ),
    CONSTRAINT phases_duration_check CHECK (
        duration_seconds > 0 AND duration_seconds <= 300
    ),
    CONSTRAINT phases_instruction_not_empty CHECK (
        LENGTH(BTRIM(movement_instruction)) > 0
    ),
    CONSTRAINT phases_order_unique UNIQUE (exercise_id, phase_order)
);

CREATE TABLE sessions (
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (user_id),
    exercise_id BIGINT NOT NULL REFERENCES exercises (exercise_id),
    started_at TIMESTAMP NOT NULL,
    finished_at TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT sessions_time_check CHECK (
        finished_at IS NULL OR finished_at >= started_at
    ),
    CONSTRAINT sessions_status_check CHECK (
        status IN ('active', 'completed', 'interrupted')
    )
);

CREATE TABLE bodyposes (
    body_pose_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    session_id BIGINT NOT NULL REFERENCES sessions (session_id),
    detected_at TIMESTAMP NOT NULL,
    landmark_positions JSONB NOT NULL,
    CONSTRAINT bodyposes_landmarks_check CHECK (
        JSONB_TYPEOF(landmark_positions) = 'object'
        AND landmark_positions <> '{}'::JSONB
    )
);

CREATE TABLE movement_checks (
    movement_check_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    body_pose_id BIGINT NOT NULL REFERENCES bodyposes (body_pose_id),
    phase_id BIGINT NOT NULL REFERENCES exercise_phases (phase_id),
    checked_at TIMESTAMP NOT NULL,
    matches_phase BOOLEAN NOT NULL,
    difference_description VARCHAR(1000),
    CONSTRAINT checks_deviation_consistent CHECK (
        (matches_phase AND difference_description IS NULL)
        OR (
            NOT matches_phase
            AND difference_description IS NOT NULL
            AND LENGTH(BTRIM(difference_description)) > 0
        )
    )
);

CREATE TABLE hints (
    hint_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    movement_check_id BIGINT NOT NULL UNIQUE
    REFERENCES movement_checks (movement_check_id),
    hint_text TEXT NOT NULL,
    appeared_at TIMESTAMP NOT NULL,
    CONSTRAINT hints_text_not_empty CHECK (
        LENGTH(BTRIM(hint_text)) > 0
    ),
    CONSTRAINT hints_text_regex CHECK (
        hint_text ~ '^[^[:cntrl:]]+$'
    )
);
