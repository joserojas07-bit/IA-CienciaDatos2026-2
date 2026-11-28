/* ==============================================================================
ESPECIALIZACIÓN EN INTELIGENCIA ARTIFICIAL
MÓDULO: CIENCIA DE DATOS Y TOMA DE DECISIONES
TALLER PRÁCTICO INTEGRADO: ANALÍTICA ACADÉMICA CON SQL & TEXT-TO-SQL

Estudiante: José Daniel Rojas Verbel
Código:     202624475
Motor BD:   SQLite (university.db)
Entorno:    Google Antigravity / DBCode / Python (sqlite3)
============================================================================== */
-- ==============================================================================
-- PARTE I: BATERÍA PROGRESIVA DE CONSULTAS RELACIONALES
-- ==============================================================================
-- ------------------------------------------------------------------------------
-- BLOQUE A: EXPLORACIÓN, ORDENAMIENTO Y FILTROS BÁSICOS
-- ------------------------------------------------------------------------------
-- Consulta A.1: Mostrar todos los registros de la tabla USUARIOS.
SELECT
    *
FROM
    USUARIOS;

-- Consulta A.2: Mostrar únicamente el NOMBRE y APELLIDO de todos los usuarios.
SELECT
    NOMBRE,
    APELLIDO
FROM
    USUARIOS;

-- Consulta A.3: Mostrar todas las carreras ordenadas alfabéticamente de forma ascendente.
SELECT
    ID_CARRERA,
    NOMBRE,
    ID_FACULTAD
FROM
    CARRERAS
ORDER BY
    NOMBRE ASC;

-- Consulta A.4: Mostrar los cursos ordenados alfabéticamente de forma descendente.
SELECT
    ID_CURSO,
    NOMBRE,
    ID_FACULTAD
FROM
    CURSOS
ORDER BY
    NOMBRE DESC;

-- Consulta A.5: Mostrar los estudiantes que estén cursando el semestre 2.
-- Nota: En la tabla USUARIOS, los estudiantes se identifican por ID_ROL = 1.
SELECT
    ID_USUARIO,
    NOMBRE,
    APELLIDO,
    SEMESTRE
FROM
    USUARIOS
WHERE
    ID_ROL = 1
    AND SEMESTRE = 2;

-- Consulta A.6: Mostrar los usuarios cuyo apellido sea 'Gomez'.
SELECT
    ID_USUARIO,
    NOMBRE,
    APELLIDO,
    SEMESTRE,
    ID_ROL
FROM
    USUARIOS
WHERE
    APELLIDO = 'Gomez';

-- Consulta A.7: Mostrar los estudiantes que pertenezcan al semestre 1 o al semestre 2.
SELECT
    ID_USUARIO,
    NOMBRE,
    APELLIDO,
    SEMESTRE
FROM
    USUARIOS
WHERE
    ID_ROL = 1
    AND SEMESTRE IN (1, 2);

-- Consulta A.8: Listar el ID_CURSO y el NOMBRE de todas las asignaturas de la Facultad de Ingeniería y Ciencias
-- (ID_FACULTAD = 1) cuyo nombre contenga palabras relacionadas con inteligencia o datos
-- (%Inteligentes%, %Aprendizaje% o %Datos%), ordenadas alfabéticamente.
SELECT
    ID_CURSO,
    NOMBRE
FROM
    CURSOS
WHERE
    ID_FACULTAD = 1
    AND (
        NOMBRE LIKE '%Inteligentes%'
        OR NOMBRE LIKE '%Aprendizaje%'
        OR NOMBRE LIKE '%Datos%'
    )
ORDER BY
    NOMBRE ASC;

-- ------------------------------------------------------------------------------
-- BLOQUE B: MANIPULACIÓN DE DATOS — DML (INSERT, UPDATE, DELETE)
-- ------------------------------------------------------------------------------
-- Consulta B.1: Insertar una nueva facultad en la tabla FACULTADES.
INSERT INTO
    FACULTADES (ID_FACULTAD, NOMBRE)
VALUES
    (
        99,
        'Facultad de Inteligencia Artificial y toma de decisiones'
    );

-- Consulta B.2: Eliminar la facultad recién insertada en el punto anterior.
DELETE FROM FACULTADES
WHERE
    ID_FACULTAD = 99;

