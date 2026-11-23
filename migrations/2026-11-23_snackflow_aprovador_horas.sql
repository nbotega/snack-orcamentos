-- Cadastro de usuário SnackFlow: Aprovador de horas (Asana 1220828901584706)
-- Rodar no Supabase (projeto jibstoejwfvpzlhymoxe) ANTES ou logo depois do merge.
-- Idempotente. Enquanto não rodar, a plataforma continua funcionando: o restante do cadastro
-- salva normalmente e só o Aprovador de horas não é gravado (a tela avisa).

ALTER TABLE public.usuarios_acesso
  ADD COLUMN IF NOT EXISTS aprovador_horas_email TEXT;   -- email do usuário (usuarios_acesso.email) que aprova as horas desta pessoa (escolha única)

COMMENT ON COLUMN public.usuarios_acesso.aprovador_horas_email IS 'Aprovador de horas no SnackFlow (escolha única entre os usuários cadastrados). Perguntado ao liberar o SnackFlow.';
