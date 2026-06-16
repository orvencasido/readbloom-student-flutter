# ReadBloom Student Flutter

Flutter reading app that loads reading passages and quiz questions from Supabase.

## Supabase setup

Run [supabase/schema.sql](/home/orven/Documents/thesis/readbloom/readbloom-student-flutter/supabase/schema.sql) in the Supabase SQL editor. It creates:

- `books`
- `quiz_questions`
- `profiles`
- `student_progress`
- `completed_books`
- public read policies for active books and their quiz questions
- per-user policies for profile and progress data
- an auth trigger that creates a profile/progress row when a user signs up
- a `complete_book(book_id)` RPC that records finished books once per user

Add one row to `books`, then add related rows to `quiz_questions` using the book's `id`.

Example `quiz_questions.choices` value:

```json
["Choice A", "Choice B", "Choice C"]
```

## Auth flow

Signup creates a Supabase Auth user with:

- full name
- email
- password
- section
- year level

The database trigger copies the signup metadata into `profiles` and creates a starter `student_progress` row with `books_completed = 0` and `days_streak = 0`.

The safety/privacy agreement is stored in `profiles.privacy_agreed_at`. Once it is set, the app skips the agreement screen on future logins.

## Running the app

Provide your Supabase project values at runtime:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

Without these values, the app opens but the home book list shows a setup error instead of dummy content.