-- Consulta B.3: Verificar mediante una consulta SELECT que la facultad fue eliminada correctamente.
SELECT
    *
FROM
    FACULTADES
WHERE
    ID_FACULTAD = 99;

-- Consulta B.4: Insertar un nuevo estudiante en la tabla USUARIOS (ID_ROL = 1 corresponde a estudiante).
INSERT INTO
    USUARIOS (ID_USUARIO, NOMBRE, APELLIDO, SEMESTRE, ID_ROL)
VALUES
    (22, 'Daniel', 'Rojas', 1, 1);

-- Consulta B.5: Verificar que el nuevo registro del estudiante se haya guardado correctamente.
SELECT
    *
FROM
    USUARIOS
WHERE
    ID_USUARIO = 22;

-- Consulta B.6: Actualizar el semestre del estudiante con ID_USUARIO = 22 a semestre 4.
UPDATE USUARIOS
SET
    SEMESTRE = 4
WHERE
    ID_USUARIO = 22;

-- Consulta B.7: Eliminar el registro del estudiante ingresado en el punto anterior.
DELETE FROM USUARIOS
WHERE
    ID_USUARIO = 22;

-- Consulta B.8: Verificar que el registro del estudiante haya sido eliminado de la base de datos.
SELECT
    *
FROM
    USUARIOS
WHERE
    ID_USUARIO = 22;

-- ------------------------------------------------------------------------------
-- BLOQUE C: CRUCES RELACIONALES Y CARTELERAS (INNER JOIN)
-- ------------------------------------------------------------------------------
-- Consulta C.1: Mostrar cada carrera junto con el nombre de su facultad.
SELECT
    c.ID_CARRERA,
    c.NOMBRE AS CARRERA,
    f.NOMBRE AS FACULTAD
FROM
    CARRERAS c
    INNER JOIN FACULTADES f ON c.ID_FACULTAD = f.ID_FACULTAD
ORDER BY
    f.NOMBRE,
    c.NOMBRE;

-- Consulta C.2: Mostrar el nombre de solo los usuarios que tienen rol de estudiante.
SELECT
    u.ID_USUARIO,
    u.NOMBRE || ' ' || u.APELLIDO AS NOMBRE_COMPLETO,
    u.SEMESTRE,
    r.NOMBRE AS ROL
FROM
    USUARIOS u
    INNER JOIN ROLES r ON u.ID_ROL = r.ID_ROL
WHERE
    r.NOMBRE = 'Estudiante';

-- Consulta C.3: Mostrar el nombre de solo los usuarios que tienen rol de profesor.
SELECT
    u.ID_USUARIO,
    u.NOMBRE || ' ' || u.APELLIDO AS NOMBRE_COMPLETO,
    r.NOMBRE AS ROL
FROM
    USUARIOS u
    INNER JOIN ROLES r ON u.ID_ROL = r.ID_ROL
WHERE
    r.NOMBRE = 'Profesor';

-- Consulta C.4: Mostrar los cursos matriculados por cada estudiante (nombre del estudiante y nombre del curso).
SELECT
    u.NOMBRE || ' ' || u.APELLIDO AS ESTUDIANTE,
    cur.NOMBRE AS CURSO
FROM
    CURSOS_ESTUDIANTES ce
    INNER JOIN USUARIOS u ON ce.ID_USUARIO = u.ID_USUARIO
    INNER JOIN CALENDARIO_CURSOS cc ON ce.ID_CALENDARIO = cc.ID_CALENDARIO
    INNER JOIN CURSOS cur ON cc.ID_CURSO = cur.ID_CURSO
ORDER BY
    ESTUDIANTE,
    CURSO;

-- Consulta C.5: Mostrar todos los cursos programados junto con el nombre del salón y el nombre del edificio donde se dictan.
SELECT
    cc.ID_CALENDARIO,
    cur.NOMBRE AS CURSO,
    s.NOMBRE AS SALON,
    e.NOMBRE AS EDIFICIO,
    cc.DIA,
    cc.HORA_INICIO || ' - ' || cc.HORA_FIN AS HORARIO
FROM
    CALENDARIO_CURSOS cc
    INNER JOIN CURSOS cur ON cc.ID_CURSO = cur.ID_CURSO
    INNER JOIN SALONES s ON cc.ID_SALON = s.ID_SALON
    INNER JOIN EDIFICIOS e ON s.ID_EDIFICIO = e.ID_EDIFICIO
