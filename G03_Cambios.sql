/* ELABORACIÓN DE RESTRICCIONES  */
-- B
/* a. La fecha del primer comentario tiene que ser anterior
   a la fecha del último comentario si este no es nulo */

ALTER TABLE GR03_comenta
    ADD CONSTRAINT CK_GR03_FECHA_COMENTARIOS
        CHECK (fecha_primer_com < fecha_ultimo_com OR fecha_ultimo_com is null);
--INSERT INTO gr03_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) values (1,9,'2020-01-11','2020-01-08');


/* b.	Cada usuario sólo puede comentar una vez al día cada juego */
/*
ALTER TABLE GR03_comentario
    ADD CONSTRAINT CK_UN_COMENTARIO_DIARIO
        CHECK (NOT EXISTS(
                SELECT 1
                FROM GR03_comentario
                group by extract(day from fecha_comentario)
                having COUNT(*)>1
            ));
*/
CREATE OR REPLACE FUNCTION TRFN_GR03_UN_COMENTARIO_DIARIO() RETURNS Trigger AS
$$
DECLARE
    fecha_comentario_h GR03_COMENTARIO.fecha_comentario%type;
BEGIN
    SELECT fecha_comentario
    INTO fecha_comentario_h
    FROM GR03_COMENTARIO
    WHERE id_juego = NEW.id_juego
      AND id_usuario = NEW.id_usuario
      AND extract(DOY from fecha_comentario) = extract(DOY FROM NEW.fecha_comentario);
    IF (fecha_comentario_h is not null) THEN
        RAISE EXCEPTION 'Ya comentaste hoy';
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';
--INSERT INTO gr03_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (1,5,8,now(), 'bla bla');
--INSERT INTO gr03_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (1,5,6,now(), 'bla bla');

/* este es un trigger de tabla */
CREATE TRIGGER TR_GR03_COMENTARIO_UN_COMENTARIO_DIARIO
    BEFORE INSERT
    ON GR03_COMENTARIO
    FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR03_UN_COMENTARIO_DIARIO();

/* c.	Un usuario no puede recomendar un juego si no ha votado previamente dicho juego */
/*
    CREATE ASSERTION CK_RECOMENDACION_VOTADO
        CHECK (NOT EXISTS(
                SELECT 1
                FROM GR03_recomendacion
                WHERE id_usuario, id_juego NOT IN (SELECT id_usuario, id_juego
                                                   FROM GR03_voto)
            ));
*/
--INSERT INTO gr03_recomendacion (id_recomendacion, email_recomendado, id_usuario, id_juego) VALUES (1,'mail', 11,11);
CREATE OR REPLACE FUNCTION TRFN_GR03_RECOMENDACION_VOTADO() RETURNS Trigger AS
$$
DECLARE
    id_user GR03_RECOMENDACION.id_usuario%type;
BEGIN
    SELECT id_usuario
    into id_user
    FROM GR03_VOTO
    WHERE id_usuario = NEW.id_usuario
      AND id_juego = NEW.id_juego;
    IF (id_user is null) THEN
        RAISE EXCEPTION 'Solo podras recomendar juegos que hayas votado';
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';
-- modificado porque solo puedo recomendar juegos que SI haya votado
/* este es una asercion (? */
CREATE TRIGGER TR_GR03_RECOMENDACION_RECOMENDADO_VOTADO
    BEFORE INSERT OR UPDATE of id_usuario,id_juego
    ON GR03_RECOMENDACION
    FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR03_RECOMENDACION_VOTADO();

/* d.	Un usuario no puede comentar un juego que no ha jugado */
/*
   CREATE ASSERTION CK_COMENTAR_JUEGO
        CHECK (NOT EXISTS(
                SELECT 1
                FROM GR03_comentario
                WHERE id_usuario, id_juego NOT IN (SELECT id_usuario, id_juego
                                                   FROM GR03_juega)
            ));

 */
--INSERT INTO gr03_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (3,1,500,now(),'hola');
CREATE OR REPLACE FUNCTION TRFN_GR03_COMENTAR_JUEGO() RETURNS Trigger AS
$$
DECLARE
    id_user GR03_comentario.id_usuario%type;
    id_game GR03_comentario.id_juego%type;
