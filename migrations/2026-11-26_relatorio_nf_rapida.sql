-- Relatório de Nota rápida (todas as notas, pendentes e validadas).
-- Permissão em usuarios_acesso.relatorio_nf_rapida — sem e-mails no código da plataforma.
-- Esta migração libera a flag para Ana Guerra e Nick (contas já existentes, identificadas pelo id do Auth).
-- Idempotente. Rodar no projeto jibstoejwfvpzlhymoxe antes ou logo depois do merge.

ALTER TABLE public.usuarios_acesso
  ADD COLUMN IF NOT EXISTS relatorio_nf_rapida boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.usuarios_acesso.relatorio_nf_rapida IS
  'Pode gerar o relatório de todas as notas rápidas (pendentes e validadas). Liberado em Configuração → Usuários.';

-- Ana Guerra: fdf185e3-1993-4765-963d-17f18d41454f
-- Nick (conta financeiro da plataforma): bbb20865-ecfe-4e49-a7f1-984ac3fe281b
UPDATE public.usuarios_acesso ua
SET relatorio_nf_rapida = true
FROM auth.users u
WHERE lower(u.email) = lower(ua.email)
  AND ua.ativo IS NOT FALSE
  AND u.id IN (
    'fdf185e3-1993-4765-963d-17f18d41454f',
    'bbb20865-ecfe-4e49-a7f1-984ac3fe281b'
  );

CREATE OR REPLACE FUNCTION public.usuario_pode_relatorio_nf_rapida()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE((
    SELECT relatorio_nf_rapida AND ativo IS NOT FALSE
    FROM public.usuarios_acesso
    WHERE lower(email) = lower(auth.jwt()->>'email')
    LIMIT 1
  ), false);
$$;

CREATE OR REPLACE FUNCTION public.nf_rapida_relatorio(
  p_status text DEFAULT 'todas',
  p_de date DEFAULT NULL,
  p_ate date DEFAULT NULL,
  p_pais text DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  orcamento_id text,
  valor numeric,
  tipo text,
  final_cartao text,
  data_compra date,
  observacoes text,
  status text,
  registrado_por text,
  registrado_em timestamptz,
  anexo_path text,
  pais text
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_status text := lower(coalesce(nullif(trim(p_status), ''), 'todas'));
BEGIN
  IF NOT public.usuario_pode_relatorio_nf_rapida() THEN
    RAISE EXCEPTION 'not_authorized' USING ERRCODE = '42501';
  END IF;
  IF v_status NOT IN ('todas', 'pendente', 'validada') THEN
    RAISE EXCEPTION 'invalid_status' USING ERRCODE = '22023';
  END IF;

  RETURN QUERY
  SELECT
    p.id,
    p.orcamento_id,
    p.valor,
    p.descricao,
    p.final_cartao,
    p.data_compra,
    p.obs,
    CASE WHEN p.validado THEN 'Validada'::text ELSE 'Pendente'::text END,
    COALESCE(
      nullif(trim(ua.nome), ''),
      nullif(trim(u.raw_user_meta_data->>'nome'), ''),
      nullif(trim(u.raw_user_meta_data->>'name'), ''),
      '—'
    ),
    COALESCE(p.created_at, (p.data_pagamento::timestamp AT TIME ZONE 'UTC')),
    p.anexo_url,
    p.pais
  FROM public.pagamentos p
  LEFT JOIN auth.users u ON u.id = p.created_by
  LEFT JOIN public.usuarios_acesso ua ON lower(ua.email) = lower(u.email)
  WHERE p.origem = 'nota_rapida'
    AND (p_pais IS NULL OR p_pais = '' OR p.pais = p_pais)
    AND (
      v_status = 'todas'
      OR (v_status = 'pendente' AND p.validado IS NOT TRUE)
      OR (v_status = 'validada' AND p.validado IS TRUE)
    )
    AND (p_de IS NULL OR p.data_compra >= p_de)
    AND (p_ate IS NULL OR p.data_compra <= p_ate)
  ORDER BY p.data_compra DESC NULLS LAST, p.created_at DESC;
END;
$$;

REVOKE ALL ON FUNCTION public.usuario_pode_relatorio_nf_rapida() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.nf_rapida_relatorio(text, date, date, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.usuario_pode_relatorio_nf_rapida() TO authenticated;
GRANT EXECUTE ON FUNCTION public.nf_rapida_relatorio(text, date, date, text) TO authenticated;