ORDER BY
    cur.NOMBRE,
    cc.DIA;

-- Consulta C.6: Generar la cartelera de programación para el día Martes mostrando:
-- nombre del curso, hora de inicio, hora de fin, nombre del salón, nombre del edificio
-- y nombre completo del profesor que lo dicta.
SELECT
    cur.NOMBRE AS CURSO,
    cc.HORA_INICIO,
    cc.HORA_FIN,
    s.NOMBRE AS SALON,
    e.NOMBRE AS EDIFICIO,
    prof.NOMBRE || ' ' || prof.APELLIDO AS PROFESOR
FROM
    CALENDARIO_CURSOS cc
    INNER JOIN CURSOS cur ON cc.ID_CURSO = cur.ID_CURSO
    INNER JOIN SALONES s ON cc.ID_SALON = s.ID_SALON
    INNER JOIN EDIFICIOS e ON s.ID_EDIFICIO = e.ID_EDIFICIO
    INNER JOIN USUARIOS prof ON cc.ID_PROFESOR = prof.ID_USUARIO
WHERE
    cc.DIA = 'Martes'
ORDER BY
    cc.HORA_INICIO,
    cur.NOMBRE;

-- Consulta C.7: Mostrar el horario completo de un estudiante específico (días, horas, cursos y salones).
-- Ejemplo con ID_USUARIO = 1
SELECT
    u.NOMBRE || ' ' || u.APELLIDO AS ESTUDIANTE,
    cc.DIA,
    cc.HORA_INICIO,
    cc.HORA_FIN,
    cur.NOMBRE AS CURSO,
    s.NOMBRE AS SALON,
    e.NOMBRE AS EDIFICIO
FROM
    CURSOS_ESTUDIANTES ce
    INNER JOIN USUARIOS u ON ce.ID_USUARIO = u.ID_USUARIO
    INNER JOIN CALENDARIO_CURSOS cc ON ce.ID_CALENDARIO = cc.ID_CALENDARIO
    INNER JOIN CURSOS cur ON cc.ID_CURSO = cur.ID_CURSO
    INNER JOIN SALONES s ON cc.ID_SALON = s.ID_SALON
    INNER JOIN EDIFICIOS e ON s.ID_EDIFICIO = e.ID_EDIFICIO
WHERE
    u.ID_USUARIO = 1
ORDER BY
    CASE cc.DIA
        WHEN 'Lunes' THEN 1
        WHEN 'Martes' THEN 2
        WHEN 'Miercoles' THEN 3
        WHEN 'Jueves' THEN 4
        WHEN 'Viernes' THEN 5
        WHEN 'Sabado' THEN 6
        ELSE 7
    END,
    cc.HORA_INICIO;

-- Consulta C.8: Listar los profesores que dictan cursos en general y los profesores que tienen cursos ofertados en el calendario.
SELECT DISTINCT
    u.ID_USUARIO,
    u.NOMBRE || ' ' || u.APELLIDO AS PROFESOR,
    'Con cursos ofertados en calendario' AS ESTADO
FROM
    USUARIOS u
    INNER JOIN CALENDARIO_CURSOS cc ON u.ID_USUARIO = cc.ID_PROFESOR
WHERE
    u.ID_ROL = 2
UNION
SELECT
    u.ID_USUARIO,
    u.NOMBRE || ' ' || u.APELLIDO AS PROFESOR,
    'Docente de planta registrado' AS ESTADO
FROM
    USUARIOS u
WHERE
    u.ID_ROL = 2
ORDER BY
    PROFESOR;

-- Consulta C.9: Mostrar los profesores junto con los nombres de los cursos ofertados que orientan.
SELECT DISTINCT
    prof.NOMBRE || ' ' || prof.APELLIDO AS PROFESOR,
    cur.NOMBRE AS CURSO
FROM
    CALENDARIO_CURSOS cc
    INNER JOIN USUARIOS prof ON cc.ID_PROFESOR = prof.ID_USUARIO
    INNER JOIN CURSOS cur ON cc.ID_CURSO = cur.ID_CURSO
ORDER BY
    PROFESOR,
    CURSO;

