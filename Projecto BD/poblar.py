import datetime
import psycopg2
from faker import Faker
import random

# conexion db
conn = psycopg2.connect(
    host="localhost", 
    database=" ",  
    user="postgres",       
    password=" "   
)
cursor = conn.cursor()
fake = Faker('es_ES')


def generar_rut_unico(ruts_existentes):
    while True:
        rut = random.randint(9000000, 23000000)
        if rut not in ruts_existentes:
            ruts_existentes.add(rut)
            return rut

# Poblar la tabla sede
def populate_sede(num_rows):
    for _ in range(num_rows):
        nombre = fake.company()
        direccion = fake.address()
        comuna = fake.city()
        cursor.execute("INSERT INTO sede (nombre, direccion, comuna) VALUES (%s, %s, %s)", (nombre, direccion, comuna))
    conn.commit()

# Poblar la tabla cliente
def populate_cliente(num_rows, ruts_existentes):
    for _ in range(num_rows):
        rut = generar_rut_unico(ruts_existentes)
        nombre = fake.first_name()
        apellido = fake.last_name()
        fono = random.randint(600000000, 699999999)
        comuna = fake.city()
        genero = random.choice(['Hombre', 'Mujer'])
        cursor.execute("INSERT INTO cliente (rut, nombre, apellido, fono, comuna, genero) VALUES (%s, %s, %s, %s, %s, %s)", (rut, nombre, apellido, fono, comuna, genero))
    conn.commit()

def populate_producto(num_rows):
    cursor.execute("SELECT id FROM sede")
    sedes_ids = [row[0] for row in cursor.fetchall()]
    existing_products = set()
    for _ in range(num_rows):
        num = random.randint(1, 25)
        nombre = random.choice([f'Shampoo{num}', f'Maquillaje{num}', f'Acondicionador{num}', f'Tinte{num}', f'Crema para piel{num}'])
        precio = random.randint(20000, 70000)
        id_sede = random.choice(sedes_ids)
        product_key = (nombre, id_sede)
        if product_key in existing_products:
            continue
        existing_products.add(product_key)
        try:
            cursor.execute("INSERT INTO producto (nombre, precio, id_sede) VALUES (%s, %s, %s)", (nombre, precio, id_sede))
        except psycopg2.errors.UniqueViolation:
            conn.rollback()  # Deshacer la transacción si hay una violación única
        else:
            conn.commit()

# Poblar la tabla empleados
def populate_empleados(num_rows, ruts_existentes):
    cursor.execute("SELECT id FROM sede")
    sedes_ids = [row[0] for row in cursor.fetchall()]
    for _ in range(num_rows):
        rut = generar_rut_unico(ruts_existentes)
        nombre = fake.first_name()
        apellido = fake.last_name()
        fono = random.randint(600000000, 699999999)
        trabajo = random.choice(['Peluquero', 'Cajero', 'Barbero'])
        sueldo = random.randint(500000, 850000)
        id_sede = random.choice(sedes_ids)
        cursor.execute("INSERT INTO empleados (rut, nombre, apellido, fono, trabajo, sueldo, id_sede) VALUES (%s, %s, %s, %s, %s, %s, %s)", (rut, nombre, apellido, fono, trabajo, sueldo, id_sede))
    conn.commit()

# Poblar la tabla servicios
def populate_servicios(num_rows):
    cursor.execute("SELECT id FROM sede")
    sedes_ids = [row[0] for row in cursor.fetchall()]
    for _ in range(num_rows):
        tipo = random.choice(['Cortar pelo', 'Lavar pelo', 'Cortar barba', 'Teñir pelo', 'Corte de barba y pelo'])
        precio = random.randint(20000, 50000)
        id_sede = random.choice(sedes_ids)
        cursor.execute("INSERT INTO servicios (tipo, precio, id_sede) VALUES (%s, %s, %s)", (tipo, precio, id_sede))
    conn.commit()

