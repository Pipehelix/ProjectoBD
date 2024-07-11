import psycopg2
from datetime import date, time

# conecion db analisis
conn_modelo_estrella = psycopg2.connect(
    host="localhost", 
    database=" ",  
    user="postgres",       
    password=" "   
)

# conexion relacional
conn_relacional = psycopg2.connect(
    host="localhost", 
    database=" ",  
    user="postgres",       
    password=" "   
)

def obtener_diccionarios(conn_modelo_estrella):
    try:
        cur = conn_modelo_estrella.cursor()

        
        cur.execute("SELECT rut, id_tabla_cliente FROM id_tabla_cliente")
        cliente_dic = {row[0]: row[1] for row in cur.fetchall()}
        
    
        cur.execute("SELECT rut, id_tabla_empleados FROM id_tabla_empleados")
        empleado_dic = {row[0]: row[1] for row in cur.fetchall()}

       
        cur.execute("SELECT id_sede, id_tabla_sede FROM id_tabla_sede")
        sede_dic = {row[0]: row[1] for row in cur.fetchall()}

        cur.execute("SELECT tipo, id_tabla_servicios FROM id_tabla_servicios")
        servicios_dic = {row[0]: row[1] for row in cur.fetchall()}

        return cliente_dic, empleado_dic, sede_dic, servicios_dic

    except psycopg2.Error as e:
        print("Error al obtener los diccionarios:", e)

    finally:
        cur.close()
    
def transferir(cone1, cone2):
    cliente_dic, empleado_dic, sede_dic, servicios_dic = obtener_diccionarios(conn_modelo_estrella)
    cur1=cone1.cursor()
    cur2=cone2.cursor()
    cur1.execute("""SELECT c.id_cita, c.precio, c.fecha, c.hora_inicio, c.hora_fin, v.id_venta, v.fecha, c.rut, c.id_sede, s.tipo, dds.rut, s.precio from cita c 
                  JOIN cliente cl ON c.rut = cl.rut
                  JOIN detalles_de_servicio dds ON c.id_cita = dds.id_cita 
                  JOIN servicios s ON dds.id_serv = s.id_serv
                  JOIN venta v ON cl.rut = v.rut""")
    consulta=cur1.fetchall()
    for fila in consulta:
            id_cita=fila[0]
            precio_cita=fila[1]
            fecha_cita=fila[2]
            hora_inicio=fila[3]
            hora_fin=fila[4]
            id_venta=fila[5]
            fecha_venta=fila[6]
            rut_cliente = fila[7]
            id_sede = fila[8]
            tipo_servicio = fila[9]
            rut_empleado = fila[10]
            precio_servicio=fila[11]
            total = precio_servicio+precio_cita
            
            id_tabla_cliente = cliente_dic.get(rut_cliente)
            id_tabla_sede = sede_dic.get(id_sede)
            id_tabla_servicio = servicios_dic.get(tipo_servicio)
            id_tabla_empleado = empleado_dic.get(rut_empleado)
            
            
           
            cur2.execute("""
                INSERT INTO analisis (id_cita, precio_cita, fecha_cita, hora_inicio, hora_fin, id_venta, fecha_venta, total, id_tabla_cliente, id_tabla_sede,id_tabla_empleados, id_tabla_servicios)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (id_cita, precio_cita, fecha_cita, hora_inicio, hora_fin, id_venta, fecha_venta, total, id_tabla_cliente, id_tabla_sede,id_tabla_empleado, id_tabla_servicio))
    cone2.commit()
    cone1.close()
    cone2.close()

transferir(conn_relacional,conn_modelo_estrella)
conn_relacional.close()
conn_modelo_estrella.close()