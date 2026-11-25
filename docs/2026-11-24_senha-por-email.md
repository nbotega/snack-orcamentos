# Senha por e-mail (convite / esqueci minha senha) — configuração do Supabase

Asana 1220859935079879 "Senha de usuários".

## Como funciona no app
1. Admin em **Usuários** > pessoa "sem login" > **Criar login** > opção padrão **Enviar convite por e-mail**.
   O app cria o login com uma senha aleatória que ninguém vê (RPC `admin_definir_senha`, a mesma de antes)
   e pede ao Supabase o e-mail de definição de senha (`supabase.auth.resetPasswordForEmail`, com `redirectTo` = URL do app).
2. A pessoa clica no link do e-mail, volta para o app e cai na tela **"Crie sua senha"**; ao salvar
   (`supabase.auth.updateUser({ password })`) ela já entra na plataforma.
3. Quem já tem login: **Trocar senha** abre a mesma janela com **Enviar link por e-mail** (padrão) ou definir manualmente.
   Para outro administrador (cuja senha o admin não pode definir) aparece **Enviar link de senha**.
4. Tela de login: **Receber link por e-mail** (esqueci minha senha / primeiro acesso).
5. Link expirado ou já usado: a tela de login avisa e orienta a pedir outro.
6. A opção antiga (admin digita a senha) continua disponível em **Definir a senha agora**.

Não precisa de migration nem de edge function: tudo usa a chave pública (anon) e a RPC que já existe.

## O que precisa ser configurado no Supabase (projeto jibstoejwfvpzlhymoxe)
Sem isso o e-mail sai com link para o lugar errado / em inglês / com limite muito baixo.

1. **Authentication > URL Configuration**
   - **Site URL**: `https://snack-orcamentos.vercel.app`
   - **Redirect URLs** (adicionar):
     - `https://snack-orcamentos.vercel.app/**`
     - (opcional, para testar nos previews) `https://snack-orcamentos-*-nelbotega-6500s-projects.vercel.app/**`
   Se o `redirectTo` não estiver na lista, o Supabase manda a pessoa para a Site URL.
2. **Authentication > Emails > SMTP Settings**: ligar **SMTP próprio** (ex.: Google Workspace, Resend, SendGrid, Amazon SES),
   remetente tipo `nao-responda@redesnack.com.br`. O SMTP padrão do Supabase só envia poucos e-mails por hora e não é para produção.
   Depois disso, ajustar em **Authentication > Rate Limits** o limite de e-mails por hora.
3. **Authentication > Emails > Templates > Reset Password** (é o e-mail usado no convite e no "esqueci a senha"):
   - Assunto: `Crie sua senha na Snack Orçamentos`
   - Corpo:
     ```html
     <h2>Olá!</h2>
     <p>Recebemos um pedido para criar ou trocar a sua senha de acesso à plataforma Snack Orçamentos.</p>
     <p><a href="{{ .ConfirmationURL }}">Clique aqui para criar sua senha</a></p>
     <p>O link vale por tempo limitado e só pode ser usado uma vez. Se expirar, peça um novo na tela de login em "Receber link por e-mail".</p>
     <p>Se você não pediu isso, ignore este e-mail.</p>
     ```
4. (Opcional) **Authentication > Providers > Email**: o tempo de validade do link (OTP expiry, padrão 1h) pode ser aumentado
   (ex.: 24h = 86400 s) para convites.

Só funciona de ponta a ponta depois dos itens 1 a 3.
