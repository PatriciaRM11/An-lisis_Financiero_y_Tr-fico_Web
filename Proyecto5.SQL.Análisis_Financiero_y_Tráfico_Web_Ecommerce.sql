#Proyecto 5 SQL: Análisis Financiero y Tráfico Web - Ecommerce

#Análisis Exploratorio
use tienda_unicornio_feliz;
#N_Registros, min(fecha), max(fecha) 
select min(fecha_creacion), max(fecha_creacion), count(*) as registros from tienda_unicornio_feliz.pedido_articulo;

#Revisar diferentes importes
select avg(precio) as precio_medio, avg(costo) as coste_medio from tienda_unicornio_feliz.pedidos;

#Suma total de importes por mes
select month(fecha_creacion), sum(precio) as total_ventas, sum(costo) as total_coste from tienda_unicornio_feliz.pedidos 
group by month(fecha_creacion) order by 2 desc;

#Ejecucion. Resolucion de las Preguntas de Negocio
#Análisis financiero 

#1.¿Cuales son las ventas por año?
select year(fecha_creacion) as año, sum(precio) as total_ventas_por_año from tienda_unicornio_feliz.pedidos 
group by year(fecha_creacion) order by sum(precio) desc;

#2.¿Cuales son las ventas medias de cada mes y año?
select year(fecha_creacion) as año, month(fecha_creacion) as mes, avg(precio) as ventas_medias from tienda_unicornio_feliz.pedidos 
group by year(fecha_creacion), month(fecha_creacion) order by 1 desc, 2 asc;

#3.¿Cuál es el producto que mas vende en términos monetarios?
SELECT P.NOMBRE_PRODUCTO,SUM(PRECIO) AS VENTA_ARTICULO
FROM pedido_articulo pa
LEFT JOIN PRODUCTOS p
ON p.ID_PRODUCTO = pa.ID_PRODUCTO
GROUP BY P.ID_PRODUCTO
ORDER BY 2 DESC
LIMIT 1;

#4.¿Cuál es el margen bruto que deja cada producto?
SELECT DISTINCT ID_PRODUCTO,PRECIO-COSTO AS MARGEN_BRUTO FROM PEDIDO_ARTICULO;

#5.¿Podemos saber cúal es la fecha de lanzamiento de cada producto?
#Entendamos como fecha de lanzamiento la fecha en la que se da de alta el producto en la tabla de productos.
SELECT ID_PRODUCTO,FECHA_CREACION FROM PRODUCTOS;

#6.Calcula las ventas por año, asi como el margen numérico. Tambien queremos saber que % representa cada producto sobre las ventas totales.
#Obtenemos primero las ventas y el margen por anyo y mes.
SELECT YEAR(FECHA_CREACION) AS ANYO, SUM(PRECIO) AS VENTAS, SUM(PRECIO-COSTO) AS MARGEN FROM PEDIDO_ARTICULO 
GROUP BY ANYO;

#Adicionalmente, calculamos el % que supone cada producto sobre el total. 
SELECT ID_PRODUCTO,(SUM(PRECIO)/(SELECT SUM(PRECIO) FROM PEDIDO_ARTICULO))*100 AS PCT FROM PEDIDO_ARTICULO GROUP BY ID_PRODUCTO;

#7.¿Cuáles son los TOP 3 meses con mayor venta?
SELECT MONTH(FECHA_CREACION) AS MES, SUM(PRECIO) AS VENTAS FROM PEDIDO_ARTICULO 
GROUP BY MES ORDER BY VENTAS DESC LIMIT 3;

#8.¿Cuál es el margen bruto por producto y que porcentaje ocupa del margen total?
SELECT ID_PRODUCTO, SUM(PRECIO-COSTO) AS MARGEN_BRUTO, ROUND(SUM(PRECIO-COSTO)/(SELECT SUM(PRECIO-COSTO)
 FROM PEDIDO_ARTICULO)*100,2) AS PCT_MARGEN FROM PEDIDO_ARTICULO GROUP BY ID_PRODUCTO;

#9.¿Cuál es el margen de beneficio bruto promedio por línea de producto en el último trimestre de los datos de la empresa?
SELECT DISTINCT YEAR(FECHA_CREACION) ANYO,MONTH(FECHA_CREACION) MES,QUARTER(FECHA_CREACION) TRIMESTRE 
FROM PEDIDO_ARTICULO ORDER BY 1 DESC,2 DESC;

SELECT ID_PRODUCTO,SUM(PRECIO-COSTO) FROM PEDIDO_ARTICULO WHERE QUARTER(FECHA_CREACION) = 1 AND YEAR(FECHA_CREACION)=2015 
GROUP BY ID_PRODUCTO;

SELECT ID_PRODUCTO,SUM(PRECIO-COSTO) FROM PEDIDO_ARTICULO WHERE MONTH(FECHA_CREACION) IN(1,2,3) AND YEAR(FECHA_CREACION)=2015 
GROUP BY ID_PRODUCTO;

#10.¿Cúal es el porcentaje de devolución de artículos?
SELECT COUNT(*)/(SELECT COUNT(*) FROM PEDIDO_ARTICULO)*100 FROM PEDIDO_ARTICULO_REEMBOLSOS;

#PORCENTAJE DE PEDIDOS CON REEMBOLSO

SELECT COUNT(DISTINCT ID_PEDIDO) NUM_PEDID_REM,COUNT(*) NUM_REMB,COUNT(DISTINCT ID_PEDIDO)/(SELECT COUNT(ID_PEDIDO) FROM PEDIDOS)*100
  FROM PEDIDO_ARTICULO_REEMBOLSOS;
  
