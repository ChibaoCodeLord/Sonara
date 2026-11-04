import dotenv from 'dotenv';
import {fileURLToPath} from 'node:url';

dotenv.config({path:fileURLToPath(new URL('../../.env',import.meta.url)),quiet:true});
const positive=(name,fallback)=>{const n=Number(process.env[name]||fallback);if(!Number.isSafeInteger(n)||n<1)throw new Error(`${name} must be a positive integer`);return n;};
const trustProxy=process.env.TRUST_PROXY;
if(trustProxy&&!/^[1-9]\d*$/.test(trustProxy)&&trustProxy!=='false')throw new Error('TRUST_PROXY must be a positive hop count or false');
if(process.env.NODE_ENV==='production'&&(!process.env.JWT_SECRET||process.env.JWT_SECRET==='sonara_secret_key_default'||Buffer.byteLength(process.env.JWT_SECRET)<32))throw new Error('JWT_SECRET must be configured securely in production');

export const ENV = {
  PORT: process.env.PORT || 5000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  MONGO_URI: process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/sonara_db',
  JWT_SECRET: process.env.JWT_SECRET || 'sonara_secret_key_default',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '1h',
  REFRESH_TOKEN_DAYS: positive('AUTH_REFRESH_DAYS',30),
  API_RATE_LIMIT: positive('API_RATE_LIMIT',100),
  TRUST_PROXY: trustProxy&&trustProxy!=='false'?Number(trustProxy):false,
  CORS_ORIGIN: process.env.CORS_ORIGIN || '*',
};