BEGIN
    SELECT id_usuario, id_juego
    into id_user, id_game
    FROM GR03_JUEGA
    WHERE id_usuario = NEW.id_usuario
      AND id_juego = NEW.id_juego;
    IF (id_user is null
        AND id_game is null) THEN
        RAISE EXCEPTION 'Solo podras comentar juegos que hayas jugado';
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

/* este es una asercion (? */
CREATE TRIGGER TR_GR03_COMENTARIO_COMENTAR_JUEGO
    BEFORE INSERT
    ON GR03_comentario
    FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR03_COMENTAR_JUEGO();

-- C
/*  1- Se debe mantener sincronizadas las tablas COMENTA y COMENTARIO en los siguientes aspectos:
La primera vez que se inserta un comentario de un usuario para un juego se debe hacer el insert conjunto
    en ambas tablas, colocando la fecha del primer comentario y última fecha comentario en nulo.
Los posteriores comentarios sólo deben modificar la fecha de último comentario e insertar en COMENTARIO
*/ /*creo xd*/
-- INSERT INTO gr03_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (101,1,1,NOW(),'comentario');
-- INSERT INTO gr03_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (101,1,2,NOW(),'comentario');
-- DELETE FROM gr03_comentario WHERE id_usuario= 101 AND id_juego = 1 AND id_comentario= 2;
-- INSERT INTO gr03_juega (finalizado, id_usuario, id_juego) VALUES (true,101,1);
CREATE OR REPLACE FUNCTION TRFN_GR03_AUDIT_COMENTA_COMENTARIO()
RETURNS Trigger AS
$$
DECLARE
    fecha_coment  GR03_comenta.fecha_primer_com%type;
BEGIN
    IF (tg_op = 'INSERT' OR tg_op = 'UPDATE') THEN
    SELECT fecha_primer_com into fecha_coment
    FROM GR03_comenta
    WHERE GR03_comenta.id_usuario = NEW.id_usuario
    AND GR03_comenta.id_juego = NEW.id_juego;
    IF (fecha_coment is null) THEN
        INSERT INTO GR03_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (NEW.id_usuario,NEW.id_juego,NEW.fecha_comentario, null);
    ELSE
        UPDATE GR03_comenta SET fecha_ultimo_com = NEW.fecha_comentario WHERE id_juego = NEW.id_juego AND id_usuario = NEW.id_usuario;
    END IF;

    RETURN NEW;
    ELSE
        SELECT fecha_comentario into fecha_coment
            FROM gr03_comentario
                ORDER BY fecha_comentario DESC
                LIMIT 2 OFFSET 1;
        IF (fecha_coment < old.fecha_comentario AND fecha_coment is not null) THEN
            UPDATE GR03_comenta SET fecha_ultimo_com = fecha_coment WHERE id_juego = OLD.id_juego AND id_usuario = OLD.id_usuario;
        ELSE
            DELETE FROM GR03_COMENTA WHERE id_usuario = OLD.id_usuario AND id_juego = OLD.id_juego;
        end if;
        RETURN OLD;
    end if;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR03_COMENTARIO_AUDIT_COMENTA_COMENTARIO
    BEFORE INSERT OR UPDATE OF id_usuario, id_juego, id_comentario OR DELETE
    ON GR03_comentario
    FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR03_AUDIT_COMENTA_COMENTARIO();

/* 2- Dado un patrón de búsqueda devolver todos los datos de el o los usuarios junto con la cantidad de
   juegos que ha jugado y la cantidad de votos que ha realizado. */
CREATE OR REPLACE FUNCTION FN_GR03_PATRON_BUSQUEDA_APELLIDO(patron varchar)
RETURNS TABLE (

        id_usuarío GR03_usuario.id_usuario%type,
        apellido GR03_usuario.apellido%type,
        nombre GR03_usuario.nombre%type,
        email GR03_usuario.email%type,
        id_tipo_usuario GR03_usuario.id_tipo_usuario%type,
        password GR03_usuario.password%type,
        cant_juegos_jugados INT,
        cant_votos INT
)
AS $$
BEGIN
    RETURN QUERY SELECT
       u.id_usuario, u.apellido, u.nombre, u.email, u.id_tipo_usuario, u.password, coalesce(cant_juegos,0)::INTEGER as cant_juegos_jugados, coalesce(cant_v,0)::INTEGER as cant_votos
    FROM
        GR03_usuario u left join (SELECT id_usuario, COUNT(*) as cant_juegos
                        FROM GR03_juega
                        GROUP BY id_usuario) as juega on (u.id_usuario = juega.id_usuario)
            left join  (SELECT id_usuario, COUNT(*) as cant_v
                        FROM GR03_voto
                        GROUP BY id_usuario) as voto on (u.id_usuario = voto.id_usuario)
    WHERE
        u.apellido ILIKE '%'||patron||'%';