### Análisis de trafico web
    
#11. ¿Cúal es la cantidad de sesiones por tipo de dispositivo?
SELECT TIPO_DISPOSITIVO,COUNT(ID_SESION_WEB) AS NUM_SESIONES FROM SESIONES_WEB GROUP BY TIPO_DISPOSITIVO;

#12. ¿Es lo mismo sesiones que usuarios?¿Cuál es la cantidad de usuarios únicos? ¿Y cúal es la cantidad de sesiones?
SELECT COUNT(ID_SESION_WEB) NUM_SESIONES,COUNT(DISTINCT ID_USUARIO) NUM_USUARIO_DIST FROM SESIONES_WEB;

#13. ¿Cúales son los 5 meses que ha habido más trafico en la web?
SELECT MONTH(FECHA_CREACION) MES,COUNT(ID_SESION_WEB) FROM SESIONES_WEB GROUP BY MES ORDER BY 2 DESC LIMIT 6;

#14. ¿Cuál es la principal fuente de tráfico?
SELECT * FROM SESIONES_WEB;
Select utm_source,Count(*) from SESIONES_WEB GROUP by utm_source order by 2 desc;

#15. ¿Cúales son las fuentes de tráfico que han dado más ventas?
SELECT utm_source,SUM(PRECIO) AS VENTAS FROM SESIONES_WEB S
RIGHT JOIN PEDIDOS P
ON S.ID_SESION_WEB = P.ID_SESION_WEB
GROUP BY utm_source; 

SELECT utm_source,SUM(PRECIO) AS VENTAS FROM SESIONES_WEB S
LEFT JOIN PEDIDOS P
ON S.ID_SESION_WEB = P.ID_SESION_WEB
GROUP BY utm_source; 

SELECT SUM(VENTAS) FROM(
SELECT utm_source,SUM(PRECIO) AS VENTAS FROM SESIONES_WEB S
INNER JOIN PEDIDOS P
ON S.ID_SESION_WEB = P.ID_SESION_WEB
GROUP BY utm_source) A; 

#16. ¿Podrías mostrar las ventas y cantidad de sesiones por fuentes de tráfico  asi como el porcentaje del total de cada métrica?
select * from SESIONES_WEB;
SELECT s.utm_source,sum(precio) as ventas,round(sum(precio)/(select sum(precio) from pedidos)*100,2) as '%_total',
count(*) as num_sesiones
FROM pedidos p
left join SESIONES_WEB s
on p.id_sesion_web = s.id_sesion_web
group by s.utm_source;

#17.  ¿Cúal es el porcentaje de conversión de tráfico a ventas?
SELECT COUNT(*) FROM PEDIDOS;  
SELECT (SELECT COUNT(*) FROM PEDIDOS) / COUNT(*)*100 AS PCT_CONV FROM SESIONES_WEB;

#18. ¿Que porcentaje de usuarios repiten?
SELECT DISTINCT ES_SESION_REPETIDA FROM SESIONES_WEB;
SELECT * FROM SESIONES_WEB WHERE ES_SESION_REPETIDA=1;
SELECT * FROM SESIONES_WEB WHERE ID_USUARIO=489;
#BUSCAMOS USUARIOS QUE SE CONECTEN MAS DE DOS VECES
SELECT ID_USUARIO,COUNT(*) FROM SESIONES_WEB GROUP BY ID_USUARIO ORDER BY 2 DESC;
SELECT * FROM SESIONES_WEB WHERE ID_USUARIO=158032;
SELECT COUNT(DISTINCT ID_USUARIO)/(SELECT COUNT(DISTINCT ID_USUARIO) FROM SESIONES_WEB)*100 FROM SESIONES_WEB WHERE ES_SESION_REPETIDA=1;
#POSIBLE NO OK
SELECT COUNT(*)/COUNT(ID_USUARIO)*100 FROM SESIONES_WEB WHERE ES_SESION_REPETIDA=1;

#19.  Podrias calcular la cantidad de pedidos diferencias por días entre que entra a la web y realiza el pedido?
#Calculamos la fecha de primera conexión de un usuario
SELECT ID_USUARIO,MIN(FECHA_CREACION) FECHA_PRIM_SESION FROM SESIONES_WEB GROUP BY ID_USUARIO;

#Realizamos una join entre el pedido, su fecha de pedido y el usuario, y cruzamos esa info con la consulta anterior. Agrupamos por diferencia de dias y contamos el numero de pedidos.
SELECT -- ID_PEDIDO,P.FECHA_CREACION AS FECHA_PEDIDO,FECHA_PRIM_SESION,
datediff(P.FECHA_CREACION,S.FECHA_PRIM_SESION) DIF,COUNT(*) FROM PEDIDOS P
LEFT JOIN (SELECT ID_USUARIO,MIN(FECHA_CREACION) FECHA_PRIM_SESION FROM SESIONES_WEB GROUP BY ID_USUARIO) S
ON P.ID_USUARIO = S.ID_USUARIO
GROUP BY DIF
ORDER BY DIF ASC;

#Vemos que la mayoria de pedidos se hacen el mismo dia que el usuario se conecta por primera vez.

#20. ¿Cúales son las ventas generadas por campaña?
SELECT s.utm_campaign,sum(precio) as VENTAS FROM pedidos p
left join SESIONES_WEB s
on p.id_sesion_web = s.id_sesion_web
group by s.utm_campaign;  