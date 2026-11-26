import Fastify, { type FastifyInstance } from 'fastify';

// web のアプリを組み立てる（ADR-0009）。経路は M1 の FR のチケットで 1 つずつ足す。
// テストは listen せず、inject と printRoutes で確かめる（ポートを開かない）。
export function buildApp(): FastifyInstance {
  return Fastify({ logger: false });
}
