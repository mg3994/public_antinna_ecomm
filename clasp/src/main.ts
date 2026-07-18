// export interface IProperties {
//   getProperty(key: string): string | null;
//   setProperty(key: string, value: string): void;
//   deleteProperty(key: string): void;
//   getProperties(): Record<string, string>;
//   setProperties(properties: Record<string, string>, deleteAllOthers?: boolean): void;
//   deleteAllProperties(): void;
// }

// export class AppsScriptProperties implements IProperties {
//   private properties: GoogleAppsScript.Properties.Properties;

//   constructor(scope: 'script' | 'document' | 'user' = 'script') {
//     switch (scope) {
//       case 'document':
//         this.properties = PropertiesService.getDocumentProperties()!;
//         break;
//       case 'user':
//         this.properties = PropertiesService.getUserProperties()!;
//         break;
//       case 'script':
//       default:
//         this.properties = PropertiesService.getScriptProperties()!;
//         break;
//     }
//   }

//   public getProperty(key: string): string | null {
//     return this.properties.getProperty(key);
//   }

//   public setProperty(key: string, value: string): void {
//     this.properties.setProperty(key, value);
//   }

//   public deleteProperty(key: string): void {
//     this.properties.deleteProperty(key);
//   }

//   public getProperties(): Record<string, string> {
//     return this.properties.getProperties();
//   }

//   public setProperties(properties: Record<string, string>, deleteAllOthers: boolean = false): void {
//     this.properties.setProperties(properties, deleteAllOthers);
//   }

//   public deleteAllProperties(): void {
//     this.properties.deleteAllProperties();
//   }
// }
// function Demo(target: Function) {
// 	console.log(target.name);
// }

// @Demo
// class User {}