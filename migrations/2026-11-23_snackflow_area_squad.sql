-- Cadastro de usuário SnackFlow: Área e Squad (Asana 1220828901584706)
-- Rodar no Supabase (projeto jibstoejwfvpzlhymoxe) ANTES ou logo depois do merge.
-- Idempotente. Enquanto não rodar, a plataforma continua funcionando: o restante do cadastro
-- salva normalmente e só Área / Squad não são gravados (a tela avisa).

ALTER TABLE public.usuarios_acesso
  ADD COLUMN IF NOT EXISTS areas  TEXT[] NOT NULL DEFAULT '{}',   -- áreas do usuário no SnackFlow (múltipla escolha)
  ADD COLUMN IF NOT EXISTS squads TEXT[] NOT NULL DEFAULT '{}';   -- squads do usuário no SnackFlow (múltipla escolha)

-- Travas: só valores das listas fixas (as mesmas de SF_AREAS / SF_SQUADS no index.html).
-- Se uma lista mudar no app, é preciso recriar a constraint correspondente.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'usuarios_acesso_areas_validas') THEN
    ALTER TABLE public.usuarios_acesso
      ADD CONSTRAINT usuarios_acesso_areas_validas CHECK (
        areas <@ ARRAY['Casting','Inteligência','Produção','Edição','Commerce','Atendimento','Conteúdo','Planejamento','Operações','Financeiro','Projetos']::TEXT[]
      );
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'usuarios_acesso_squads_validos') THEN
    ALTER TABLE public.usuarios_acesso
      ADD CONSTRAINT usuarios_acesso_squads_validos CHECK (
        squads <@ ARRAY['Alpha','Omega','Delta','Sigma','Gamma']::TEXT[]
      );
  END IF;
END $$;

COMMENT ON COLUMN public.usuarios_acesso.areas IS 'Áreas do usuário (múltipla escolha, lista fixa). Perguntado ao liberar o SnackFlow.';
COMMENT ON COLUMN public.usuarios_acesso.squads IS 'Squads do usuário (múltipla escolha: Alpha, Omega, Delta, Sigma, Gamma). Perguntado ao liberar o SnackFlow.';
