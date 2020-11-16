-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-06-12 17:04:22.554
-- somos el grupo 03
-- tables
-- Table: CATEGORIA
CREATE TABLE G03_CATEGORIA (
    id_categoria int  NOT NULL,
    descripcion varchar(200)  NOT NULL,
    id_nivel_juego int  NOT NULL,
    CONSTRAINT PK_CATEGORIA PRIMARY KEY (id_categoria)
);

-- Table: COMENTA
CREATE TABLE G03_COMENTA (
    id_usuario int  NOT NULL,
    id_juego int  NOT NULL,
    fecha_primer_com timestamp  NOT NULL,
    fecha_ultimo_com timestamp  NULL,
    CONSTRAINT PK_COMENTA PRIMARY KEY (id_usuario,id_juego)
);

-- Table: COMENTARIO
CREATE TABLE G03_COMENTARIO (
    id_usuario int  NOT NULL,
    id_juego int  NOT NULL,
    id_comentario int  NOT NULL,
    fecha_comentario timestamp  NOT NULL,
    comentario varchar(200)  NOT NULL,
    CONSTRAINT PK_COMENTARIO PRIMARY KEY (id_usuario,id_juego,id_comentario)
);

-- Table: JUEGA
CREATE TABLE G03_JUEGA (
    finalizado boolean  NULL,
    id_usuario int  NOT NULL,
    id_juego int  NOT NULL,
    CONSTRAINT PK_JUEGA PRIMARY KEY (id_usuario,id_juego)
);

-- Table: JUEGO
CREATE TABLE G03_JUEGO (
    id_juego int  NOT NULL,
    nombre_juego varchar(100)  NOT NULL,
    descripcion_juego varchar(2048)  NOT NULL,
    id_categoria int  NOT NULL,
    CONSTRAINT PK_JUEGO PRIMARY KEY (id_juego)
);

-- Table: NIVEL
CREATE TABLE G03_NIVEL (
    id_nivel_juego int  NOT NULL,
    descripcion varchar(200)  NOT NULL,
    CONSTRAINT PK_NIVEL PRIMARY KEY (id_nivel_juego)
);

-- Table: RECOMENDACION
CREATE TABLE G03_RECOMENDACION (
    id_recomendacion int  NOT NULL,
    email_recomendado varchar(30)  NOT NULL,
    id_usuario int  NOT NULL,
    id_juego int  NOT NULL,
    CONSTRAINT PK_RECOMENDACION PRIMARY KEY (id_recomendacion)
);

-- Table: TIPO_USUARIO
CREATE TABLE G03_TIPO_USUARIO (
    id_tipo_usuario int  NOT NULL,
    descripcion varchar(30)  NOT NULL,
    CONSTRAINT PK_NIVEL_USUARIO PRIMARY KEY (id_tipo_usuario)
);

-- Table: USUARIO
CREATE TABLE G03_USUARIO (
    id_usuario int  NOT NULL,
    apellido varchar(50)  NOT NULL,
    nombre varchar(50)  NOT NULL,
    email varchar(30)  NOT NULL,
    id_tipo_usuario int  NOT NULL,
    password varchar(32)  NOT NULL,
    CONSTRAINT PK_USUARIO PRIMARY KEY (id_usuario)
);

-- Table: VOTO
CREATE TABLE G03_VOTO (
    id_voto int  NOT NULL,
    valor_voto int  NOT NULL,
    id_usuario int  NOT NULL,
    id_juego int  NOT NULL,
    CONSTRAINT PK_VOTO PRIMARY KEY (id_voto)
);

-- foreign keys
-- Reference: COMENTARIO_COMENTA (table: COMENTARIO)
ALTER TABLE G03_COMENTARIO ADD CONSTRAINT COMENTARIO_COMENTA
    FOREIGN KEY (id_usuario, id_juego)
    REFERENCES G03_COMENTA (id_usuario, id_juego)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_CATEGORIA_NIVEL (table: CATEGORIA)
ALTER TABLE G03_CATEGORIA ADD CONSTRAINT FK_CATEGORIA_NIVEL
    FOREIGN KEY (id_nivel_juego)
    REFERENCES G03_NIVEL (id_nivel_juego)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_COMENTA_JUEGO (table: COMENTA)
ALTER TABLE G03_COMENTA ADD CONSTRAINT FK_COMENTA_JUEGO
    FOREIGN KEY (id_juego)
    REFERENCES G03_JUEGO (id_juego)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_COMENTA_USUARIO (table: COMENTA)
ALTER TABLE G03_COMENTA ADD CONSTRAINT FK_COMENTA_USUARIO
    FOREIGN KEY (id_usuario)
    REFERENCES G03_USUARIO (id_usuario)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_JUEGA_JUEGO (table: JUEGA)
ALTER TABLE G03_JUEGA ADD CONSTRAINT FK_JUEGA_JUEGO
    FOREIGN KEY (id_juego)
    REFERENCES G03_JUEGO (id_juego)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_JUEGA_USUARIO (table: JUEGA)
ALTER TABLE G03_JUEGA ADD CONSTRAINT FK_JUEGA_USUARIO
    FOREIGN KEY (id_usuario)
    REFERENCES G03_USUARIO (id_usuario)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_JUEGO_CATEGORIA (table: JUEGO)
ALTER TABLE G03_JUEGO ADD CONSTRAINT FK_JUEGO_CATEGORIA
    FOREIGN KEY (id_categoria)
    REFERENCES G03_CATEGORIA (id_categoria)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_RECOMENDACION_JUEGA (table: RECOMENDACION)
ALTER TABLE G03_RECOMENDACION ADD CONSTRAINT FK_RECOMENDACION_JUEGA
    FOREIGN KEY (id_usuario, id_juego)
    REFERENCES G03_JUEGA (id_usuario, id_juego)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_USUARIO_NIVEL_USUARIO (table: USUARIO)
ALTER TABLE G03_USUARIO ADD CONSTRAINT FK_USUARIO_NIVEL_USUARIO
    FOREIGN KEY (id_tipo_usuario)
    REFERENCES G03_TIPO_USUARIO (id_tipo_usuario)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_VOTO_JUEGA (table: VOTO)
ALTER TABLE G03_VOTO ADD CONSTRAINT FK_VOTO_JUEGA
    FOREIGN KEY (id_usuario, id_juego)
    REFERENCES G03_JUEGA (id_usuario, id_juego)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.