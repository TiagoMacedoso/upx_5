#uvicorn main:app --host 0.0.0.0 --port 3000

from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker

app = FastAPI()

# Configuração da conexão com MySQL
DATABASE_URL = "mysql+pymysql://root:1809@192.168.3.222:3306/control_finance"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String(100))
    email = Column(String(100), unique=True)
    senha = Column(String(100))

Base.metadata.create_all(bind=engine)

# Modelo de entrada da API
class UsuarioCreate(BaseModel):
    nome: str
    email: str
    senha: str

@app.post("/api/cadastro")
def cadastrar_usuario(usuario: UsuarioCreate):
    db = SessionLocal()
    existing_user = db.query(Usuario).filter(Usuario.email == usuario.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email já cadastrado")

    novo_usuario = Usuario(**usuario.dict())
    db.add(novo_usuario)
    db.commit()
    db.refresh(novo_usuario)
    db.close()
    return {"message": "Usuário cadastrado com sucesso"}

@app.post("/api/login")
def login(usuario: UsuarioCreate):
    db = SessionLocal()
    user = db.query(Usuario).filter(
        Usuario.email == usuario.email,
        Usuario.senha == usuario.senha
    ).first()

    db.close()

    if user:
        return {"message": "Login autorizado", "nome": user.nome}
    else:
        raise HTTPException(status_code=401, detail="Credenciais inválidas")
