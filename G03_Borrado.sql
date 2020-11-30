drop table if exists GR03
_categoria cascade;
drop table if exists GR03
_comenta cascade;
drop table if exists GR03
_comentario cascade;
drop table if exists GR03
_juega cascade;
drop table if exists GR03
_juego cascade;
drop table if exists GR03
_nivel cascade;
drop table if exists GR03
_recomendacion cascade;
drop table if exists GR03
_tipo_usuario cascade;
drop table if exists GR03
_usuario cascade;
drop table if exists GR03
_voto cascade;
drop function if exists TRFN_GR03_FECHA_COMENTARIOS cascade;
drop trigger if exists TR_GR03_FECHA_COMENTARIOS cascade;
drop function if exists TRFN_GR03_UN_COMENTARIO_DIARIO cascade;
drop trigger if exists TR_GR03_UN_COMENTARIO_DIARIO cascade;
drop function if exists TRFN_GR03_RECOMENDACION_VOTADO cascade;
drop trigger if exists TR_GR03_RECOMENDACION_VOTADO cascade;
drop function if exists TRFN_GR03_COMENTAR_JUEGO CASCADE;
drop trigger if exists TR_GR03_COMENTAR_JUEGO cascade;
drop function if exists TRFN_GR03_AUDIT_COMENTA_COMENTARIO cascade;
drop trigger if exists TR_GR03_AUDIT_COMENTA_COMENTARIO cascade;
drop function if exists FN_GR03_PATRON_BUSQUEDA_APELLIDO cascade;
drop view if exists GR03_COMENTARIOS_MES cascade;
drop view if exists GR03_USUARIOS_COMENTADORES cascade;
drop view if exists GR03_LOS_20_JUEGOS_MAS_PUNTUADOS cascade;
drop view if exists GR03_LOS_10_JUEGOS_MAS_JUGADOS cascade;


