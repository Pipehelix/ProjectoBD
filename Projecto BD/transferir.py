import psycopg2

# conexion relacional
conn_relacional = psycopg2.connect(
    host="localhost", 
    database=" ",  
    user="postgres",       
    password=" "   
)
# conexion analisis
conn_modelo_estrella = psycopg2.connect(
    host="localhost", 
    database=" ",  
    user="postgres",       
    password=" "   
)

def llenar_tabla_cliente(conn_relacional, conn_modelo_estrella):
    try:
        cur_relacional = conn_relacional.cursor()
        cur_modelo_estrella = conn_modelo_estrella.cursor()

        cur_relacional.execute("SELECT rut, nombre, comuna, genero FROM cliente")

        for row in cur_relacional.fetchall():
            cur_modelo_estrella.execute("""
                INSERT INTO id_tabla_cliente (rut, nombre, comuna, genero)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (rut) DO UPDATE SET
                    nombre = EXCLUDED.nombre,
                    comuna = EXCLUDED.comuna,
                    genero = EXCLUDED.genero
            """, (row[0], row[1], row[2], row[3]))

        conn_modelo_estrella.commit()
        print("Tabla id_tabla_cliente llenada correctamente.")

    except psycopg2.Error as e:
        conn_modelo_estrella.rollback()
        print("Error al llenar la tabla id_tabla_cliente:", e)

    finally:
        cur_relacional.close()
        cur_modelo_estrella.close()

def llenar_tabla_sede(conn_relacional, conn_modelo_estrella):
    try:
        cur_relacional = conn_relacional.cursor()
        cur_modelo_estrella = conn_modelo_estrella.cursor()

        cur_relacional.execute("SELECT id, nombre, comuna FROM sede")

        for row in cur_relacional.fetchall():
            cur_modelo_estrella.execute("""
                INSERT INTO id_tabla_sede (id_sede, nombre, comuna)
                VALUES (%s, %s, %s)
                ON CONFLICT (id_sede) DO UPDATE SET
                    nombre = EXCLUDED.nombre,
                    comuna = EXCLUDED.comuna
            """, (row[0], row[1], row[2]))

        conn_modelo_estrella.commit()
        print("Tabla id_tabla_sede llenada correctamente.")

    except psycopg2.Error as e:
        conn_modelo_estrella.rollback()
        print("Error al llenar la tabla id_tabla_sede:", e)

    finally:
        cur_relacional.close()
        cur_modelo_estrella.close()

def llenar_tabla_empleados(conn_relacional, conn_modelo_estrella):
    try:
        cur_relacional = conn_relacional.cursor()
        cur_modelo_estrella = conn_modelo_estrella.cursor()

        cur_relacional.execute("SELECT rut, nombre, trabajo, sueldo FROM empleados")

        for row in cur_relacional.fetchall():
            cur_modelo_estrella.execute("""
                INSERT INTO id_tabla_empleados (rut, nombre, trabajo, sueldo)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (rut) DO UPDATE SET
                    nombre = EXCLUDED.nombre,
                    trabajo = EXCLUDED.trabajo,
                    sueldo = EXCLUDED.sueldo
            """, (row[0], row[1], row[2], row[3]))

        conn_modelo_estrella.commit()
        print("Tabla id_tabla_empleados llenada correctamente.")

    except psycopg2.Error as e:
        conn_modelo_estrella.rollback()
        print("Error al llenar la tabla id_tabla_empleados:", e)

    finally:
        cur_relacional.close()
        cur_modelo_estrella.close()

def llenar_tabla_servicios(conn_relacional, conn_modelo_estrella):
    try:
        cur_relacional = conn_relacional.cursor()
        cur_modelo_estrella = conn_modelo_estrella.cursor()

        cur_relacional.execute("SELECT tipo, precio FROM servicios")

        for row in cur_relacional.fetchall():
            cur_modelo_estrella.execute("""
                INSERT INTO id_tabla_servicios (tipo, precio)
                VALUES (%s, %s)
                ON CONFLICT (tipo) DO UPDATE SET
                    precio = EXCLUDED.precio
            """, (row[0], row[1]))

        conn_modelo_estrella.commit()
        print("Tabla id_tabla_servicios llenada correctamente.")

    except psycopg2.Error as e:
        conn_modelo_estrella.rollback()
        print("Error al llenar la tabla id_tabla_servicios:", e)

    finally:
        cur_relacional.close()
        cur_modelo_estrella.close()

def main():
    llenar_tabla_cliente(conn_relacional, conn_modelo_estrella)
    llenar_tabla_sede(conn_relacional, conn_modelo_estrella)
    llenar_tabla_empleados(conn_relacional, conn_modelo_estrella)
    llenar_tabla_servicios(conn_relacional, conn_modelo_estrella)

    conn_relacional.close()
    conn_modelo_estrella.close()

if __name__ == "__main__":
    main()
