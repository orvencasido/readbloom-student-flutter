create extension if not exists pgcrypto;

create table if not exists public.books (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  book_number integer not null,
  level integer not null default 1,
  passage text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  book_id uuid not null references public.books(id) on delete cascade,
  question text not null,
  choices jsonb not null,
  answer_index integer not null default 0,
  order_number integer not null,
  created_at timestamptz not null default now(),
  constraint quiz_questions_choices_array check (jsonb_typeof(choices) = 'array'),
  constraint quiz_questions_answer_index_non_negative check (answer_index >= 0)
);

create index if not exists books_active_book_number_idx
  on public.books (is_active, book_number);

create index if not exists quiz_questions_book_order_idx
  on public.quiz_questions (book_id, order_number);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null,
  section text not null,
  year_level text not null,
  privacy_agreed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.student_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  books_completed integer not null default 0,
  days_streak integer not null default 0,
  reading_level integer not null default 1,
  fluency_level integer not null default 1,
  comprehension_level integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint student_progress_books_completed_non_negative check (books_completed >= 0),
  constraint student_progress_days_streak_non_negative check (days_streak >= 0)
);

alter table public.student_progress
  add column if not exists reading_level integer not null default 1,
  add column if not exists fluency_level integer not null default 1,
  add column if not exists comprehension_level integer not null default 1;

create table if not exists public.completed_books (
  user_id uuid not null references auth.users(id) on delete cascade,
  book_id uuid not null references public.books(id) on delete cascade,
  completed_at timestamptz not null default now(),
  primary key (user_id, book_id)
);

create table if not exists public.reading_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  book_id uuid not null references public.books(id) on delete cascade,
  video_path text not null,
  transcript text not null default '',
  duration_seconds integer not null default 0,
  quiz_answers jsonb not null,
  correct_answers integer not null,
  total_questions integer not null,
  submitted_at timestamptz not null default now(),
  constraint reading_submissions_duration_non_negative check (duration_seconds >= 0),
  constraint reading_submissions_answers_array check (jsonb_typeof(quiz_answers) = 'array'),
  constraint reading_submissions_perfect_score check (
    total_questions > 0 and correct_answers = total_questions
  ),
  unique (user_id, book_id)
);

create index if not exists reading_submissions_user_submitted_idx
  on public.reading_submissions (user_id, submitted_at desc);

insert into storage.buckets (id, name, public)
values ('reading-recordings', 'reading-recordings', false)
on conflict (id) do update set public = false;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row
  execute function public.set_updated_at();

drop trigger if exists student_progress_set_updated_at on public.student_progress;
create trigger student_progress_set_updated_at
  before update on public.student_progress
  for each row
  execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (
    id,
    full_name,
    email,
    section,
    year_level
  )
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'section', ''),
    coalesce(new.raw_user_meta_data ->> 'year_level', '')
  )
  on conflict (id) do update set
    full_name = excluded.full_name,
    email = excluded.email,
    section = excluded.section,
    year_level = excluded.year_level;

  insert into public.student_progress (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

create or replace function public.complete_book(p_book_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  inserted_count integer;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  insert into public.completed_books (user_id, book_id)
  values (auth.uid(), p_book_id)
  on conflict do nothing;

  get diagnostics inserted_count = row_count;

  insert into public.student_progress (user_id, books_completed)
  values (auth.uid(), inserted_count)
  on conflict (user_id) do update set
    books_completed = public.student_progress.books_completed + inserted_count;
end;
$$;

create or replace function public.finalize_reading_submission(
  p_book_id uuid,
  p_video_path text,
  p_transcript text,
  p_duration_seconds integer,
  p_answers jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  question_count integer;
  correct_count integer;
  inserted_count integer;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if p_video_path not like (auth.uid()::text || '/%') then
    raise exception 'Invalid recording path';
  end if;

  if jsonb_typeof(p_answers) <> 'array' then
    raise exception 'Quiz answers must be an array';
  end if;

  select count(*) into question_count
  from public.quiz_questions
  where book_id = p_book_id;

  if question_count = 0 or jsonb_array_length(p_answers) <> question_count then
    raise exception 'Every quiz question must be answered';
  end if;

  select count(*) into correct_count
  from jsonb_array_elements_text(p_answers) with ordinality answer(value, position)
  join (
    select answer_index, row_number() over (order by order_number) as position
    from public.quiz_questions
    where book_id = p_book_id
  ) question on question.position = answer.position
  where question.answer_index = answer.value::integer;

  if correct_count <> question_count then
    raise exception 'A perfect quiz score is required to unlock the next passage';
  end if;

  insert into public.reading_submissions (
    user_id, book_id, video_path, transcript, duration_seconds,
    quiz_answers, correct_answers, total_questions
  ) values (
    auth.uid(), p_book_id, p_video_path, coalesce(p_transcript, ''),
    greatest(coalesce(p_duration_seconds, 0), 0), p_answers,
    correct_count, question_count
  )
  on conflict (user_id, book_id) do update set
    video_path = excluded.video_path,
    transcript = excluded.transcript,
    duration_seconds = excluded.duration_seconds,
    quiz_answers = excluded.quiz_answers,
    correct_answers = excluded.correct_answers,
    total_questions = excluded.total_questions,
    submitted_at = now();

  insert into public.completed_books (user_id, book_id)
  values (auth.uid(), p_book_id)
  on conflict do nothing;
  get diagnostics inserted_count = row_count;

  insert into public.student_progress (user_id, books_completed)
  values (auth.uid(), inserted_count)
  on conflict (user_id) do update set
    books_completed = public.student_progress.books_completed + inserted_count;
end;
$$;

revoke execute on function public.complete_book(uuid) from public, anon, authenticated;
revoke execute on function public.finalize_reading_submission(uuid, text, text, integer, jsonb) from public, anon;
grant execute on function public.finalize_reading_submission(uuid, text, text, integer, jsonb) to authenticated;

alter table public.books enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.profiles enable row level security;
alter table public.student_progress enable row level security;
alter table public.completed_books enable row level security;
alter table public.reading_submissions enable row level security;

drop policy if exists "Anyone can read active books" on public.books;
create policy "Anyone can read active books"
  on public.books
  for select
  using (is_active = true);

drop policy if exists "Anyone can read quiz questions for active books" on public.quiz_questions;
create policy "Anyone can read quiz questions for active books"
  on public.quiz_questions
  for select
  using (
    exists (
      select 1
      from public.books
      where books.id = quiz_questions.book_id
        and books.is_active = true
    )
  );

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile"
  on public.profiles
  for select
  using (auth.uid() = id);

drop policy if exists "Users can create own profile" on public.profiles;
create policy "Users can create own profile"
  on public.profiles
  for insert
  with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "Users can read own progress" on public.student_progress;
create policy "Users can read own progress"
  on public.student_progress
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can create own progress" on public.student_progress;
create policy "Users can create own progress"
  on public.student_progress
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can read own completed books" on public.completed_books;
create policy "Users can read own completed books"
  on public.completed_books
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can read own reading submissions" on public.reading_submissions;
create policy "Users can read own reading submissions"
  on public.reading_submissions
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can upload own reading recordings" on storage.objects;
create policy "Users can upload own reading recordings"
  on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'reading-recordings'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Users can read own reading recordings" on storage.objects;
create policy "Users can read own reading recordings"
  on storage.objects
  for select to authenticated
  using (
    bucket_id = 'reading-recordings'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Users can delete own reading recordings" on storage.objects;
create policy "Users can delete own reading recordings"
  on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'reading-recordings'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
