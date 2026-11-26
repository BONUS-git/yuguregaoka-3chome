import { afterEach, expect, test } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../src/app.js';

let app: FastifyInstance | undefined;

afterEach(async () => {
  await app?.close();
  app = undefined;
});

test('TC-033 ルートの一覧に OAuth と WebAuthn の経路がない（FR-092）', async () => {
  app = buildApp();
  await app.ready();
  const routes = app.printRoutes({ commonPrefix: false }).toLowerCase();
  expect(routes).not.toContain('oauth');
  expect(routes).not.toContain('webauthn');
});
