-- Políticas RLS para a tabela kv (path, col, data).
-- ATENÇÃO: aplique SÓ depois de o gestor passar a entrar com Supabase Auth (email+palavra-passe).
-- Se aplicar agora, a gestão deixa de gravar, porque hoje o login é feito no navegador com a chave anónima.

alter table public.kv enable row level security;
drop policy if exists "kv_all" on public.kv;
drop policy if exists "kv_anon_read" on public.kv;
drop policy if exists "kv_anon_rsvp_insert" on public.kv;
drop policy if exists "kv_anon_rsvp_update" on public.kv;
drop policy if exists "kv_gestor_all" on public.kv;

-- Gestor autenticado: acesso total
create policy "kv_gestor_all" on public.kv for all to authenticated using (true) with check (true);

-- Público (anon): só lê convites, configuração do evento e respostas
create policy "kv_anon_read" on public.kv for select to anon
  using (col like 'guests%' or col like 'rsvp%' or col like 'config%');

-- Público (anon): só cria/atualiza respostas RSVP; nunca apaga
create policy "kv_anon_rsvp_insert" on public.kv for insert to anon
  with check (col like 'rsvp%' and path like 'rsvp%');
create policy "kv_anon_rsvp_update" on public.kv for update to anon
  using (col like 'rsvp%') with check (col like 'rsvp%' and path like 'rsvp%');

-- Limite de tamanho nas respostas públicas
alter table public.kv drop constraint if exists kv_data_size;
alter table public.kv add constraint kv_data_size check (pg_column_size(data) < 200000);

-- Depois do login por Auth, apague o hash antigo do gestor em config/main (campo "h").
