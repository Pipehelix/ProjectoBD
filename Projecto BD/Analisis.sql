CREATE TABLE public.id_tabla_cliente (
	id_tabla_cliente serial4 NOT NULL,
	rut int4 NOT NULL,
	nombre varchar NULL,
	comuna varchar NULL,
	genero varchar NULL,
	CONSTRAINT id_tabla_cliente_pk PRIMARY KEY (id_tabla_cliente)
);
COMMENT ON TABLE public.id_tabla_cliente IS 'Tabla del cliente con datos para consultas';

-- Column comments

COMMENT ON COLUMN public.id_tabla_cliente.id_tabla_cliente IS 'Identificador de la tabla del cliente';
COMMENT ON COLUMN public.id_tabla_cliente.rut IS 'rut de un cliente';
COMMENT ON COLUMN public.id_tabla_cliente.nombre IS 'Nombre del cliente';
COMMENT ON COLUMN public.id_tabla_cliente.comuna IS 'Comuna del cliente';
COMMENT ON COLUMN public.id_tabla_cliente.genero IS 'Género del cliente';


CREATE TABLE public.id_tabla_sede (
	id_tabla_sede serial4 NOT NULL,
	id_sede serial4 NOT NULL,
	nombre varchar NULL,
	comuna varchar NULL,
	CONSTRAINT id_tabla_sede_pk PRIMARY KEY (id_tabla_sede)
);
COMMENT ON TABLE public.id_tabla_sede IS 'Tabla de la sede para analisis';

-- Column comments

COMMENT ON COLUMN public.id_tabla_sede.id_tabla_sede IS 'Identificador de la tabla de la sede';
COMMENT ON COLUMN public.id_tabla_sede.id_sede IS 'Identificador de una sede';
COMMENT ON COLUMN public.id_tabla_sede.nombre IS 'Nombre de la sede';
COMMENT ON COLUMN public.id_tabla_sede.comuna IS 'Comuna en donde está establecida la sede';




CREATE TABLE public.id_tabla_servicios (
	id_tabla_servicios serial4 NOT NULL,
	tipo varchar NULL,
	precio int4 NULL,
	CONSTRAINT id_tabla_servicios_pk PRIMARY KEY (id_tabla_servicios)
);
COMMENT ON TABLE public.id_tabla_servicios IS 'Tabla de servicios para análisis';

-- Column comments

COMMENT ON COLUMN public.id_tabla_servicios.id_tabla_servicios IS 'Identificador de la tabla de servicios';
COMMENT ON COLUMN public.id_tabla_servicios.tipo IS 'Tipo de servicio ofrecido';
COMMENT ON COLUMN public.id_tabla_servicios.precio IS 'Precio del servicio en CLP';

CREATE TABLE public.id_tabla_empleados (
id_tabla_empleados serial4 NOT NULL,
rut int4 NOT NULL,
nombre varchar NULL,
trabajo varchar NULL,
sueldo int4 NULL,
CONSTRAINT id_tabla_empleados_pk PRIMARY KEY (id_tabla_empleados)
);
COMMENT ON TABLE public.id_tabla_empleados IS 'Tabla de los empleados para análisis';

-- Column comments

COMMENT ON COLUMN public.id_tabla_empleados.id_tabla_empleados IS 'Identificador de la tabla de empleados';
COMMENT ON COLUMN public.id_tabla_empleados.nombre IS 'Nombre del empleado';
COMMENT ON COLUMN public.id_tabla_empleados.trabajo IS 'Trabajo que ejerce el empleado';
COMMENT ON COLUMN public.id_tabla_empleados.sueldo IS 'Sueldo del empleado en CLP';
ALTER TABLE public.id_tabla_empleados ADD CONSTRAINT id_tabla_empleados_unique UNIQUE (rut);




CREATE TABLE public.analisis (
	id_cita serial4 NOT NULL,
	precio_cita int4 NULL,
	fecha_cita date NULL,
	hora_inicio time NULL,
	hora_fin time NULL,
	id_venta serial4 NOT NULL,
	fecha_venta date NULL,
	total int4 NULL
);
COMMENT ON TABLE public.analisis IS 'Tabla de análisis';

-- Column comments

COMMENT ON COLUMN public.analisis.id_cita IS 'identificador de una cita en particular';

COMMENT ON COLUMN public.analisis.precio_cita IS 'Precio total de una cita en CLP';
COMMENT ON COLUMN public.analisis.fecha_cita IS 'Día en el que se realizó una cita';
COMMENT ON COLUMN public.analisis.hora_inicio IS 'Hora de inicio de una cita';
COMMENT ON COLUMN public.analisis.hora_fin IS 'Hora de término de una cita';
COMMENT ON COLUMN public.analisis.id_venta IS 'Identificador de una boleta de venta en la peluquería';
COMMENT ON COLUMN public.analisis.fecha_venta IS 'Día en el que se realizó la venta';

ALTER TABLE public.analisis ADD id_tabla_cliente serial4 NOT NULL;
COMMENT ON COLUMN public.analisis.id_tabla_cliente IS 'Identificador de la tabla cliente';
ALTER TABLE public.analisis ADD id_tabla_sede serial4 not NULL;
ALTER TABLE public.analisis ADD id_tabla_empleados serial4 NOT NULL;
ALTER TABLE public.analisis ADD id_tabla_servicios serial4 NOT NULL;
ALTER TABLE public.analisis ADD CONSTRAINT analisis_id_tabla_cliente_fk FOREIGN KEY (id_tabla_cliente) REFERENCES public.id_tabla_cliente(id_tabla_cliente) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;
ALTER TABLE public.analisis ADD CONSTRAINT analisis_id_tabla_sede_fk FOREIGN KEY (id_tabla_sede) REFERENCES public.id_tabla_sede(id_tabla_sede) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;
ALTER TABLE public.analisis ADD CONSTRAINT analisis_id_tabla_empleados_fk FOREIGN KEY (id_tabla_empleados) REFERENCES public.id_tabla_empleados(id_tabla_empleados) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;
ALTER TABLE public.analisis ADD CONSTRAINT analisis_id_tabla_servicios_fk FOREIGN KEY (id_tabla_servicios) REFERENCES public.id_tabla_servicios(id_tabla_servicios) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;

ALTER TABLE id_tabla_cliente ADD CONSTRAINT unique_rut UNIQUE (rut);
ALTER TABLE id_tabla_sede ADD CONSTRAINT unique_id_sede UNIQUE (id_sede);
ALTER TABLE id_tabla_servicios ADD CONSTRAINT unique_tipo UNIQUE (tipo);

