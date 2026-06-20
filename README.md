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

## Recorded-video transcription

Speech recognition runs after recording so Android can preserve the video's
audio. Android copies the recorded video's existing AAC audio track into a
temporary M4A file without re-recording or re-encoding it. The original video
is uploaded to `reading-recordings`; only the temporary audio is uploaded to
`transcription-audio` and sent to OpenAI. Both the app and Edge Function clean
up temporary audio. The returned text is stored in
`reading_submissions.transcript` when the learner turns in the quiz.

Set the server-side OpenAI key and deploy the function:

```bash
supabase secrets set OPENAI_API_KEY=your-openai-api-key
supabase functions deploy transcribe-recording --no-verify-jwt
```

Run `supabase/schema.sql` again before deploying so the private
`transcription-audio` bucket and its per-user policies exist.

Never put `OPENAI_API_KEY` in Flutter or pass it with `--dart-define`. The
function validates the signed-in user itself before reading the private file.
The `--no-verify-jwt` option only disables the Edge gateway's legacy JWT check;
it does not make the function public. The
current transcription API accepts MP4 input up to 25 MB, so recordings above
that size need server-side audio extraction/chunking before transcription.
