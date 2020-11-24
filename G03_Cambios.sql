/* ELABORACIÓN DE RESTRICCIONES  */
-- B
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
      AND date(fecha_comentario) = date(NEW.fecha_comentario);
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
    BEFORE INSERT OR UPDATE of id_usuario,id_juego
    ON G03_RECOMENDACION
    FOR EACH ROW
EXECUTE PROCEDURE FN_G03_RECOMENDACION_VOTADO();

/* d.	Un usuario no puede comentar un juego que no ha jugado */
CREATE OR REPLACE FUNCTION FN_G03_COMENTAR_JUEGO() RETURNS Trigger AS
$$
DECLARE
    id_user g03_comentario.id_usuario%type;
    id_game g03_comentario.id_juego%type;
BEGIN
    SELECT id_usuario, id_juego
    into id_user, id_game
    FROM G03_JUEGA
    WHERE id_usuario = NEW.id_usuario
      AND id_juego = NEW.id_juego;
    IF (id_user <> NEW.id_usuario
        AND id_game <> NEW.id_juego) THEN
        RAISE EXCEPTION 'Solo podras votar juegos que hays jugado';
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

/* este es una asercion (? */
CREATE TRIGGER TR_G03_COMENTAR_JUEGO
    BEFORE INSERT
    ON g03_comentario
    FOR EACH ROW
EXECUTE PROCEDURE FN_G03_COMENTAR_JUEGO();

-- C
/*  1- Se debe mantener sincronizadas las tablas COMENTA y COMENTARIO en los siguientes aspectos:
La primera vez que se inserta un comentario de un usuario para un juego se debe hacer el insert conjunto
    en ambas tablas, colocando la fecha del primer comentario y última fecha comentario en nulo.
Los posteriores comentarios sólo deben modificar la fecha de último comentario e insertar en COMENTARIO
*/ /*creo xd*/

CREATE OR REPLACE FUNCTION FN_G03_AUDIT_COMENTA_COMENTARIO()
RETURNS Trigger AS
$$
DECLARE
    fecha_primer_coment  g03_comenta.fecha_primer_com%type;
BEGIN
    SELECT fecha_primer_com into fecha_primer_coment
    FROM g03_comenta
    WHERE g03_comenta.id_usuario = NEW.id_usuario
    AND g03_comenta.id_juego = NEW.id_juego;
    IF NOT EXISTS(fecha_primer_coment) THEN
        INSERT INTO g03_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (NEW.id_usuario,NEW.id_juego,NEW.fecha_comentario, null);
    ELSE
        UPDATE g03_comenta SET fecha_ultimo_com = NEW.fecha_comentario WHERE id_juego = NEW.id_juego AND id_usuario = NEW.id_usuario;
    END IF;
END;
$$
    LANGUAGE 'plpgsql';


CREATE TRIGGER TR_G03_AUDIT_COMENTA_COMENTARIO
    AFTER INSERT OR UPDATE OF id_usuario, id_juego, fecha_comentario
    ON g03_comentario
    FOR EACH ROW
EXECUTE PROCEDURE FN_G03_AUDIT_COMENTA_COMENTARIO();

/* 2- Dado un patrón de búsqueda devolver todos los datos de el o los usuarios junto con la cantidad de
   juegos que ha jugado y la cantidad de votos que ha realizado. */

CREATE OR REPLACE FUNCTION FN_G03_PATRON_BUSQUEDA_APELLIDO(patron varchar)
RETURNS TABLE (
        id_usuario g03_usuario.id_usuario%type,
        apellido g03_usuario.apellido%type,
        nombre g03_usuario.nombre%type,
        email g03_usuario.email%type,
        id_tipo_usuario g03_usuario.id_tipo_usuario%type,
        password g03_usuario.password%type,
        cant_juegos_jugados INT,
        cant_votos  INT
)
AS $$
BEGIN
    RETURN QUERY SELECT
       g03_usuario.id_usuario, apellido, nombre, email, id_tipo_usuario, password, coalesce(cant_juegos_jugados,0) as cant_juegos_jugados, coalesce(cant_votos,0) as cant_votos
    FROM
        g03_usuario left join (SELECT id_usuario, COUNT(*) as cant_juegos_jugados
                        FROM g03_juega
                        GROUP BY id_usuario) as juega on (g03_usuario.id_usuario = juega.id_usuario)
            left join  (SELECT id_usuario, COUNT(*) as cant_votos
                        FROM g03_voto
                        GROUP BY id_usuario) as voto on (g03_usuario.id_usuario = voto.id_usuario)
    WHERE
        g03_usuario.apellido ILIKE '%'||patron||'%';

END; $$
LANGUAGE 'plpgsql';
--D
/* COMENTARIOS_MES: Listar todos los comentarios realizados durante el último mes descartando aquellos
   juegos de la Categoría “Sin Categorías”. */
CREATE VIEW COMENTARIOS_MES AS
SELECT comentario, fecha_comentario
FROM G03_COMENTARIO
WHERE G03_COMENTARIO.id_juego IN (SELECT id_juego
                                  FROM g03_comenta
                                  WHERE id_juego IN (
                                      SELECT id_juego
                                      FROM g03_juego
                                      WHERE id_categoria IN (
                                          SELECT id_categoria
                                            FROM g03_categoria
                                                WHERE descripcion = 'Sin Categorías'
                                          )
                                  ))
  AND fecha_comentario BETWEEN NOW() - '1 month'::interval AND NOW();
-- actualizable, no rompe ninguna regla

/* USUARIOS_COMENTADORES: Listar aquellos usuarios que han comentado TODOS los juegos durante el
   último año, teniendo en cuenta que sólo pueden comentar aquellos juegos que han jugado.
*/

--teniendo en cuenta que sólo pueden comentar aquellos juegos que han jugado.
-- ESTA IMPLEMENTADO EN trigger B sub d

CREATE VIEW USUARIOS_COMENTADORES AS
SELECT *
FROM g03_usuario
WHERE id_usuario IN (SELECT G03_COMENTA.id_usuario
                     FROM g03_comenta
                     WHERE G03_COMENTA.id_usuario IN (
                         SELECT id_usuario
                         FROM g03_comentario
                         WHERE fecha_comentario
                                   BETWEEN NOW() - '1 year'::interval AND NOW()
                         HAVING COUNT(id_juego) = (SELECT COUNT(id_juego) FROM G03_JUEGO)));

/* LOS_20_JUEGOS_MAS_PUNTUADOS: Realizar el ranking de los 20 juegos mejor puntuados por los Usuarios.
   El ranking debe ser generado considerando el promedio del valor puntuado por los usuarios y que el
   juego hubiera sido calificado más de 5 veces. */

CREATE VIEW LOS_20_JUEGOS_MAS_PUNTUADOS AS
SELECT *
FROM g03_juego
WHERE id_juego IN (SELECT id_juego
                   FROM g03_voto
                   HAVING count(*) > 5
                   ORDER BY AVG(valor_voto) ASC
                   LIMIT 20);

/* LOS_10_JUEGOS_MAS_JUGADOS: Generar una vista con los 10 juegos más jugados. */

CREATE VIEW LOS_10_JUEGOS_MAS_JUGADOS AS
SELECT *
FROM g03_juego
WHERE id_juego IN (SELECT id_juego
                   FROM g03_juega
                   ORDER BY COUNT(id_juego) ASC
                   LIMIT 10);