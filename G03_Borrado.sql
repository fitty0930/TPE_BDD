drop table if exists GR03_categoria cascade;
drop table if exists GR03_comenta cascade;
drop table if exists GR03_comentario cascade;
drop table if exists GR03_juega cascade;
drop table if exists GR03_juego cascade;
drop table if exists GR03_nivel cascade;
drop table if exists GR03_recomendacion cascade;
drop table if exists GR03_tipo_usuario cascade;
drop table if exists GR03_usuario cascade;
drop table if exists GR03_voto cascade;
drop function if exists TRFN_GR03_UN_COMENTARIO_DIARIO cascade;
drop trigger if exists TR_GR03_COMENTARIO_UN_COMENTARIO_DIARIO on GR03_COMENTARIO cascade;
drop function if exists TRFN_GR03_RECOMENDACION_VOTADO cascade;
drop trigger if exists TR_GR03_RECOMENDACION_RECOMENDADO_VOTADO on gr03_recomendacion cascade;
drop function if exists TRFN_GR03_COMENTAR_JUEGO CASCADE;
drop trigger if exists TR_GR03_COMENTARIO_COMENTAR_JUEGO on gr03_comentario cascade;
drop function if exists TRFN_GR03_AUDIT_COMENTA_COMENTARIO cascade;
drop trigger if exists TR_GR03_COMENTARIO_AUDIT_COMENTA_COMENTARIO on gr03_comentario cascade;
drop function if exists FN_GR03_PATRON_BUSQUEDA_APELLIDO cascade;
drop view if exists GR03_COMENTARIOS_MES cascade;
drop view if exists GR03_USUARIOS_COMENTADORES cascade;
drop view if exists GR03_LOS_20_JUEGOS_MAS_PUNTUADOS cascade;
drop view if exists GR03_LOS_10_JUEGOS_MAS_JUGADOS cascade;