-- ------------------------------------------------------------------------------
-- BLOQUE D: AUDITORÍA DE REGISTROS HUÉRFANOS (LEFT JOIN / SUBCONSULTAS)
-- ------------------------------------------------------------------------------
-- Consulta D.1: Identificar los estudiantes registrados que no tienen ningún curso matriculado en CURSOS_ESTUDIANTES.
SELECT
    u.ID_USUARIO,
    u.NOMBRE || ' ' || u.APELLIDO AS ESTUDIANTE,
    u.SEMESTRE
FROM
    USUARIOS u
    LEFT JOIN CURSOS_ESTUDIANTES ce ON u.ID_USUARIO = ce.ID_USUARIO
WHERE
    u.ID_ROL = 1
    AND ce.ID_USUARIO IS NULL;

-- Consulta D.2: Detectar qué cursos existen en el catálogo general (CURSOS) pero no tienen ningún horario programado en CALENDARIO_CURSOS.
SELECT
    c.ID_CURSO,
    c.NOMBRE AS CURSO
FROM
    CURSOS c
    LEFT JOIN CALENDARIO_CURSOS cc ON c.ID_CURSO = cc.ID_CURSO
WHERE
    cc.ID_CURSO IS NULL
ORDER BY
    c.NOMBRE;

-- Consulta D.3: Mostrar los cursos que existen en el sistema pero que no tienen ningún estudiante matriculado.
SELECT
    c.ID_CURSO,
    c.NOMBRE AS CURSO
FROM
    CURSOS c
    LEFT JOIN CALENDARIO_CURSOS cc ON c.ID_CURSO = cc.ID_CURSO
    LEFT JOIN CURSOS_ESTUDIANTES ce ON cc.ID_CALENDARIO = ce.ID_CALENDARIO
GROUP BY
    c.ID_CURSO,
    c.NOMBRE
HAVING
    COUNT(ce.ID_USUARIO) = 0
ORDER BY
    c.NOMBRE;

-- Consulta D.4: Identificar los cursos que sí están ofertados en CALENDARIO_CURSOS pero que no tienen estudiantes matriculados.
SELECT DISTINCT
    cc.ID_CALENDARIO,
    c.ID_CURSO,
    c.NOMBRE AS CURSO,
    cc.DIA,
    cc.HORA_INICIO || ' - ' || cc.HORA_FIN AS HORARIO
FROM
    CALENDARIO_CURSOS cc
    INNER JOIN CURSOS c ON cc.ID_CURSO = c.ID_CURSO
    LEFT JOIN CURSOS_ESTUDIANTES ce ON cc.ID_CALENDARIO = ce.ID_CALENDARIO
WHERE
    ce.ID_USUARIO IS NULL
ORDER BY
    c.NOMBRE;

-- ------------------------------------------------------------------------------
-- BLOQUE E: AGREGACIONES, ESTADÍSTICAS Y CUPOS (GROUP BY / HAVING)
-- ------------------------------------------------------------------------------
-- Consulta E.1: Contar cuántos estudiantes existen en total en la universidad.
SELECT
    COUNT(*) AS TOTAL_ESTUDIANTES
FROM
    USUARIOS
WHERE
    ID_ROL = 1;

-- Consulta E.2: Mostrar en una sola consulta el total de profesores y el total de estudiantes registrados.
SELECT
    SUM(
        CASE
            WHEN ID_ROL = 1 THEN 1
            ELSE 0
        END
    ) AS TOTAL_ESTUDIANTES,
    SUM(
        CASE
            WHEN ID_ROL = 2 THEN 1
            ELSE 0
        END
    ) AS TOTAL_PROFESORES,
    COUNT(*) AS TOTAL_USUARIOS
FROM
    USUARIOS;

-- Consulta E.3: Calcular el promedio del semestre en el que se encuentran los estudiantes.
SELECT
    ROUND(AVG(SEMESTRE), 2) AS PROMEDIO_SEMESTRE,
    MIN(SEMESTRE) AS SEMESTRE_MINIMO,
    MAX(SEMESTRE) AS SEMESTRE_MAXIMO
FROM
    USUARIOS
WHERE
    ID_ROL = 1;

