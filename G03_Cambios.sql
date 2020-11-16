/* ELABORACIÓN DE RESTRICCIONES  */
/* a. La fecha del primer comentario tiene que ser anterior
   a la fecha del último comentario si este no es nulo */

CREATE OR REPLACE FUNCTION FN_G03_FECHA_COMENTARIOS() RETURNS Trigger AS
$$
DECLARE
    fecha_primero G03_COMENTARIO.fecha_comentario%type;
BEGIN
    SELECT fecha_comentario
    INTO fecha_primero
    FROM G03_COMENTARIO
    WHERE id_comentario = NEW.id_comentario
      AND id_juego = NEW.id_juego
    ORDER BY id_comentario, id_juego ASC
    limit 1;
    IF (fecha_primero > NEW.fecha_comentario) THEN
        RAISE EXCEPTION 'La fecha de su comentario % es anterior a la fecha del primer comentario %',
            NEW.fecha_comentario, fecha_primero;
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

/* este es un trigger de tabla */
CREATE TRIGGER TR_G03_FECHA_COMENTARIOS
    BEFORE INSERT
    ON G03_COMENTARIO
    FOR EACH ROW
    WHEN (NEW.comentario <> null)
EXECUTE PROCEDURE FN_G03_FECHA_COMENTARIOS();


/* b.	Cada usuario sólo puede comentar una vez al día cada juego */
CREATE OR REPLACE FUNCTION FN_G03_UN_COMENTARIO_DIARIO() RETURNS Trigger AS
$$
DECLARE
    fecha_comentario_h G03_COMENTARIO.fecha_comentario%type;
BEGIN
    SELECT fecha_comentario
    INTO fecha_comentario_h
    FROM G03_COMENTARIO
    WHERE id_juego = NEW.id_juego
      AND id_usuario = NEW.id_usuario
      AND fecha_comentario = NEW.fecha_comentario;

    IF (fecha_comentario_h) THEN
        RAISE EXCEPTION 'Ya comentaste hoy';
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

/* este es un trigger de tabla */
CREATE TRIGGER TR_G03_UN_COMENTARIO_DIARIO
    BEFORE INSERT
    ON G03_COMENTARIO
    FOR EACH ROW
EXECUTE PROCEDURE FN_G03_UN_COMENTARIO_DIARIO();

/* c.	Un usuario no puede recomendar un juego si no ha votado previamente dicho juego */
CREATE OR REPLACE FUNCTION FN_G03_RECOMENDACION_VOTADO() RETURNS Trigger AS
$$
DECLARE
    id_user G03_RECOMENDACION.id_usuario%type;
    id_game G03_RECOMENDACION.id_juego%type;
BEGIN
    SELECT id_usuario, id_juego
    into id_user, id_game
    FROM G03_VOTO
    WHERE id_usuario = NEW.id_usuario
      AND id_juego = NEW.id_juego;
    IF (id_user = NEW.id_usuario
        AND id_game = NEW.id_juego) THEN
        RAISE EXCEPTION 'Solo podras recomendar juegos que no hayas votado';
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

/* este es una asercion (? */
CREATE TRIGGER TR_G03_RECOMENDACION_VOTADO
    BEFORE INSERT
    ON G03_RECOMENDACION
    FOR EACH ROW
EXECUTE PROCEDURE FN_G03_RECOMENDACION_VOTADO();

/* d.	Un usuario no puede comentar un juego que no ha jugado */
CREATE OR REPLACE FUNCTION FN_G03_COMENTAR_JUEGO() RETURNS Trigger AS
$$
DECLARE
    id_user G03_VOTO.id_usuario%type;
    id_game G03_VOTO.id_juego%type;
BEGIN
    SELECT id_usuario, id_juego
    into id_user, id_game
    FROM G03_JUEGA
    WHERE id_usuario = NEW.id_usuario
      AND id_juego = NEW.id_juego;
    IF (id_user = NEW.id_usuario
        AND id_game = NEW.id_juego) THEN
        RAISE EXCEPTION 'Solo podras votar juegos que hays jugado';
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

/* este es una asercion (? */
CREATE TRIGGER TR_G03_COMENTAR_JUEGO
    BEFORE INSERT
    ON G03_VOTO
    FOR EACH ROW
EXECUTE PROCEDURE FN_G03_COMENTAR_JUEGO();