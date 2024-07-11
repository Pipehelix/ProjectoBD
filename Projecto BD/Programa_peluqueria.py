import psycopg2
from psycopg2 import sql
from datetime import datetime

# conexion a la db
conn = psycopg2.connect(
    host="localhost", 
    database=" ",  
    user="postgres",       
    password=" "   
)
cursor = conn.cursor()

def verificar_existencia(tabla, columna_verificar, valor_verificar):
    query = sql.SQL("SELECT EXISTS(SELECT 1 FROM {} WHERE {} = %s)").format(
        sql.Identifier(tabla),
        sql.Identifier(columna_verificar)
    )
    cursor.execute(query, (valor_verificar,))
    return cursor.fetchone()[0]

def ingresar_datos_sede():
    print("\nIngreso de datos de una sede:")
    nombre = input("Ingrese el nombre de la sede: ")
    direccion = input("Ingrese la direccion de la sede: ")
    comuna = input("Ingrese la comuna donde esta ubicada la sede: ")
    
    try:
        cursor.execute("INSERT INTO sede (nombre, direccion, comuna) VALUES (%s, %s, %s)", (nombre, direccion, comuna))
        conn.commit()
        print("Sede ingresada correctamente.")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error al ingresar la sede: {e}")

def ingresar_datos_empleado():
    print("\nIngreso de datos de un empleado:")
    nombre = input("Ingrese el nombre del empleado: ")
    apellido = input("Ingrese el apellido del empleado: ")
    rut = input("Ingrese el Rut del empleado (sin digito verificador): ")
    fono = input("Ingrese el telefono del empleado (maximo 9 digitos): ")
    trabajo = input("Ingrese el rol que cumple el empleado: ")
    sueldo = input("Ingrese el sueldo mensual del empleado en CLP: ")
    id_sede = input("ID de la sede donde trabaja el empleado: ")
    
    try:
        if not verificar_existencia('sede', 'id', id_sede):
            print(f"No existe una sede con ID '{id_sede}'. Tiene que ingresar la sede primero.")
            return
        
        cursor.execute("INSERT INTO empleados (rut, nombre, apellido, fono, trabajo, sueldo, id_sede) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                       (rut, nombre, apellido, fono, trabajo, sueldo, id_sede))
        conn.commit()
        print("Empleado ingresado correctamente.")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error al ingresar el empleado: {e}")

def ingresar_datos_cliente():
    print("\nIngreso de datos de un cliente:")
    nombre = input("Ingrese el nombre del cliente: ")
    apellido = input("Ingrese el apellido del cliente: ")
    rut = input("Ingrese el Rut del cliente (sin dígito verificador): ")
    fono = input("Ingrese el teléfono del cliente: ")
    comuna = input("Ingrese la comuna del cliente: ")
    genero = input("Ingrese el género del cliente: ")
    
    try:
        cursor.execute("INSERT INTO cliente (rut, nombre, apellido, fono, comuna, genero) VALUES (%s, %s, %s, %s, %s, %s)",
                       (rut, nombre, apellido, fono, comuna, genero))
        conn.commit()
        print("Cliente ingresado correctamente.")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error al ingresar el cliente: {e}")

def ingresar_datos_producto():
    print("\nIngreso de datos de un producto:")
    nombre = input("Ingrese el nombre del producto: ")
    precio = input("Ingrese el precio del producto en CLP: ")
    id_sede = input("ID de la sede que ofrece el producto: ")
    
    try:
        # existencia sede
        if not verificar_existencia('sede', 'id', id_sede):
            print(f"No existe una sede con ID '{id_sede}'. Tiene que ingresar la sede primero.")
            return
        
        cursor.execute("INSERT INTO producto (nombre, precio, id_sede) VALUES (%s, %s, %s)",
                       (nombre, precio, id_sede))
        conn.commit()
        print("Producto ingresado correctamente.")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error al ingresar el producto: {e}")

def ingresar_datos_servicio():
    print("\nIngreso de datos de un servicio:")
    tipo = input("Ingrese el tipo de servicio: ")
    precio = input("Ingrese el precio del servicio en CLP: ")
    id_sede = input("ID de la sede que ofrece el servicio: ")
    
    try:
        # existencia sede
        if not verificar_existencia('sede', 'id', id_sede):
            print(f"No existe una sede con ID '{id_sede}'. Tiene que ingresar la sede primero.")
            return
        
        cursor.execute("INSERT INTO servicios (tipo, precio, id_sede) VALUES (%s, %s, %s)",
                       (tipo, precio, id_sede))
        conn.commit()
        print("Servicio ingresado correctamente.")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error al ingresar el servicio: {e}")
def ingresar_datos_venta():
    print("\nIngreso de datos de una venta:")
    fecha_str = input("Ingrese la fecha de la cita en formato YYYY-MM-DD: ")
    total = input("Ingrese el total de la venta en CLP: ")
    id_sede = input("ID de la sede ofrece el producto: ")
    rut = input("Ingrese el Rut del cliente (sin dígito verificador): ")
    try:
        fecha = datetime.strptime(fecha_str, '%Y-%m-%d').date()

        cursor.execute("INSERT INTO venta (fecha, total, rut, id_sede) VALUES (%s, %s, %s, %s) RETURNING id_venta", 
                       (fecha, total, rut, id_sede))
        id_venta= cursor.fetchone()[0]
        conn.commit()
        print(f"Venta programada correctamente con ID: {id_venta}")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error al ingresar la venta: {e}")

def ingresar_datos_cita():
    print("\nIngreso de datos de una cita:")
    fecha_str = input("Ingrese la fecha de la cita en formato YYYY-MM-DD: ")
    hora_inicio_str = input("Ingrese la hora de inicio de la cita en formato HH:MM: ")
    hora_fin_str = input("Ingrese la hora de termino de la cita en formato HH:MM: ")
    rut_cliente = input("Ingrese el Rut del cliente (sin digito verificador): ")
    precio = input("Ingrese el precio de la cita: ")
    
    id_sede = input("ID de la sede donde se realizara la cita: ")
    
    try:
        # ver si existe la sede
        if not verificar_existencia('sede', 'id', id_sede):
            print(f"No existe una sede con ID '{id_sede}'. Tiene que ingresar la sede primero.")
            return
        #formato fecha y hora
        fecha = datetime.strptime(fecha_str, '%Y-%m-%d').date()
        hora_inicio = datetime.strptime(hora_inicio_str, '%H:%M').time()
        hora_fin = datetime.strptime(hora_fin_str, '%H:%M').time()
        cursor.execute("INSERT INTO cita (fecha, precio, hora_inicio, hora_fin, rut, id_sede) VALUES (%s, %s, %s, %s, %s, %s) RETURNING id_cita", 
                       (fecha, precio, hora_inicio, hora_fin, rut_cliente, id_sede))
        id_cita = cursor.fetchone()[0]
        conn.commit()
        print(f"Cita programada correctamente con ID: {id_cita}")
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error al ingresar la cita: {e}")

def menu_principal():
    while True:
        print("\n--- MENU PRINCIPAL ---")
        print("1. Ingresar datos de una sede")
        print("2. Ingresar datos de un empleado")
        print("3. Ingresar datos de un cliente")
        print("4. Ingresar datos de un producto")
        print("5. Ingresar datos de un servicio")
        print("6. Reservar una cita")
        print("7. Registrar una venta")
        print("8. Salir")
        
        opcion = input("Seleccione una opcion: ")
        
        if opcion == "1":
            ingresar_datos_sede()
        elif opcion == "2":
            ingresar_datos_empleado()
        elif opcion == "3":
            ingresar_datos_cliente()
        elif opcion == "4":
            ingresar_datos_producto()
        elif opcion == "5":
            ingresar_datos_servicio()
        elif opcion == "6":
            ingresar_datos_cita()
        elif opcion == "7":
            ingresar_datos_venta()
        elif opcion == "8":
            print("Saliendo del programa...")
            break
        else:
            print("Opción invalida. Intente nuevamente.")

#main
if __name__ == "__main__":
    menu_principal()

cursor.close()
conn.close()
