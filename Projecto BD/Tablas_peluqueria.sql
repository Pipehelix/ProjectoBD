CREATE TABLE public.sede (
	id serial4 NOT NULL,
	nombre varchar NULL,
	direccion varchar NULL,
	comuna varchar NULL,
	CONSTRAINT sede_pk PRIMARY KEY (id)
);
COMMENT ON TABLE public.sede IS 'Sede de cadena de peluquerías';

-- Column comments

COMMENT ON COLUMN public.sede.id IS 'Identificador de la sede';
COMMENT ON COLUMN public.sede.nombre IS 'Nombre de la sede';
COMMENT ON COLUMN public.sede.direccion IS 'Dirección de la calle donde se ubica la sede';
COMMENT ON COLUMN public.sede.comuna IS 'Comuna en donde está la sede';


CREATE TABLE public.empleados (
	rut serial4 NOT NULL,
	fono int4 NULL,
	nombre varchar NULL,
	apellido varchar NULL,
	trabajo varchar NULL,
	sueldo int4 NULL,
	CONSTRAINT empleados_pk PRIMARY KEY (rut)
);
COMMENT ON TABLE public.empleados IS 'Empleados de una sede de la peluquería';

-- Column comments

COMMENT ON COLUMN public.empleados.rut IS 'Rut del empleado sin digito verificador';
COMMENT ON COLUMN public.empleados.fono IS 'Teléfono del empleado';
COMMENT ON COLUMN public.empleados.nombre IS 'Nombre del empleado';
COMMENT ON COLUMN public.empleados.apellido IS 'Apellido del empleado';
COMMENT ON COLUMN public.empleados.trabajo IS 'Qué rol cumple el empleado dentro de la peluquería';
COMMENT ON COLUMN public.empleados.sueldo IS 'Sueldo mensual del empleado en CLP';
ALTER TABLE public.empleados ADD id_sede serial4 NOT NULL;
COMMENT ON COLUMN public.empleados.id_sede IS 'Sede dónde se emplea';
ALTER TABLE public.empleados ADD CONSTRAINT empleados_sede_fk FOREIGN KEY (id_sede) REFERENCES public.sede(id) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;


CREATE TABLE public.cliente (
	rut serial4 NOT NULL,
	nombre varchar NULL,
	apellido varchar NULL,
	fono int4 NULL,
	comuna varchar NULL,
	genero varchar NULL,
	CONSTRAINT cliente_pk PRIMARY KEY (rut)
);
COMMENT ON TABLE public.cliente IS 'Cliente que buscó servicios o compró productos en una sede';

-- Column comments

COMMENT ON COLUMN public.cliente.rut IS 'Rut del cliente sin digito verificador';
COMMENT ON COLUMN public.cliente.nombre IS 'Nombre del cliente';
COMMENT ON COLUMN public.cliente.apellido IS 'Apellido del cliente';
COMMENT ON COLUMN public.cliente.fono IS 'Telefono del cliente';
COMMENT ON COLUMN public.cliente.comuna IS 'Comuna de donde proviene el cliente';
COMMENT ON COLUMN public.cliente.genero IS 'Género del cliente';


CREATE TABLE public.producto (
	id_producto serial4 NOT NULL,
	nombre varchar NULL,
	precio int4 NULL,
	CONSTRAINT producto_pk PRIMARY KEY (id_producto)
);
COMMENT ON TABLE public.producto IS 'Producto que una sede tiene a la venta';

-- Column comments

COMMENT ON COLUMN public.producto.id_producto IS 'Identificador del producto';
COMMENT ON COLUMN public.producto.nombre IS 'Nombre del producto';
COMMENT ON COLUMN public.producto.precio IS 'Precio del producto en CLP';
ALTER TABLE public.producto ADD id_sede serial4 NOT NULL;
COMMENT ON COLUMN public.producto.id_sede IS 'Sede que ofrece el producto';
ALTER TABLE public.producto ADD CONSTRAINT producto_sede_fk FOREIGN KEY (id_sede) REFERENCES public.sede(id) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;


CREATE TABLE public.servicios (
	id_serv serial4 NOT NULL,
	tipo varchar NULL,
	precio int4 NULL,
	CONSTRAINT servicios_pk PRIMARY KEY (id_serv)
);
COMMENT ON TABLE public.servicios IS 'Servicios que ofrece una sede';

-- Column comments

COMMENT ON COLUMN public.servicios.id_serv IS 'Identificador del servico a ofrecer';
COMMENT ON COLUMN public.servicios.tipo IS 'Nombre del servicio que se realiza';
COMMENT ON COLUMN public.servicios.precio IS 'Costo del servico a realizar en CLP';
ALTER TABLE public.servicios ADD id_sede serial4 NOT NULL;
COMMENT ON COLUMN public.servicios.id_sede IS 'Sede donde se ofrecen los servicios';
ALTER TABLE public.servicios ADD CONSTRAINT servicios_sede_fk FOREIGN KEY (id_sede) REFERENCES public.sede(id) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;


