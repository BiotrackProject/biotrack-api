import { describe, it, expect } from '@jest/globals';
import {
  globalLimiter,
  authLimiter,
  denunciaPublicaLimiter,
  seguimientoLimiter,
  telemetriaLimiter,
} from '../../src/middleware/rateLimiter.js';

/**
 * Tests unitarios de configuración para los middlewares de rate limiting.
 *
 * express-rate-limit v7 retorna funciones Express estándar (req, res, next).
 * La validación del comportamiento de 429 se cubre en tests de integración
 * (supertest contra la app real).
 */

const isExpressMiddleware = (fn: unknown): boolean =>
  typeof fn === 'function' && (fn as { length: number }).length === 3;

describe('Rate limiter — instancias exportadas', () => {
  it('globalLimiter es un middleware Express válido', () => {
    expect(isExpressMiddleware(globalLimiter)).toBe(true);
  });

  it('authLimiter es un middleware Express válido', () => {
    expect(isExpressMiddleware(authLimiter)).toBe(true);
  });

  it('denunciaPublicaLimiter es un middleware Express válido', () => {
    expect(isExpressMiddleware(denunciaPublicaLimiter)).toBe(true);
  });

  it('seguimientoLimiter es un middleware Express válido', () => {
    expect(isExpressMiddleware(seguimientoLimiter)).toBe(true);
  });

  it('telemetriaLimiter es un middleware Express válido', () => {
    expect(isExpressMiddleware(telemetriaLimiter)).toBe(true);
  });

  it('todos los limiters son instancias distintas (sin reutilización accidental)', () => {
    const limiters = [
      globalLimiter,
      authLimiter,
      denunciaPublicaLimiter,
      seguimientoLimiter,
      telemetriaLimiter,
    ];
    expect(new Set(limiters).size).toBe(5);
  });
});
