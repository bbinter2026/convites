-- Armazenamento das imagens dos convites (Supabase Storage).
-- Execute no SQL Editor. A app funciona mesmo sem isto (guarda as imagens dentro do convite),
-- mas com isto passa a guardar só o link, e o guardar fica muito mais rápido.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('convites','convites', true, 3145728, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update
  set public = true, file_size_limit = 3145728,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "convites_upload" on storage.objects;
drop policy if exists "convites_apagar" on storage.objects;

-- Quem usa a app (gestor ou cliente com licença) envia imagens; só ficheiros novos (sem substituir)
create policy "convites_upload" on storage.objects for insert to anon, authenticated
  with check (bucket_id = 'convites');

-- Só o gestor autenticado apaga imagens
create policy "convites_apagar" on storage.objects for delete to authenticated
  using (bucket_id = 'convites');
