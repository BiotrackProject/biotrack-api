-- CreateEnum
CREATE TYPE "EstadoUsuario" AS ENUM ('PENDIENTE_APROBACION', 'ACTIVO', 'INACTIVO');

-- CreateEnum
CREATE TYPE "ModuloSistema" AS ENUM ('MOD_01_AUTH', 'MOD_02_DENUNCIAS', 'MOD_03_ZONAS', 'MOD_04_INDICADORES', 'MOD_05_ACCIONES', 'MOD_06_ADMIN');

-- CreateEnum
CREATE TYPE "AccionPermiso" AS ENUM ('LEER', 'CREAR', 'EDITAR', 'ELIMINAR_LOGICO', 'EXPORTAR', 'PUBLICAR', 'CONFIGURAR');

-- CreateEnum
CREATE TYPE "EstadoDenunciaEnum" AS ENUM ('PENDIENTE', 'EN_INVESTIGACION', 'VERIFICADA', 'RESUELTA', 'DESESTIMADA');

-- CreateEnum
CREATE TYPE "EstadoSolicitud" AS ENUM ('PENDIENTE_APROBACION', 'PENDIENTE_INFO', 'APROBADA', 'RECHAZADA');

-- CreateEnum
CREATE TYPE "NivelRiesgo" AS ENUM ('BAJO', 'MEDIO', 'ALTO', 'CRITICO');

-- CreateEnum
CREATE TYPE "TipoSensor" AS ENUM ('TURBIDEZ', 'TEMPERATURA', 'MOVIMIENTO', 'NIVEL_AGUA', 'AUDIO', 'GPS_TRACKER', 'OTRO');

-- CreateEnum
CREATE TYPE "TipoActividad" AS ENUM ('EXTRACCION_RIO', 'EXTRACCION_PLAYA', 'EXTRACCION_ZONA_PROTEGIDA', 'TRANSPORTE_ILEGAL', 'OTRO');

