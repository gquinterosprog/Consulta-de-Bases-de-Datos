/*
    Consulta de Bases de Datos - PRY2205
    Sumativa 1 - Semana 3 - Forma B
    Estudiante: Gabriel Quinteros

    Preparacion: ejecutar por separado los scripts originales de usuario
    y de creacion y poblado. Abrir este archivo como PRY2205_S3 en la
    conexion PRY2205_ACTIVIDAD_S3 y ejecutar con F5.

    Datos de prueba (ingresar solo numeros, sin puntos ni comillas):
    Caso 1: VALOR_TOTAL_GASTO_COMUN = 100000.
    Caso 2: CODIGO_SUCURSAL = 30.
*/

-- CASO 1: Analisis de propiedades.
-- Los gastos comunes nulos se consideran cero.
SELECT id_tipo_propiedad AS "TIPO",
       COUNT(*) AS "TOTAL_PROPIEDADES",
       '$' || LTRIM(REPLACE(TO_CHAR(MAX(valor_arriendo),
                                   '999,999,990'), ',', '.')) AS "MAX_ARRIENDO",
       '$' || LTRIM(REPLACE(TO_CHAR(ROUND(AVG(valor_arriendo)),
                                   '999,999,990'), ',', '.')) AS "PROMEDIO_ARRIENDO",
       '$' || LTRIM(REPLACE(TO_CHAR(MIN(valor_arriendo),
                                   '999,999,990'), ',', '.')) AS "MIN_ARRIENDO",
       CASE
           WHEN MAX(valor_arriendo) <= 1000000 THEN 'ESTÁNDAR'
           ELSE 'PREMIUM'
       END AS "CLASIFICACION",
       LTRIM(REPLACE(TO_CHAR(SUM(NVL(valor_gasto_comun, 0)),
                            '999,999,990'), ',', '.')) AS "TOTAL_GASTOS_COMUNES"
FROM propiedad
GROUP BY id_tipo_propiedad
HAVING SUM(NVL(valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(valor_gasto_comun, 0)) DESC;


-- CASO 2: Analisis de antiguedad de empleados.
-- TRUNC obtiene los anios cumplidos; ROUND redondea el monto del bono.
SELECT nombre_emp || ' ' || appaterno_emp AS "Nombre Empleado",
       '$' || LTRIM(REPLACE(TO_CHAR(sueldo_emp,
                                   '999,999,990'), ',', '.')) AS "Sueldo con Formato",
       CASE
           WHEN sueldo_emp > 2000000 THEN 'ALTO'
           ELSE 'MEDIO'
       END AS "Clasificación Sueldo",
       TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) AS "Años Antigüedad",
       CASE
           WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 5 AND 10
               THEN 'Corresponde bono 5%: '
           WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 11 AND 20
               THEN 'Corresponde bono 10%: '
           ELSE 'Corresponde bono 15%: '
       END || '$' || LTRIM(REPLACE(TO_CHAR(ROUND(sueldo_emp *
           CASE
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 5 AND 10
                   THEN 0.05
               WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 11 AND 20
                   THEN 0.10
               ELSE 0.15
           END), '999,999,990'), ',', '.')) AS "BONO"
FROM empleado
WHERE id_categoria_emp = 3
  AND id_sucursal <> &CODIGO_SUCURSAL
  AND MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12 > 5
ORDER BY sueldo_emp DESC;


-- CASO 3: Lista de clientes.
-- Se considera el celular o, si es nulo, el telefono fijo.
-- Con los datos originales todos los segmentos tienen telefono,
-- incluido ALTA, aunque la imagen referencial indica lo contrario.
SELECT CASE
           WHEN renta_cli >= 1000000 THEN 'PREMIUM'
           WHEN renta_cli >= 600000 THEN 'ALTA'
           WHEN renta_cli >= 300000 THEN 'MEDIA'
           ELSE 'BAJA'
       END AS "CLASIFICACION_RENTA",
       COUNT(*) AS "CANTIDAD_CLIENTES",
       '$' || LTRIM(REPLACE(TO_CHAR(ROUND(AVG(renta_cli)),
                                   '999,999,990'), ',', '.')) AS "RENTA_PROMEDIO",
       CASE
           WHEN COUNT(NVL(celular_cli, fonofijo_cli)) = 0 THEN 'Clientes Sin Teléfono'
           ELSE 'Clientes con Teléfono'
       END AS "ESTADO_TELEFONO"
FROM cliente
GROUP BY CASE
             WHEN renta_cli >= 1000000 THEN 'PREMIUM'
             WHEN renta_cli >= 600000 THEN 'ALTA'
             WHEN renta_cli >= 300000 THEN 'MEDIA'
             ELSE 'BAJA'
         END
HAVING AVG(renta_cli) > 200000;
