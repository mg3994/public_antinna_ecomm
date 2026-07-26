import { IUserClaimsRepository, UserClaims } from '../domain/types';

export class UserClaimsRepository implements IUserClaimsRepository {
	async getUserClaims(db: any, uid: string): Promise<UserClaims> {
		const result = (await db.prepare('SELECT * FROM user_claims WHERE uid = ?').bind(uid).first()) as any;

		if (result) {
			return {
				uid,
				owners: JSON.parse(result.owners) as string[],
				moderators: JSON.parse(result.moderators) as string[],
				staffs: JSON.parse(result.staffs) as string[],
			};
		}

		return {
			uid,
			owners: [],
			moderators: [],
			staffs: [],
		};
	}

	async saveUserClaims(db: any, claims: UserClaims): Promise<void> {
		await db
			.prepare('INSERT OR REPLACE INTO user_claims (uid, owners, moderators, staffs) VALUES (?, ?, ?, ?)')
			.bind(claims.uid, JSON.stringify(claims.owners), JSON.stringify(claims.moderators), JSON.stringify(claims.staffs))
			.run();
	}
}