-- CreateTable
CREATE TABLE "usuarios" (
    "id" TEXT NOT NULL,
    "auth0_id" TEXT NOT NULL,
    "nombre_completo" TEXT NOT NULL,
    "correo_electronico" TEXT NOT NULL,
    "telefono" TEXT,
    "cargo" TEXT NOT NULL,
    "institucion" TEXT NOT NULL,
    "estado" "EstadoUsuario" NOT NULL DEFAULT 'PENDIENTE_APROBACION',
    "rol_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "descripcion" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permisos" (
    "id" TEXT NOT NULL,
    "modulo" "ModuloSistema" NOT NULL,
    "accion" "AccionPermiso" NOT NULL,

    CONSTRAINT "permisos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rol_permisos" (
    "id" TEXT NOT NULL,
    "rol_id" TEXT NOT NULL,
    "permiso_id" TEXT NOT NULL,

    CONSTRAINT "rol_permisos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "solicitudes_registro" (
    "id" TEXT NOT NULL,
    "auth0_user_id" TEXT,
    "nombre_completo" TEXT NOT NULL,
    "correo_electronico" TEXT NOT NULL,
    "cargo" TEXT NOT NULL,
    "institucion" TEXT NOT NULL,
    "estado" "EstadoSolicitud" NOT NULL DEFAULT 'PENDIENTE_APROBACION',
    "comentario_admin" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "solicitudes_registro_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tokens_revocados" (
    "id" TEXT NOT NULL,
    "jti" TEXT NOT NULL,
    "usuario_id" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "revocado_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tokens_revocados_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "denuncias" (
    "id" TEXT NOT NULL,
    "codigo_seguimiento" TEXT NOT NULL,
    "tipo_actividad" "TipoActividad" NOT NULL,
    "descripcion" TEXT NOT NULL,
    "ubicacion" JSONB,
    "evidencias_urls" TEXT[],
    "es_anonima" BOOLEAN NOT NULL DEFAULT false,
    "contacto_denunciante" TEXT,
    "estado" "EstadoDenunciaEnum" NOT NULL DEFAULT 'PENDIENTE',
    "usuario_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "denuncias_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "estados_denuncia" (
    "id" TEXT NOT NULL,
    "denuncia_id" TEXT NOT NULL,
    "estado" "EstadoDenunciaEnum" NOT NULL,
    "comentario" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "estados_denuncia_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "zonas_criticas" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "descripcion" TEXT,
    "ubicacion" JSONB NOT NULL,
    "nivel_riesgo" "NivelRiesgo" NOT NULL DEFAULT 'MEDIO',
    "api_key_hash" TEXT NOT NULL,
    "activa" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "zonas_criticas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "historial_riesgo_zonas" (
    "id" TEXT NOT NULL,
    "zona_id" TEXT NOT NULL,
    "nivel_riesgo" "NivelRiesgo" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "historial_riesgo_zonas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "registros_telemetria" (
    "id" TEXT NOT NULL,
    "zona_id" TEXT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL,
    "tipo_sensor" "TipoSensor" NOT NULL,
    "valor" DOUBLE PRECISION NOT NULL,
    "unidad" VARCHAR(20) NOT NULL,
    "coordenadas" JSONB,
    "received_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "registros_telemetria_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "acciones_correctivas" (
    "id" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "descripcion" TEXT NOT NULL,
    "publicada" BOOLEAN NOT NULL DEFAULT false,
    "creada_por" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "acciones_correctivas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "acciones_denuncias" (
    "accion_id" TEXT NOT NULL,
    "denuncia_id" TEXT NOT NULL,

    CONSTRAINT "acciones_denuncias_pkey" PRIMARY KEY ("accion_id","denuncia_id")
);

-- CreateTable
CREATE TABLE "acciones_zonas" (
    "accion_id" TEXT NOT NULL,
    "zona_id" TEXT NOT NULL,

    CONSTRAINT "acciones_zonas_pkey" PRIMARY KEY ("accion_id","zona_id")
);

-- CreateTable
CREATE TABLE "adjuntos" (
    "id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "mime_type" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "denuncia_id" TEXT,
    "accion_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "adjuntos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "logs_auditoria" (
    "id" TEXT NOT NULL,
    "usuario_id" TEXT,
    "accion" TEXT NOT NULL,
    "modulo" TEXT NOT NULL,
    "recurso_id" TEXT,
    "ip" TEXT,
    "detalle" JSONB,
    "resultado" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "logs_auditoria_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_auth0_id_key" ON "usuarios"("auth0_id");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_correo_electronico_key" ON "usuarios"("correo_electronico");

-- CreateIndex
CREATE UNIQUE INDEX "roles_nombre_key" ON "roles"("nombre");

-- CreateIndex
CREATE UNIQUE INDEX "permisos_modulo_accion_key" ON "permisos"("modulo", "accion");

-- CreateIndex
CREATE UNIQUE INDEX "rol_permisos_rol_id_permiso_id_key" ON "rol_permisos"("rol_id", "permiso_id");

-- CreateIndex
CREATE UNIQUE INDEX "tokens_revocados_jti_key" ON "tokens_revocados"("jti");

-- CreateIndex
CREATE UNIQUE INDEX "denuncias_codigo_seguimiento_key" ON "denuncias"("codigo_seguimiento");

-- CreateIndex
CREATE UNIQUE INDEX "zonas_criticas_api_key_hash_key" ON "zonas_criticas"("api_key_hash");

-- AddForeignKey
ALTER TABLE "usuarios" ADD CONSTRAINT "usuarios_rol_id_fkey" FOREIGN KEY ("rol_id") REFERENCES "roles"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rol_permisos" ADD CONSTRAINT "rol_permisos_rol_id_fkey" FOREIGN KEY ("rol_id") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rol_permisos" ADD CONSTRAINT "rol_permisos_permiso_id_fkey" FOREIGN KEY ("permiso_id") REFERENCES "permisos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tokens_revocados" ADD CONSTRAINT "tokens_revocados_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "denuncias" ADD CONSTRAINT "denuncias_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "estados_denuncia" ADD CONSTRAINT "estados_denuncia_denuncia_id_fkey" FOREIGN KEY ("denuncia_id") REFERENCES "denuncias"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "historial_riesgo_zonas" ADD CONSTRAINT "historial_riesgo_zonas_zona_id_fkey" FOREIGN KEY ("zona_id") REFERENCES "zonas_criticas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "registros_telemetria" ADD CONSTRAINT "registros_telemetria_zona_id_fkey" FOREIGN KEY ("zona_id") REFERENCES "zonas_criticas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "acciones_correctivas" ADD CONSTRAINT "acciones_correctivas_creada_por_fkey" FOREIGN KEY ("creada_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "acciones_denuncias" ADD CONSTRAINT "acciones_denuncias_accion_id_fkey" FOREIGN KEY ("accion_id") REFERENCES "acciones_correctivas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "acciones_denuncias" ADD CONSTRAINT "acciones_denuncias_denuncia_id_fkey" FOREIGN KEY ("denuncia_id") REFERENCES "denuncias"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "acciones_zonas" ADD CONSTRAINT "acciones_zonas_accion_id_fkey" FOREIGN KEY ("accion_id") REFERENCES "acciones_correctivas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "acciones_zonas" ADD CONSTRAINT "acciones_zonas_zona_id_fkey" FOREIGN KEY ("zona_id") REFERENCES "zonas_criticas"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "adjuntos" ADD CONSTRAINT "adjuntos_denuncia_id_fkey" FOREIGN KEY ("denuncia_id") REFERENCES "denuncias"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "adjuntos" ADD CONSTRAINT "adjuntos_accion_id_fkey" FOREIGN KEY ("accion_id") REFERENCES "acciones_correctivas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "logs_auditoria" ADD CONSTRAINT "logs_auditoria_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;