-- Consulta E.4: Mostrar el estudiante (o estudiantes) que cursa el semestre más alto.
SELECT
    ID_USUARIO,
    NOMBRE || ' ' || APELLIDO AS ESTUDIANTE,
    SEMESTRE
FROM
    USUARIOS
WHERE
    ID_ROL = 1
    AND SEMESTRE = (
        SELECT
            MAX(SEMESTRE)
        FROM
            USUARIOS
        WHERE
            ID_ROL = 1
    );

-- Consulta E.5: Mostrar la cantidad de cursos ofertados por cada facultad.
SELECT
    f.ID_FACULTAD,
    f.NOMBRE AS FACULTAD,
    COUNT(DISTINCT cc.ID_CURSO) AS CURSOS_OFERTADOS_DISTINTOS,
    COUNT(cc.ID_CALENDARIO) AS TOTAL_SECCIONES_PROGRAMADAS
FROM
    FACULTADES f
    INNER JOIN CURSOS c ON f.ID_FACULTAD = c.ID_FACULTAD
    INNER JOIN CALENDARIO_CURSOS cc ON c.ID_CURSO = cc.ID_CURSO
GROUP BY
    f.ID_FACULTAD,
    f.NOMBRE
ORDER BY
    TOTAL_SECCIONES_PROGRAMADAS DESC;

-- Consulta E.6: Mostrar las facultades que tienen más de 3 carreras asociadas.
SELECT
    f.ID_FACULTAD,
    f.NOMBRE AS FACULTAD,
    COUNT(c.ID_CARRERA) AS TOTAL_CARRERAS
FROM
    FACULTADES f
    INNER JOIN CARRERAS c ON f.ID_FACULTAD = c.ID_FACULTAD
GROUP BY
    f.ID_FACULTAD,
    f.NOMBRE
HAVING
    COUNT(c.ID_CARRERA) > 3
ORDER BY
    TOTAL_CARRERAS DESC;

-- Consulta E.7: Mostrar la cantidad de estudiantes matriculados por cada carrera.
SELECT
    car.ID_CARRERA,
    car.NOMBRE AS CARRERA,
    COUNT(ce.ID_USUARIO) AS TOTAL_ESTUDIANTES
FROM
    CARRERAS car
    LEFT JOIN CARRERAS_ESTUDIANTES ce ON car.ID_CARRERA = ce.ID_CARRERA
GROUP BY
    car.ID_CARRERA,
    car.NOMBRE
ORDER BY
    TOTAL_ESTUDIANTES DESC;

-- Consulta E.8: Identificar la carrera con mayor cantidad de estudiantes matriculados.
SELECT
    car.ID_CARRERA,
    car.NOMBRE AS CARRERA,
    COUNT(ce.ID_USUARIO) AS TOTAL_ESTUDIANTES
FROM
    CARRERAS car
    INNER JOIN CARRERAS_ESTUDIANTES ce ON car.ID_CARRERA = ce.ID_CARRERA
GROUP BY
    car.ID_CARRERA,
    car.NOMBRE
ORDER BY
    TOTAL_ESTUDIANTES DESC
LIMIT
    1;

-- Consulta E.9: Mostrar el edificio con mayor cantidad de salones registrados.
SELECT
    e.ID_EDIFICIO,
    e.NOMBRE AS EDIFICIO,
    COUNT(s.ID_SALON) AS TOTAL_SALONES
FROM
    EDIFICIOS e
    INNER JOIN SALONES s ON e.ID_EDIFICIO = s.ID_EDIFICIO
GROUP BY
    e.ID_EDIFICIO,
    e.NOMBRE
ORDER BY
    TOTAL_SALONES DESC
LIMIT
    1;

-- Consulta E.10: Mostrar el total de cursos ofertados que orienta cada docente e identificar a los profesores que dictan más cursos.
SELECT
    u.ID_USUARIO,
    u.NOMBRE || ' ' || u.APELLIDO AS PROFESOR,
    COUNT(cc.ID_CALENDARIO) AS TOTAL_SECCIONES_DICTADAS,
    COUNT(DISTINCT cc.ID_CURSO) AS CURSOS_DISTINTOS_DICTADOS
FROM
    USUARIOS u
    INNER JOIN CALENDARIO_CURSOS cc ON u.ID_USUARIO = cc.ID_PROFESOR
WHERE
    u.ID_ROL = 2