# Poblar la tabla venta
def populate_venta(num_rows):
    cursor.execute("SELECT id FROM sede")
    sedes_ids = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT rut FROM cliente")
    clientes_ruts = [row[0] for row in cursor.fetchall()]
    for _ in range(num_rows):
        fecha = fake.date_between(start_date='-1y', end_date='today')
        total = random.randint(20000, 100000)
        id_sede = random.choice(sedes_ids)
        rut = random.choice(clientes_ruts)
        cursor.execute("INSERT INTO venta (fecha, total, id_sede, rut) VALUES (%s, %s, %s, %s)", (fecha, total, id_sede, rut))
    conn.commit()

# Poblar la tabla producto_venta
def populate_producto_venta(num_rows):
    cursor.execute("SELECT id_venta FROM venta")
    ventas_ids = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT id_producto FROM producto")
    productos_ids = [row[0] for row in cursor.fetchall()]
    existing_combinations = set()
    for _ in range(num_rows):
        while True:
            id_venta = random.choice(ventas_ids)
            id_producto = random.choice(productos_ids)
            combination = (id_producto, id_venta)
            if combination not in existing_combinations:
                existing_combinations.add(combination)
                cursor.execute("INSERT INTO producto_venta (id_producto, id_venta) VALUES (%s, %s)", (id_producto, id_venta))
                break
    conn.commit()
def random_time():
    return datetime.time(random.randint(0, 23), random.randint(0, 59), random.randint(0, 59))

# Poblar la tabla cita
def populate_cita(num_rows):
    cursor.execute("SELECT id FROM sede")
    sedes_ids = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT rut FROM cliente")
    clientes_ruts = [row[0] for row in cursor.fetchall()]
    rango_minimo = 30 * 60  # 30 minutos en segundos
    rango_maximo = 5 * 60 * 60  # 5 horas en segundos

    for _ in range(num_rows):
        while True:
            fecha = fake.date_between(start_date='-3y', end_date='today')
            precio = random.randint(20000, 100000)
            rut = random.choice(clientes_ruts)
            id_sede = random.choice(sedes_ids)
            hora_inicio = random_time()
            hora_fin = random_time()
            diferencia = (datetime.datetime.combine(datetime.date.today(), hora_fin) - datetime.datetime.combine(datetime.date.today(), hora_inicio)).total_seconds()

            # Validar que la diferencia esté dentro del rango permitido
            while rango_maximo < diferencia or diferencia < rango_minimo:
                hora_inicio = random_time()
                hora_fin = random_time()
                diferencia = (datetime.datetime.combine(datetime.date.today(), hora_fin) - datetime.datetime.combine(datetime.date.today(), hora_inicio)).total_seconds()

            # Verificar si el cliente ya tiene una cita en la misma fecha
            cursor.execute("SELECT COUNT(*) FROM cita WHERE rut = %s AND fecha = %s", (rut, fecha))
            count = cursor.fetchone()[0]
            if count == 0:
                cursor.execute("INSERT INTO cita (fecha, hora_inicio, hora_fin, precio, rut, id_sede) VALUES (%s, %s, %s, %s, %s, %s)", (fecha, hora_inicio, hora_fin, precio, rut, id_sede))
                conn.commit()
                break

# Poblar la tabla detalles_de_servicio
def populate_detalles_de_servicio(num_rows):
    cursor.execute("SELECT id_cita FROM cita")
    citas_ids = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT rut FROM empleados")
    empleados_ruts = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT id_serv FROM servicios")
    servicios_ids = [row[0] for row in cursor.fetchall()]
    existing_combinations = set()
    for _ in range(num_rows):
        while True:
            id_cita = random.choice(citas_ids)
            rut = random.choice(empleados_ruts)
            id_serv = random.choice(servicios_ids)
            combination = (id_cita, rut, id_serv)
            if combination not in existing_combinations:
                existing_combinations.add(combination)
                cursor.execute("INSERT INTO detalles_de_servicio (id_cita, rut, id_serv) VALUES (%s, %s, %s)", (id_cita, rut, id_serv))
                break
    conn.commit()

# Inicializar conjunto para ruts únicos
ruts_existentes = set()
n = 1000
# Llamadas para poblar las tablas
populate_sede(10)
populate_cliente(250, ruts_existentes)
populate_producto(200)
populate_empleados(20, ruts_existentes)
populate_servicios(10)
populate_venta(n)
populate_producto_venta(50)
populate_cita(n)
populate_detalles_de_servicio(n)

cursor.close()
conn.close()
