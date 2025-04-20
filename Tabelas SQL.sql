
-- Tabela de usuários
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL
);

-- Tabela de carteira para armazenar o saldo atual do usuário
CREATE TABLE carteira (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id),
  saldo NUMERIC(10, 2) DEFAULT 0.00
);

-- Tabela de entradas (depósitos)
CREATE TABLE entradas (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id),
  valor NUMERIC(10, 2) NOT NULL,
  descricao TEXT,
  data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de saídas (saques)
CREATE TABLE saidas (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id),
  valor NUMERIC(10, 2) NOT NULL,
  descricao TEXT,
  data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