GROUP BY
    u.ID_USUARIO,
    PROFESOR
ORDER BY
    TOTAL_SECCIONES_DICTADAS DESC;

-- Consulta E.11: Mostrar el número de matrículas realizadas por cada estudiante.
SELECT
    u.ID_USUARIO,
    u.NOMBRE || ' ' || u.APELLIDO AS ESTUDIANTE,
    u.SEMESTRE,
    COUNT(ce.ID_CALENDARIO) AS TOTAL_CURSOS_INSCRITOS
FROM
    USUARIOS u
    LEFT JOIN CURSOS_ESTUDIANTES ce ON u.ID_USUARIO = ce.ID_USUARIO
WHERE
    u.ID_ROL = 1
GROUP BY
    u.ID_USUARIO,
    ESTUDIANTE,
    u.SEMESTRE
ORDER BY
    TOTAL_CURSOS_INSCRITOS DESC;

-- Consulta E.12: Listar los estudiantes que están matriculados en menos de 10 cursos.
SELECT
    u.ID_USUARIO,
    u.NOMBRE || ' ' || u.APELLIDO AS ESTUDIANTE,
    u.SEMESTRE,
    COUNT(ce.ID_CALENDARIO) AS TOTAL_CURSOS_INSCRITOS
FROM
    USUARIOS u
    LEFT JOIN CURSOS_ESTUDIANTES ce ON u.ID_USUARIO = ce.ID_USUARIO
WHERE
    u.ID_ROL = 1
GROUP BY
    u.ID_USUARIO,
    ESTUDIANTE,
    u.SEMESTRE
HAVING
    COUNT(ce.ID_CALENDARIO) < 10
ORDER BY
    TOTAL_CURSOS_INSCRITOS ASC;

-- Consulta E.13: Identificar el curso con mayor cantidad de matrículas (inscripciones)
-- y el curso con mayor cantidad de estudiantes únicos.
SELECT
    c.ID_CURSO,
    c.NOMBRE AS CURSO,
    COUNT(ce.ID_USUARIO) AS TOTAL_INSCRIPCIONES,
    COUNT(DISTINCT ce.ID_USUARIO) AS ESTUDIANTES_UNICOS
FROM
    CURSOS c
    INNER JOIN CALENDARIO_CURSOS cc ON c.ID_CURSO = cc.ID_CURSO
    INNER JOIN CURSOS_ESTUDIANTES ce ON cc.ID_CALENDARIO = ce.ID_CALENDARIO
GROUP BY
    c.ID_CURSO,
    c.NOMBRE
ORDER BY
    TOTAL_INSCRIPCIONES DESC
LIMIT
    1;

-- Consulta E.14: Análisis de Demanda y Cupos:
-- Calcular cuántos estudiantes están inscritos actualmente en cada sección programada en CALENDARIO_CURSOS.
-- Mostrar ID_CALENDARIO, nombre del curso, día, CUPO máximo y cantidad de inscritos,
-- filtrando únicamente las secciones que tengan 5 o más estudiantes inscritos.
SELECT
    cc.ID_CALENDARIO,
    c.NOMBRE AS CURSO,
    cc.DIA,
    cc.HORA_INICIO || ' - ' || cc.HORA_FIN AS HORARIO,
    cc.CUPO AS CUPO_MAXIMO,
    COUNT(ce.ID_USUARIO) AS ESTUDIANTES_INSCRITOS,
    ROUND((COUNT(ce.ID_USUARIO) * 100.0 / cc.CUPO), 1) AS PORCENTAJE_OCUPACION
FROM
    CALENDARIO_CURSOS cc
    INNER JOIN CURSOS c ON cc.ID_CURSO = c.ID_CURSO
    INNER JOIN CURSOS_ESTUDIANTES ce ON cc.ID_CALENDARIO = ce.ID_CALENDARIO
GROUP BY
    cc.ID_CALENDARIO,
    c.NOMBRE,
    cc.DIA,
    cc.HORA_INICIO,
    cc.HORA_FIN,
    cc.CUPO
HAVING
    COUNT(ce.ID_USUARIO) >= 5
ORDER BY
    ESTUDIANTES_INSCRITOS DESC;

