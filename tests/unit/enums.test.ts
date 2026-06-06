import { describe, it, expect } from '@jest/globals';
import {
  TRANSICIONES_DENUNCIA,
  ESTADOS_REQUIEREN_COMENTARIO,
  MODULO_SISTEMA,
  ACCION_PERMISO,
  NIVEL_RIESGO,
  TIPO_SENSOR,
  TIPO_ACTIVIDAD,
  ESTADO_DENUNCIA,
  ESTADO_USUARIO,
} from '../../src/shared/constants/enums.js';

describe('TRANSICIONES_DENUNCIA — máquina de estados RF-2.3', () => {
  it('Pendiente solo puede transicionar a En_Investigacion', () => {
    expect(TRANSICIONES_DENUNCIA.Pendiente).toEqual(['En_Investigacion']);
  });

  it('En_Investigacion puede ir a Verificada o Desestimada', () => {
    expect(TRANSICIONES_DENUNCIA.En_Investigacion).toContain('Verificada');
    expect(TRANSICIONES_DENUNCIA.En_Investigacion).toContain('Desestimada');
    expect(TRANSICIONES_DENUNCIA.En_Investigacion).toHaveLength(2);
  });

  it('Verificada puede ir a Resuelta o Desestimada', () => {
    expect(TRANSICIONES_DENUNCIA.Verificada).toContain('Resuelta');
    expect(TRANSICIONES_DENUNCIA.Verificada).toContain('Desestimada');
  });

  it('Resuelta es un estado terminal sin transiciones', () => {
    expect(TRANSICIONES_DENUNCIA.Resuelta).toHaveLength(0);
  });

  it('Desestimada es un estado terminal sin transiciones', () => {
    expect(TRANSICIONES_DENUNCIA.Desestimada).toHaveLength(0);
  });

  it('Pendiente no puede ir directamente a Resuelta (salto inválido)', () => {
    expect(TRANSICIONES_DENUNCIA.Pendiente).not.toContain('Resuelta');
  });

  it('Pendiente no puede ir directamente a Desestimada', () => {
    expect(TRANSICIONES_DENUNCIA.Pendiente).not.toContain('Desestimada');
  });
});

describe('ESTADOS_REQUIEREN_COMENTARIO', () => {
  it('Resuelta requiere comentario', () => {
    expect(ESTADOS_REQUIEREN_COMENTARIO).toContain('Resuelta');
  });

  it('Desestimada requiere comentario', () => {
    expect(ESTADOS_REQUIEREN_COMENTARIO).toContain('Desestimada');
  });

  it('Pendiente no requiere comentario', () => {
    expect(ESTADOS_REQUIEREN_COMENTARIO).not.toContain('Pendiente');
  });

  it('En_Investigacion no requiere comentario', () => {
    expect(ESTADOS_REQUIEREN_COMENTARIO).not.toContain('En_Investigacion');
  });
});

describe('Constantes de enums', () => {
  it('MODULO_SISTEMA tiene exactamente 6 módulos (según SRS)', () => {
    expect(Object.keys(MODULO_SISTEMA)).toHaveLength(6);
  });

  it('ACCION_PERMISO tiene exactamente 7 acciones', () => {
    expect(Object.keys(ACCION_PERMISO)).toHaveLength(7);
  });

  it('NIVEL_RIESGO tiene los 4 niveles esperados', () => {
    expect(NIVEL_RIESGO.Bajo).toBe('Bajo');
    expect(NIVEL_RIESGO.Medio).toBe('Medio');
    expect(NIVEL_RIESGO.Alto).toBe('Alto');
    expect(NIVEL_RIESGO.Critico).toBe('Critico');
  });

  it('TIPO_SENSOR incluye GPS_Tracker y Audio', () => {
    expect(TIPO_SENSOR.GPS_Tracker).toBe('GPS_Tracker');
    expect(TIPO_SENSOR.Audio).toBe('Audio');
  });

  it('TIPO_ACTIVIDAD incluye extracción en zona protegida', () => {
    expect(TIPO_ACTIVIDAD.Extraccion_Zona_Protegida).toBe('Extraccion_Zona_Protegida');
  });

  it('ESTADO_DENUNCIA tiene los 5 estados del flujo', () => {
    expect(Object.keys(ESTADO_DENUNCIA)).toHaveLength(5);
  });

  it('ESTADO_USUARIO tiene los 2 estados de usuario', () => {
    expect(Object.keys(ESTADO_USUARIO)).toHaveLength(2);
  });
});
