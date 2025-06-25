Dashboard IoT - Máquina Separadora (Flutter + Supabase)
Este projeto é uma solução completa de monitoramento para uma Máquina Separadora, construído com uma arquitetura moderna baseada em Flutter e Supabase. A aplicação exibe em tempo real dados de produção gerados por um simulador em Node-RED, que insere os dados diretamente em um banco de dados PostgreSQL gerenciado pelo Supabase.

O aplicativo Flutter consome a API auto-gerada do Supabase para exibir dashboards, gráficos e relatórios detalhados.

🏛️ Arquitetura do Projeto
O fluxo de dados segue o seguinte caminho:

[Simulador em Node-RED] ---- (Gera e envia dados aleatórios) ----> [API do Supabase] ----> [Banco de Dados PostgreSQL]
                                                                                                   ^
                                                                                                   |
                                                                                        (App busca dados via API)
                                                                                                   |
                                                                                            [Aplicativo Flutter]



✨ Funcionalidades
Dashboard em Tempo Real: Atualização automática para exibir os dados mais recentes do Supabase.
Gráficos Interativos: Gráficos de pizza e barras para visualizar a distribuição da produção por cor, tamanho e material.
Feed de Atividades Recentes: Tabela que exibe os últimos itens processados, lidos diretamente do banco.
Arquitetura Serverless: Utiliza o Supabase como BaaS (Backend as a Service), eliminando a necessidade de gerenciar um servidor próprio.
Simulação de Dispositivo IoT: O Node-RED atua como um simulador de dispositivo IoT, gerando e inserindo dados de produção de forma contínua.
🛠️ Tecnologias Utilizadas
Frontend
Flutter: Framework da Google para criar interfaces nativas para mobile e web a partir de uma única base de código.
Dart: Linguagem de programação utilizada pelo Flutter.
supabase_flutter: Cliente oficial do Supabase para Dart, usado para autenticação e interação com o banco de dados.
fl_chart / syncfusion_flutter_charts: Bibliotecas populares de gráficos para Flutter.
Backend (BaaS)
Supabase: Plataforma open-source que oferece banco de dados PostgreSQL, API REST auto-gerada, autenticação e mais.
Banco de Dados
PostgreSQL: Banco de dados relacional robusto e escalável, gerenciado pelo Supabase.
Simulador de Dados
Node-RED: Ferramenta de programação visual baseada em fluxos, utilizada aqui para simular a geração de dados da máquina.
🚀 Como Executar o Projeto
Siga os passos abaixo para configurar todo o ambiente.

Pré-requisitos
Flutter SDK
Uma conta gratuita no Supabase
Node.js e Node-RED instalados globalmente (npm install -g --unsafe-perm node-red)
1. Configurar o Supabase
Crie um novo projeto no seu painel do Supabase.
Vá para o "SQL Editor" e execute o script para criar as tabelas (ver schema.sql no repositório).
Vá para Project Settings > API. Guarde a sua Project URL e a sua chave anon public.
2. Configurar o Node-RED
Inicie o Node-RED no seu terminal com o comando node-red.
Acesse o editor no seu navegador (geralmente http://127.0.0.1:1880).
Importe o arquivo flow.json do repositório (Menu > Import).
Configure os nós que se conectam ao Supabase, inserindo a URL e a chave anon que você copiou no passo anterior.
Dê "Deploy" no fluxo para que ele comece a gerar e inserir dados no seu banco Supabase.
3. Configurar o Frontend (Flutter)
Clone este repositório:



git clone https://github.com/Victorow/MAQUINA-SEPARADORA.git
cd MAQUINA-SEPARADORA
Crie um arquivo de configuração para suas chaves do Supabase. Por exemplo, crie lib/env.dart:

Dart

// lib/env.dart
abstract class Env {
  static const supabaseUrl = 'SUA_URL_DO_SUPABASE_AQUI';
  static const supabaseAnonKey = 'SUA_CHAVE_ANON_AQUI';
}
Substitua pelos valores do seu projeto Supabase.

Instale as dependências do Flutter:


flutter pub get

Execute o aplicativo:


flutter run
Escolha o dispositivo desejado (emulador, navegador Chrome, etc.) para rodar o app.
🗄️ Schema do Banco de Dados (PostgreSQL)
O schema utilizado no Supabase para este projeto:

SQL

-- Tabela para as cores
CREATE TABLE tb_cor (
  id_cor SERIAL PRIMARY KEY,
  cor VARCHAR(50) UNIQUE NOT NULL
);

-- Tabela para os materiais
CREATE TABLE tb_material (
  id_material SERIAL PRIMARY KEY,
  material VARCHAR(50) UNIQUE NOT NULL
);

-- Tabela para os tamanhos
CREATE TABLE tb_tamanho (
  id_tamanho SERIAL PRIMARY KEY,
  tamanho VARCHAR(50) UNIQUE NOT NULL
);

-- Tabela principal de produção
CREATE TABLE tb_prod (
  id_prod SERIAL PRIMARY KEY,
  data_hora TIMESTAMPTZ DEFAULT NOW(),
  cor INT REFERENCES tb_cor(id_cor),
  material INT REFERENCES tb_material(id_material),
  tamanho INT REFERENCES tb_tamanho(id_tamanho)
);
