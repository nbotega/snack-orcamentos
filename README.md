# Snack Orçamentos

Plataforma interna da Snack pra cálculo automatizado de orçamentos, com painel de margem ao vivo, simulador de fee, cobertura de overhead e geração de proposta com IA (em breve).

## Stack atual (v0.1)

- Frontend: HTML single-file com Tailwind via CDN
- Backend: Supabase (Postgres + REST)
- Deploy: GitHub Pages (estático)

## Como usar

Abrir `index.html` no navegador, ou acessar a versão deployada (GitHub Pages).

A primeira tela é um login mock — clica em "Entrar com Google" pra entrar. (Auth real virá na próxima fase.)

Tudo que você fizer fica salvo no Supabase em tempo real. O indicador "Tudo salvo / Salvando…" na topbar mostra o status.

## Como subir no GitHub Pages

1. Cria um repositório novo chamado `snack-orcamentos` em [github.com/new](https://github.com/new)
2. Marca como **Public** (necessário pro Pages funcionar no plano grátis)
3. Faz upload dos arquivos desta pasta (botão "Add file" → "Upload files", arrasta tudo)
4. Em Settings → Pages, escolhe branch `main` e pasta `/ (root)`, salva
5. Em ~1 minuto a URL fica disponível: `https://[seu-usuário].github.io/snack-orcamentos/`

## Estrutura

```
snack-orcamentos/
├── index.html       <- aplicação completa (HTML + CSS + JS num arquivo só)
├── README.md        <- este arquivo
└── .gitignore
```

## Banco (Supabase)

Projeto: **snack-orcamentos** (org Nelbotega, região sa-east-1).
URL: `https://jibstoejwfvpzlhymoxe.supabase.co`

Tabelas:

- `cargos` — catálogo (57 cargos × níveis × salário)
- `tipos_orcamento` — 7 tipos com regras próprias
- `premissas` — premissas globais (imposto, encargo, margens, overhead fixo)
- `heads_por_tipo` — % de heads diferenciado por tipo
- `orcamentos` + `orcamento_squad` — orçamentos e squad alocado

RLS está ligado mas com policy aberta (anon pode tudo). Será restrito quando o Google OAuth estiver configurado.

## Próximas fases

- Auth com Google OAuth restrito ao domínio `@snackcontent.com.br`
- Migração pra Next.js (necessário pra integração com Claude API e geração de PDF)
- Geração de proposta PDF via IA (Claude Sonnet)
- Comparador de cenários A/B/C funcional
- Notificações no Slack (margem abaixo do mínimo, proposta aprovada)
- Forecast anual

Veja o documento completo `snack-orcamentos-features-e-roadmap.md` (uma pasta acima, no scratchpad da sessão).
