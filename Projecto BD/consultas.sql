--1-
WITH citas_por_hora AS (
    SELECT 
        s.id_tabla_sede, 
        s.nombre AS peluqueria, 
        s.comuna AS comuna_peluqueria, 
        EXTRACT(HOUR FROM a.hora_inicio) AS hora, 
        COUNT(a.id_cita) AS cantidad_citas
    FROM 
        analisis a
    JOIN 
        id_tabla_sede s ON a.id_tabla_sede = s.id_tabla_sede
    GROUP BY 
        s.id_tabla_sede, s.nombre, s.comuna, EXTRACT(HOUR FROM a.hora_inicio)
),
max_citas_por_peluqueria AS (
    SELECT 
        id_tabla_sede, 
        MAX(cantidad_citas) AS max_citas
    FROM 
        citas_por_hora
    GROUP BY 
        id_tabla_sede
)
SELECT 
    cph.peluqueria, 
    cph.comuna_peluqueria, 
    cph.hora, 
    cph.cantidad_citas
FROM 
    citas_por_hora cph
JOIN 
    max_citas_por_peluqueria mcp 
    ON cph.id_tabla_sede = mcp.id_tabla_sede 
    AND cph.cantidad_citas = mcp.max_citas
ORDER BY 
    cph.peluqueria, cph.hora;
--2
WITH gasto_total_por_cliente AS (
    SELECT 
        s.nombre AS peluqueria,
        s.comuna AS comuna_peluqueria,
        c.nombre AS cliente,
        c.comuna AS comuna_cliente,
        SUM(a.total) AS total_gastado
    FROM 
        analisis a
    JOIN 
        id_tabla_cliente c ON a.id_tabla_cliente = c.id_tabla_cliente
    JOIN 
        id_tabla_sede s ON a.id_tabla_sede = s.id_tabla_sede
    GROUP BY 
        s.nombre, s.comuna, c.nombre, c.comuna
)
SELECT 
    peluqueria,
    comuna_peluqueria,
    cliente,
    comuna_cliente,
    total_gastado
FROM 
    gasto_total_por_cliente
WHERE 
    (peluqueria, total_gastado) IN (
        SELECT 
            peluqueria, MAX(total_gastado)
        FROM 
            gasto_total_por_cliente
        GROUP BY 
            peluqueria
    );
--4
SELECT DISTINCT
    c.nombre AS cliente,
    c.comuna AS comuna_cliente
FROM
    analisis a
JOIN
    id_tabla_cliente c ON a.id_tabla_cliente = c.id_tabla_cliente
JOIN
    id_tabla_servicios s ON a.id_tabla_servicios = s.id_tabla_servicios
WHERE
    s.tipo = 'Corte de barba y pelo'
    AND c.genero = 'Hombre';
   
--3 x
SELECT
    s.nombre AS peluqueria,
    EXTRACT(MONTH FROM a.fecha_venta) AS mes,
    e.nombre AS peluquero,
    SUM(a.total) AS total_ganado
FROM
    analisis a
JOIN
    id_tabla_sede s ON a.id_tabla_sede = s.id_tabla_sede
JOIN
    id_tabla_empleados e ON a.id_tabla_empleados = e.id_tabla_empleados
WHERE
    EXTRACT(YEAR FROM a.fecha_venta) = 2023
GROUP BY
    s.nombre, EXTRACT(MONTH FROM a.fecha_venta), e.nombre
HAVING
    SUM(a.total) = (
        SELECT MAX(sum_total)
        FROM (
            SELECT
                SUM(a.total) AS sum_total
            FROM
                analisis a
                JOIN id_tabla_sede s ON a.id_tabla_sede = s.id_tabla_sede
                JOIN id_tabla_empleados e ON a.id_tabla_empleados = e.id_tabla_empleados
            WHERE
                EXTRACT(YEAR FROM a.fecha_venta) = 2023
                AND s.nombre = peluqueria
                AND EXTRACT(MONTH FROM a.fecha_venta) = mes
            GROUP BY
                s.nombre, EXTRACT(MONTH FROM a.fecha_venta), e.nombre
        ) AS maximos_por_mes
    );

--5
SELECT DISTINCT
    c.comuna AS comuna_cliente,
    s.nombre AS peluqueria,
    a.total AS valor_pagado,
    a.id_cita
FROM
    analisis a
JOIN
    id_tabla_cliente c ON a.id_tabla_cliente = c.id_tabla_cliente