-- ==============================================================================
-- PARTE II: RETOS INTEGRADORES E INTELIGENCIA ARTIFICIAL
-- ==============================================================================
-- Reto Integrador 1: Carga Académica por Carrera (Agregación Múltiple)
-- Obtén un resumen consolidado por cada carrera que muestre:
-- - Nombre de la carrera
-- - Nombre de su facultad
-- - Total de cursos que componen su malla curricular (CURSOS_CARRERAS)
-- - Número de estudiantes matriculados en dicha carrera (CARRERAS_ESTUDIANTES)
--
-- Nota técnica: Se emplean subconsultas agregadas independientes (CTEs) para evitar
-- el producto cartesiano entre CURSOS_CARRERAS y CARRERAS_ESTUDIANTES.
WITH
    MallaCurricular AS (
        SELECT
            ID_CARRERA,
            COUNT(ID_CURSO) AS TOTAL_CURSOS_MALLA
        FROM
            CURSOS_CARRERAS
        GROUP BY
            ID_CARRERA
    ),
    MatriculaEstudiantes AS (
        SELECT
            ID_CARRERA,
            COUNT(ID_USUARIO) AS TOTAL_ESTUDIANTES_MATRICULADOS
        FROM
            CARRERAS_ESTUDIANTES
        GROUP BY
            ID_CARRERA
    )
SELECT
    car.ID_CARRERA,
    car.NOMBRE AS CARRERA,
    fac.NOMBRE AS FACULTAD,
    COALESCE(mc.TOTAL_CURSOS_MALLA, 0) AS CURSOS_MALLA,
    COALESCE(me.TOTAL_ESTUDIANTES_MATRICULADOS, 0) AS ESTUDIANTES_MATRICULADOS
FROM
    CARRERAS car
    INNER JOIN FACULTADES fac ON car.ID_FACULTAD = fac.ID_FACULTAD
    LEFT JOIN MallaCurricular mc ON car.ID_CARRERA = mc.ID_CARRERA
    LEFT JOIN MatriculaEstudiantes me ON car.ID_CARRERA = me.ID_CARRERA
ORDER BY
    ESTUDIANTES_MATRICULADOS DESC,
    CURSOS_MALLA DESC;

-- Reto Integrador 2: Auditoría Text-to-SQL con el Agente de Antigravity
-- Promt en lenguaje natural: "Identifica qué estudiantes tienen cruces de horario (dos clases el mismo día y a la misma hora) en university_db"
--
-- Consulta generada por el Agente / Optimizada para auditoría:
SELECT
    u.ID_USUARIO,
    u.NOMBRE || ' ' || u.APELLIDO AS ESTUDIANTE,
    c1.DIA,
    cur1.NOMBRE AS CURSO_1,
    c1.HORA_INICIO || ' - ' || c1.HORA_FIN AS HORARIO_1,
    cur2.NOMBRE AS CURSO_2,
    c2.HORA_INICIO || ' - ' || c2.HORA_FIN AS HORARIO_2
FROM
    CURSOS_ESTUDIANTES ce1
    INNER JOIN CURSOS_ESTUDIANTES ce2 ON ce1.ID_USUARIO = ce2.ID_USUARIO
    AND ce1.ID_CALENDARIO < ce2.ID_CALENDARIO -- Evita duplicados reflejados y comparación de la misma sección
    INNER JOIN CALENDARIO_CURSOS c1 ON ce1.ID_CALENDARIO = c1.ID_CALENDARIO
    INNER JOIN CALENDARIO_CURSOS c2 ON ce2.ID_CALENDARIO = c2.ID_CALENDARIO
    INNER JOIN CURSOS cur1 ON c1.ID_CURSO = cur1.ID_CURSO
    INNER JOIN CURSOS cur2 ON c2.ID_CURSO = cur2.ID_CURSO
    INNER JOIN USUARIOS u ON ce1.ID_USUARIO = u.ID_USUARIO
WHERE
    c1.DIA = c2.DIA
    -- Solapamiento de intervalos temporales: [Inicio1 < Fin2] Y [Inicio2 < Fin1]
    AND (
        c1.HORA_INICIO < c2.HORA_FIN
        AND c2.HORA_INICIO < c1.HORA_FIN
    )
ORDER BY
    u.ID_USUARIO,
    c1.DIA,
    c1.HORA_INICIO;

/* ==============================================================================
Fin del Script SQL
============================================================================== */