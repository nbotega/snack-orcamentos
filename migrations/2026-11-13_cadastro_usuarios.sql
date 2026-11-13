-- Cadastro de usuários (Asana 1220514547878443)
-- Rodar no Supabase (projeto jibstoejwfvpzlhymoxe) ANTES ou logo depois do merge.
-- Idempotente. Enquanto não rodar, a plataforma continua funcionando: nome e permissões
-- salvam normalmente, e foto / superior direto / elegibilidade ao timesheet só não são gravados
-- (a tela avisa).

ALTER TABLE public.usuarios_acesso
  ADD COLUMN IF NOT EXISTS foto TEXT,                                   -- data URL JPEG 160x160 (~10 KB), redimensionada no navegador
  ADD COLUMN IF NOT EXISTS superior_email TEXT,                         -- e-mail do superior direto (outro usuário cadastrado)
  ADD COLUMN IF NOT EXISTS timesheet_elegivel BOOLEAN NOT NULL DEFAULT true;  -- elegível ao preenchimento de horas no SnackFlow

-- Trava de tamanho pra foto não inflar a tabela (data URL de até ~60 KB)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'usuarios_acesso_foto_tamanho') THEN
    ALTER TABLE public.usuarios_acesso
      ADD CONSTRAINT usuarios_acesso_foto_tamanho CHECK (foto IS NULL OR length(foto) <= 80000);
  END IF;
END $$;

COMMENT ON COLUMN public.usuarios_acesso.foto IS 'Foto do usuário como data URL (JPEG 160x160 gerado no navegador). Não usa Storage.';
COMMENT ON COLUMN public.usuarios_acesso.superior_email IS 'Superior direto (e-mail de outro registro de usuarios_acesso). Perguntado ao liberar o SnackFlow.';
COMMENT ON COLUMN public.usuarios_acesso.timesheet_elegivel IS 'Se false, o usuário não lança horas no timesheet do SnackFlow.';
