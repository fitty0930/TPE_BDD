drop table if exists g03_categoria cascade;
drop table if exists g03_comenta cascade;
drop table if exists g03_comentario cascade;
drop table if exists g03_juega cascade;
drop table if exists g03_juego cascade;
drop table if exists g03_nivel cascade;
drop table if exists g03_recomendacion cascade;
drop table if exists g03_tipo_usuario cascade;
drop table if exists g03_usuario cascade;
drop table if exists g03_voto cascade;
drop function if exists FN_G03_FECHA_COMENTARIOS cascade;
drop trigger if exists TR_G03_FECHA_COMENTARIOS cascade;
drop function if exists FN_G03_UN_COMENTARIO_DIARIO cascade;
drop trigger if exists TR_G03_UN_COMENTARIO_DIARIO cascade;
drop function if exists FN_G03_RECOMENDACION_VOTADO cascade;
drop trigger if exists TR_G03_RECOMENDACION_VOTADO cascade;
drop function if exists FN_G03_COMENTAR_JUEGO CASCADE;
drop trigger if exists TR_G03_COMENTAR_JUEGO cascade;
drop function if exists FN_G03_AUDIT_COMENTA_COMENTARIO cascade;
drop trigger if exists TR_G03_AUDIT_COMENTA_COMENTARIO cascade;
drop function if exists FN_G03_PATRON_BUSQUEDA_APELLIDO cascade;
drop view if exists VW_G03_COMENTARIOS_MES cascade;
drop view if exists VW_G03_USUARIOS_COMENTADORES cascade;
drop view if exists VW_G03_LOS_20_JUEGOS_MAS_PUNTUADOS cascade;
drop view if exists VW_G03_LOS_10_JUEGOS_MAS_JUGADOS cascade;


