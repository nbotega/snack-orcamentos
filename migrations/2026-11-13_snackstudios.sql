-- Módulo SnackStudios — agenda dos estúdios (Asana 1220514744226023)
-- Rodar no Supabase (projeto jibstoejwfvpzlhymoxe) ANTES ou logo depois do merge. Idempotente.
-- Enquanto não rodar, o módulo abre e mostra um aviso ("falta ativar no banco") em vez de quebrar.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- necessário pra trava de conflito de horário

CREATE TABLE IF NOT EXISTS public.studio_agendamentos (
  id                      BIGSERIAL PRIMARY KEY,
  nome                    TEXT NOT NULL,                       -- Nome da gravação
  orcamento_id            TEXT,                                -- orçamento aprovado (orcamentos.id); sem FK pra não travar renomeação/exclusão
  cliente                 TEXT,                                -- copiado do orçamento no momento do agendamento (destaque no evento)
  projeto                 TEXT,
  estudio                 TEXT NOT NULL CHECK (estudio IN ('A','B','C')),
  inicio                  TIMESTAMPTZ NOT NULL,
  fim                     TIMESTAMPTZ NOT NULL,
  descricao               TEXT,
  participantes_internos  TEXT[] NOT NULL DEFAULT '{}',        -- e-mails de usuarios_acesso
  participantes_externos  TEXT,
  anexos                  JSONB NOT NULL DEFAULT '[]',         -- [{nome, path, por, em}] — arquivos no bucket privado "comprovantes", pasta studios/
  pais                    TEXT NOT NULL DEFAULT 'BR',          -- unidade de quem agendou (informativo; a agenda é única)
  created_by              TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT studio_agendamentos_periodo CHECK (fim > inicio)
);

CREATE INDEX IF NOT EXISTS studio_agendamentos_inicio_idx ON public.studio_agendamentos (inicio);

-- Trava no banco: dois agendamentos do mesmo estúdio não podem se sobrepor
-- (o app já checa antes de salvar; isto cobre dois usuários salvando ao mesmo tempo).
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'studio_agendamentos_sem_conflito') THEN
    ALTER TABLE public.studio_agendamentos
      ADD CONSTRAINT studio_agendamentos_sem_conflito
      EXCLUDE USING gist (estudio WITH =, tstzrange(inicio, fim) WITH &&);
  END IF;
END $$;

-- RLS no mesmo padrão das demais tabelas de módulo (backlog_status, pipeline_deals, sf_*):
-- qualquer usuário autenticado lê e grava; o controle de quem vê a aba é feito em usuarios_acesso.
ALTER TABLE public.studio_agendamentos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS studio_agendamentos_all ON public.studio_agendamentos;
CREATE POLICY studio_agendamentos_all ON public.studio_agendamentos
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Storage: NÃO precisa de bucket novo. Os arquivos vão pro bucket privado já existente
-- "comprovantes" (mesmo da Nota Rápida e do SnackFlow), na pasta studios/, e abrem por link assinado de 5 min.