JOIN
    id_tabla_sede s ON a.id_tabla_sede = s.id_tabla_sede
JOIN
    id_tabla_servicios se ON a.id_tabla_servicios = se.id_tabla_servicios
WHERE
    se.tipo = 'Teñir pelo';

--6
WITH horarios_concurridos AS (
    SELECT
        s.nombre AS peluqueria,
        EXTRACT(YEAR FROM a.fecha_cita) AS año,
        EXTRACT(MONTH FROM a.fecha_cita) AS mes,
        a.hora_inicio AS horario_mas_concurrido,
        COUNT(*) AS cantidad_citas,
        ROW_NUMBER() OVER(PARTITION BY s.nombre, EXTRACT(YEAR FROM a.fecha_cita), EXTRACT(MONTH FROM a.fecha_cita) ORDER BY COUNT(*) DESC) AS rn
    FROM
        analisis a
    JOIN
        id_tabla_sede s ON a.id_tabla_sede = s.id_tabla_sede
    WHERE
        EXTRACT(YEAR FROM a.fecha_cita) IN (2022, 2023)
    GROUP BY
        s.nombre, año, mes, a.hora_inicio
)
SELECT
    peluqueria,
    año,
    mes,
    horario_mas_concurrido,
    cantidad_citas
FROM
    horarios_concurridos
WHERE
    rn = 1;
   
--7
   
WITH citas_mas_largas AS (
    SELECT
        s.nombre AS peluqueria,
        EXTRACT(YEAR FROM a.fecha_cita) AS año,
        EXTRACT(MONTH FROM a.fecha_cita) AS mes,
        c.nombre AS nombre_cliente,
        a.id_cita,
        a.hora_inicio,
        a.hora_fin,
        ROW_NUMBER() OVER(PARTITION BY s.nombre, EXTRACT(YEAR FROM a.fecha_cita), EXTRACT(MONTH FROM a.fecha_cita) ORDER BY (a.hora_fin - a.hora_inicio) DESC) AS rn
    FROM
        analisis a
    JOIN
        id_tabla_sede s ON a.id_tabla_sede = s.id_tabla_sede
    JOIN
        id_tabla_cliente c ON a.id_tabla_cliente = c.id_tabla_cliente
    WHERE
        EXTRACT(YEAR FROM a.fecha_cita) = 2023  -- Cambiar el año según necesidad
)
SELECT
    peluqueria,
    año,
    mes,
    nombre_cliente,
    id_cita,
    hora_inicio,
    hora_fin
FROM
    citas_mas_largas
WHERE
    rn = 1;

--8
   SELECT DISTINCT 
    s.nombre AS peluqueria,
    se.tipo AS servicio_mas_caro,
    se.precio AS precio_servicio
FROM
    id_tabla_sede s
JOIN
    analisis a ON s.id_tabla_sede = a.id_tabla_sede
JOIN
    id_tabla_servicios se ON a.id_tabla_servicios = se.id_tabla_servicios
WHERE
    se.precio = (
        SELECT MAX(precio)
        FROM id_tabla_servicios
    );

--9
SELECT DISTINCT ON (mes)
    s.nombre AS peluqueria,
    EXTRACT(MONTH FROM a.fecha_cita) AS mes,
    COUNT(*) AS cantidad_citas
FROM
    analisis a
JOIN
    id_tabla_sede s ON a.id_tabla_sede = s.id_tabla_sede
WHERE
    EXTRACT(YEAR FROM a.fecha_cita) = 2023
GROUP BY
    s.nombre, mes
ORDER BY
    mes, cantidad_citas DESC;


--10 sin peluqueria
   SELECT
    c.comuna,
    COUNT(DISTINCT s.id_sede) AS cantidad_peluquerias,
    COUNT(DISTINCT c.id_tabla_cliente) AS cantidad_clientes
FROM
    id_tabla_cliente c
LEFT JOIN
    id_tabla_sede s ON c.comuna = s.comuna
GROUP BY
    c.comuna
ORDER BY
    c.comuna;
--10 con
SELECT
    c.comuna,
    COUNT(DISTINCT s.id_sede) AS cantidad_peluquerias,
    COUNT(DISTINCT c.id_tabla_cliente) AS cantidad_clientes
FROM
    id_tabla_cliente c
INNER JOIN
    id_tabla_sede s ON c.comuna = s.comuna
GROUP BY
    c.comuna
ORDER BY
    c.comuna;