CREATE TABLE public.venta (
	id_venta serial4 NOT NULL,
	fecha date NULL,
	total int4 NULL,
	CONSTRAINT venta_pk PRIMARY KEY (id_venta)
);
COMMENT ON TABLE public.venta IS 'Boleta de la venta de productos a un cliente';
ALTER TABLE public.venta ADD id_sede serial4 NOT NULL;
COMMENT ON COLUMN public.venta.id_sede IS 'Sede donde se realizó la venta';
ALTER TABLE public.venta ADD CONSTRAINT venta_sede_fk FOREIGN KEY (id_sede) REFERENCES public.sede(id) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;

-- Column comments

COMMENT ON COLUMN public.venta.id_venta IS 'Identificador de una venta en particular';
COMMENT ON COLUMN public.venta.fecha IS 'Día en que la venta fué realizada';
COMMENT ON COLUMN public.venta.total IS 'Total del precio a cobrar al cliente, calculable';
ALTER TABLE public.venta ADD rut serial4 NOT NULL;
COMMENT ON COLUMN public.venta.rut IS 'Rut del cliente comprando';
ALTER TABLE public.venta ADD CONSTRAINT venta_cliente_fk FOREIGN KEY (rut) REFERENCES public.cliente(rut) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;


CREATE TABLE public.producto_venta (
	id_producto serial4 NOT NULL,
	id_venta serial4 NOT NULL,
	CONSTRAINT producto_venta_pk PRIMARY KEY (id_producto,id_venta),
	CONSTRAINT producto_venta_venta_fk FOREIGN KEY (id_venta) REFERENCES public.venta(id_venta) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT,
	CONSTRAINT producto_venta_producto_fk FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT
);
COMMENT ON TABLE public.producto_venta IS 'Relación entre una venta y un producto';

-- Column comments

COMMENT ON COLUMN public.producto_venta.id_producto IS 'Identificador de un producto';
COMMENT ON COLUMN public.producto_venta.id_venta IS 'Identificador de una venta en particular';


CREATE TABLE public.cita (
	id_cita serial4 NOT NULL,
	precio int4 NULL,
	fecha date NULL,
	hora_inicio time NULL,
	hora_fin time NULL,
	rut serial4 NOT NULL,
	id_sede serial4 NOT NULL,
	CONSTRAINT cita_pk PRIMARY KEY (id_cita),
	CONSTRAINT cita_sede_fk FOREIGN KEY (id_sede) REFERENCES public.sede(id) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT,
	CONSTRAINT cita_cliente_fk FOREIGN KEY (rut) REFERENCES public.cliente(rut) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT
);
COMMENT ON TABLE public.cita IS 'Cita que realiza un clienta en una sede por sus servicios ofrecidos';

-- Column comments

COMMENT ON COLUMN public.cita.id_cita IS 'Identificador de una cita en particular';
COMMENT ON COLUMN public.cita.precio IS 'Costo toal de la cita, calculable';
COMMENT ON COLUMN public.cita.fecha IS 'Día en el que se realizó la cita';
COMMENT ON COLUMN public.cita.hora_inicio IS 'Hora en la que inició la cita';
COMMENT ON COLUMN public.cita.hora_fin IS 'Hora de término de la cita';
COMMENT ON COLUMN public.cita.rut IS 'Rut del cliente';
COMMENT ON COLUMN public.cita.id_sede IS 'Sede donde se realizó la cita';


CREATE TABLE public.detalles_de_servicio (
	rut serial4 NOT NULL,
	id_cita serial4 NOT NULL,
	id_serv serial4 NOT NULL,
	CONSTRAINT detalles_de_servicio_pk PRIMARY KEY (rut,id_cita,id_serv),
	CONSTRAINT detalles_de_servicio_empleados_fk FOREIGN KEY (rut) REFERENCES public.empleados(rut) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT,
	CONSTRAINT detalles_de_servicio_cita_fk FOREIGN KEY (id_cita) REFERENCES public.cita(id_cita) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT,
	CONSTRAINT detalles_de_servicio_servicios_fk FOREIGN KEY (id_serv) REFERENCES public.servicios(id_serv) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT
);
COMMENT ON TABLE public.detalles_de_servicio IS 'Infromación del servicio entregado en una cita';

-- Column comments

COMMENT ON COLUMN public.detalles_de_servicio.rut IS 'Rut del empleado que entrega el servicio';
COMMENT ON COLUMN public.detalles_de_servicio.id_cita IS 'Cita en particular donde se entrega el servicio';
COMMENT ON COLUMN public.detalles_de_servicio.id_serv IS 'Identificador del servicio realizado';
