import { IAuthService, UserClaims, VerifiedUser } from '../domain/types';

export class AuthService implements IAuthService {
  private decodeJwt(token: string): any {
    try {
      const parts = token.split('.');
      if (parts.length !== 3) return null;
      const payload = parts[1];

      const base64 = payload.replace(/-/g, '+').replace(/_/g, '/');
      const jsonPayload = decodeURIComponent(
        atob(base64)
          .split('')
          .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
          .join('')
      );
      return JSON.parse(jsonPayload);
    } catch (e) {
      console.error('Failed to decode JWT payload:', e);
      return null;
    }
  }

  private base64UrlToUint8Array(str: string): Uint8Array {
    const base64 = str.replace(/-/g, '+').replace(/_/g, '/');
    const pad = base64.length % 4;
    const padded = pad ? base64 + '='.repeat(4 - pad) : base64;
    const binary = atob(padded);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return bytes;
  }

  async verifyIdToken(token: string, projectId: string, kv: any): Promise<VerifiedUser | null> {
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    const header = this.decodeJwt(parts[0]);
    const decoded = this.decodeJwt(parts[1]);
    if (!header || !decoded) return null;

    const now = Math.floor(Date.now() / 1000);

    // 1. Verify token is not expired
    if (decoded.exp && now >= decoded.exp) {
      console.error('ID Token expired. exp:', decoded.exp, 'now:', now);
      return null;
    }

    // 2. Verify audience matches the target Firebase Project ID
    if (decoded.aud !== projectId) {
      console.error('ID Token audience mismatch. aud:', decoded.aud, 'expected:', projectId);
      return null;
    }

    // 3. Verify issuer matches the expected secure token URL
    const expectedIssuer = `https://securetoken.google.com/${projectId}`;
    if (decoded.iss !== expectedIssuer) {
      console.error('ID Token issuer mismatch. iss:', decoded.iss, 'expected:', expectedIssuer);
      return null;
    }

    // 4. Verify Cryptographic RS256 Signature using Google JWK cached in KV
    try {
      const kid = header.kid;
      if (!kid) {
        console.error('Missing kid claim in JWT header.');
        return null;
      }

      const cacheKey = 'firebase_public_jwks';
      let jwksStr = await kv.get(cacheKey);
      let jwks: any;

      if (jwksStr) {
        jwks = JSON.parse(jwksStr);
      } else {
        const jwksUrl = 'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';
        const res = await fetch(jwksUrl);
        if (!res.ok) throw new Error('Failed to fetch Google JWKs.');
        jwks = await res.json();

        await kv.put(cacheKey, JSON.stringify(jwks), { expirationTtl: 3600 });
      }

      const keysList = jwks.keys || [];
      const targetJwk = keysList.find((key: any) => key.kid === kid);
      if (!targetJwk) {
        console.error('No matching JWK found for kid:', kid);
        return null;
      }

      const cryptoKey = await crypto.subtle.importKey(
        'jwk',
        targetJwk,
        { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
        false,
        ['verify']
      );

      const dataBytes = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);
      const signatureBytes = this.base64UrlToUint8Array(parts[2]);

      const verified = await crypto.subtle.verify(
        'RSASSA-PKCS1-v1_5',
        cryptoKey,
        signatureBytes,
        dataBytes
      );

      if (!verified) {
        console.error('RS256 signature verification failed!');
        return null;
      }

      return {
        uid: decoded.sub,
        email: decoded.email,
        name: decoded.name,
        picture: decoded.picture,
        phoneNumber: decoded.phone_number
      };
    } catch (err) {
      console.error('Cryptographic signature verification threw exception:', err);
      return null;
    }
  }

  async getUserClaims(db: any, uid: string): Promise<UserClaims> {
    const result = await db.prepare('SELECT * FROM user_claims WHERE uid = ?')
      .bind(uid)
      .first() as any;

    if (result) {
      return {
        owners: JSON.parse(result.owners) as string[],
        moderators: JSON.parse(result.moderators) as string[],
        staffs: JSON.parse(result.staffs) as string[]
      };
    }

    return { owners: [], moderators: [], staffs: [] };
  }

  hasStoreAccess(claims: UserClaims, storeId: string, requiredRoles: ('o' | 'm' | 's')[]): boolean {
    if (!claims) return false;

    return requiredRoles.some((role) => {
      if (role === 'o' && claims.owners.includes(storeId)) return true;
      if (role === 'm' && claims.moderators.includes(storeId)) return true;
      if (role === 's' && claims.staffs.includes(storeId)) return true;
      return false;
    });
  }
}
