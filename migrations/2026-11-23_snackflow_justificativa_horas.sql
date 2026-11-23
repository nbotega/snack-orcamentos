-- SnackFlow: justificativa obrigatória pra horas lançadas no nível de projeto (Asana 1220828901584716)
-- Rodar no Supabase (projeto jibstoejwfvpzlhymoxe) ANTES ou logo depois do merge.
-- Idempotente. Enquanto não rodar, a plataforma continua funcionando: a justificativa (que a tela
-- já exige pra horas sem tarefa) é gravada no fim da descrição do lançamento ("Justificativa: ...").

ALTER TABLE public.sf_timesheets
  ADD COLUMN IF NOT EXISTS justificativa TEXT;   -- obrigatória (na tela) quando tarefa_id é nulo, ou seja, horas lançadas direto no projeto

COMMENT ON COLUMN public.sf_timesheets.justificativa IS 'Justificativa de horas lançadas no nível de projeto (sem tarefa). Exigida pela tela antes de ir pro aprovador; vazia quando há tarefa.';