END; $$
LANGUAGE 'plpgsql';
--D
/* COMENTARIOS_MES: Listar todos los comentarios realizados durante el último mes descartando aquellos
   juegos de la Categoría “Sin Categorías”. */
CREATE VIEW GR03_COMENTARIOS_MES AS
SELECT comentario, fecha_comentario
FROM GR03_COMENTARIO
WHERE GR03_COMENTARIO.id_juego IN (SELECT id_juego
                                  FROM GR03_comenta
                                  WHERE id_juego IN (
                                      SELECT id_juego
                                      FROM GR03_juego
                                      WHERE id_categoria IN (
                                          SELECT id_categoria
                                            FROM GR03_categoria
                                                WHERE descripcion <> 'Sin Categorías'
                                          )
                                  ))
  AND fecha_comentario BETWEEN NOW() - '1 month'::interval AND NOW();
-- actualizable, no rompe ninguna regla

/* USUARIOS_COMENTADORES: Listar aquellos usuarios que han comentado TODOS los juegos durante el
   último año, teniendo en cuenta que sólo pueden comentar aquellos juegos que han jugado.
*/

--teniendo en cuenta que sólo pueden comentar aquellos juegos que han jugado.
-- ESTA IMPLEMENTADO EN trigger B sub d

CREATE VIEW GR03_USUARIOS_COMENTADORES AS
SELECT *
FROM GR03_usuario
WHERE id_usuario IN (SELECT GR03_COMENTA.id_usuario
                     FROM GR03_comenta
                     WHERE GR03_COMENTA.id_usuario IN (
                         SELECT id_usuario
                         FROM GR03_comentario
                         WHERE fecha_comentario
                             BETWEEN NOW() - '1 year'::interval AND NOW()
                             group by GR03_comentario.id_usuario
                    HAVING COUNT(id_juego) = (SELECT COUNT(id_juego) FROM GR03_JUEGO)));
/* LOS_20_JUEGOS_MAS_PUNTUADOS: Realizar el ranking de los 20 juegos mejor puntuados por los Usuarios.
   El ranking debe ser generado considerando el promedio del valor puntuado por los usuarios y que el
   juego hubiera sido calificado más de 5 veces. */
/* NO ES ACTUALIZABLE */
CREATE VIEW GR03_LOS_20_JUEGOS_MAS_PUNTUADOS AS
SELECT j.id_juego, j.nombre_juego, j.descripcion_juego, j.id_categoria, round(AVG(g03v.valor_voto),2) as Puntaje FROM gr03_juego j join gr03_voto g03v on j.id_juego = g03v.id_juego
                    GROUP BY j.id_juego
                   HAVING count(*) > 1
                   ORDER BY AVG(valor_voto) DESC
                   LIMIT 20;
/* LOS_10_JUEGOS_MAS_JUGADOS: Generar una vista con los 10 juegos más jugados. */
CREATE OR REPLACE VIEW GR03_LOS_10_JUEGOS_MAS_JUGADOS AS
 /* ACTUALIZABLE NO ORDENADO AL MOSTRAR LOS 10 */
SELECT *
FROM GR03_juego o
WHERE o.id_juego IN (SELECT a.id_juego
                   FROM GR03_juega a
                   GROUP BY a.id_juego
                   ORDER BY COUNT(a.id_juego) DESC
                   LIMIT 10);
/* NO ACTUALIZABLE, ORDERNADO AL MOSTRAR LOS 10*/
-- SELECT o.id_juego, o.nombre_juego, o.descripcion_juego, o.id_categoria FROM gr03_juego o join gr03_juega J on o.id_juego = j.id_juego
--                     GROUP BY o.id_juego
--                     ORDER BY COUNT(j.id_juego) DESC
--                     LIMIT 10;

