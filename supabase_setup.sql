-- 나랑 나갈래? Supabase 테이블 설정
-- Supabase > SQL Editor 에서 실행하세요

create table if not exists rooms (
  id uuid default gen_random_uuid() primary key,
  code text unique not null,
  host_id text not null,
  status text default 'waiting',
  stage integer default 0,
  question_idx integer default 0,
  custom_q text default null,
  created_at timestamptz default now()
);

create table if not exists players (
  id text not null,
  room_id uuid references rooms(id) on delete cascade,
  name text default '',
  char_id integer default -1,
  emoji text default '',
  color text default '',
  bg text default '',
  is_host boolean default false,
  joined_at timestamptz default now(),
  primary key (room_id, id)
);

create table if not exists answers (
  id uuid default gen_random_uuid() primary key,
  room_id uuid references rooms(id) on delete cascade,
  player_id text not null,
  stage integer not null,
  question_idx integer not null,
  choice text not null,
  unique(room_id, player_id, stage, question_idx)
);

create table if not exists final_choices (
  room_id uuid references rooms(id) on delete cascade,
  player_id text not null,
  target_id text not null,
  primary key (room_id, player_id)
);

-- RLS 비활성화 (프로토타입용)
alter table rooms disable row level security;
alter table players disable row level security;
alter table answers disable row level security;
alter table final_choices disable row level security;

-- Realtime 활성화
alter publication supabase_realtime add table rooms;
alter publication supabase_realtime add table players;
alter publication supabase_realtime add table answers;
alter publication supabase_realtime add table final_choices;

-- 기존 DB에 custom_q 컬럼 추가 (이미 테이블이 있는 경우 이 줄만 실행)
alter table rooms add column if not exists custom_q text default null;
